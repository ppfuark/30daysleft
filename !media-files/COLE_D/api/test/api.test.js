import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve, sep } from 'node:path';
import { createConnection } from 'node:net';
import { once } from 'node:events';
import WebSocket from 'ws';
import { createApp } from '../src/server.js';

const HERE = { lat: -22.107, lng: -50.173 };
const FAR = { lat: -22.117, lng: -50.183 };
const pause = (milliseconds) => new Promise((done) => setTimeout(done, milliseconds));

function seed() {
  return {
    configuracoes_sistema: {
      versao: '1.0',
      segredo_interno: 'CONFIG-NAO-PUBLICAR',
      mensagem_erro_rua: 'Nenhum caminhão em rota para este endereço',
    },
    usuarios: [{ id: 1, nome: 'Usuário privado', pin_acesso: '9876', score_persistente: 450 }],
    mensagens_validacao: { login_invalido: 'Mensagem privada de autenticação' },
    frota_coleta_comum: [
      {
        caminhao_id: 'CAM-01', motorista: 'Carlos Silva', turno: 'Tarde', tipos_residuo: ['Orgânico'],
        posicao_atual: { ...HERE }, itinerario_ruas: ['R. Japão', 'R. Eng. Freire'],
      },
      {
        caminhao_id: 'CAM-02', motorista: 'Ana Souza', turno: 'Manhã', tipos_residuo: ['Rejeitos'],
        posicao_atual: { ...FAR }, itinerario_ruas: ['R. Manoel Rafael da Cruz'],
      },
    ],
    pontos_coleta_seletiva: [
      { id: 34, logradouro: 'R. Japão, 1055', material: 'Plástico', nivel_ocupacao: 85, coordenadas: { ...HERE } },
      { id: 31, logradouro: 'R. Manoel Rafael da Cruz', material: 'Papel', nivel_ocupacao: 30, coordenadas: { ...FAR } },
      { id: 55, logradouro: 'R. Japão, 2000', material: 'Plástico', nivel_ocupacao: 91, coordenadas: { ...FAR } },
      { id: 56, logradouro: 'R. Japão, 2001', material: 'Plástico', nivel_ocupacao: 90, coordenadas: { lat: -22.12, lng: -50.185 } },
    ],
  };
}

class Client {
  constructor(url) {
    this.messages = [];
    this.waiters = new Set();
    this.socket = new WebSocket(url);
    this.socket.on('message', (raw) => {
      let message;
      try { message = JSON.parse(raw.toString()); } catch { return; }
      this.messages.push(message);
      for (const check of this.waiters) check();
    });
  }

  async ready() {
    if (this.socket.readyState !== WebSocket.OPEN) {
      await new Promise((done, reject) => {
        this.socket.once('open', done);
        this.socket.once('error', reject);
      });
    }
    await this.next((message) => message.type === 'connected');
    return this;
  }

  send(message) {
    this.socket.send(JSON.stringify(message));
  }

  next(predicate, { after = 0, timeout = 3000 } = {}) {
    return new Promise((done, reject) => {
      let timer;
      const check = () => {
        const message = this.messages.slice(after).find(predicate);
        if (!message) return;
        clearTimeout(timer);
        this.waiters.delete(check);
        done(message);
      };
      timer = setTimeout(() => {
        this.waiters.delete(check);
        reject(new Error(`Evento esperado não recebido. Mensagens: ${JSON.stringify(this.messages.slice(after))}`));
      }, timeout);
      this.waiters.add(check);
      check();
    });
  }

  async subscribe(message) {
    const after = this.messages.length;
    this.send({ type: 'subscribe', ...message });
    return this.next((item) => item.type === 'snapshot' && item.requestId === message.requestId, { after });
  }

  terminate() {
    this.socket.terminate();
  }
}

async function fixture(t, options = {}) {
  const directory = await mkdtemp(join(tmpdir(), 'recicla-websocket-test-'));
  const pontosPath = join(directory, 'pontos.json');
  const simulacaoPath = join(directory, 'simulacao.json');
  const source = seed();
  await writeFile(pontosPath, JSON.stringify(source), 'utf8');
  await writeFile(simulacaoPath, JSON.stringify({
    descricao: 'Cenário isolado para testar movimento e ocupação',
    caminhoes: [{ caminhao_id: 'CAM-01', velocidade_kmh: 36, tipos_residuo: ['Orgânico'], trajeto: [{ ...HERE }, { ...FAR }] }],
    pontos: [{ ponto_id: 34, ciclo_ocupacao: [85, 95, 35] }],
  }), 'utf8');
  const clients = [];
  let app;
  t.after(async () => {
    for (const client of clients) client.terminate();
    if (app) await app.close();
    const temporaryRoot = resolve(tmpdir()) + sep;
    assert.ok(resolve(directory).startsWith(temporaryRoot), 'A limpeza permanece na pasta temporária');
    await rm(directory, { recursive: true, force: true });
  });
  app = await createApp({
    port: 0, host: '127.0.0.1', pontosPath, simulacaoPath,
    simulation: false, tickMs: 100, watchMs: 40, heartbeatMs: 30000,
    logger: { warn() {}, error() {} }, ...options,
  });
  return {
    app, source, pontosPath, simulacaoPath,
    async connect() {
      const client = new Client(app.url);
      clients.push(client);
      return client.ready();
    },
    async save() { await writeFile(pontosPath, JSON.stringify(source), 'utf8'); },
  };
}

function assertEnvelope(message, topic) {
  assert.equal(message.topic, topic);
  assert.ok(Number.isInteger(message.revision));
  assert.ok(Number.isFinite(Date.parse(message.timestamp)));
  assert.equal(typeof message.simulation, 'boolean');
}

test('saúde HTTP, rota inexistente e rejeição de upgrade fora de /ws', async (t) => {
  const { app } = await fixture(t);
  const origin = app.url.replace(/^ws:/u, 'http:').replace(/\/ws$/u, '');
  const health = await fetch(`${origin}/health`);
  assert.equal(health.status, 200);
  assert.equal((await health.json()).status, 'ok');
  assert.equal((await fetch(`${origin}/nao-existe`)).status, 404);
  await new Promise((done, reject) => {
    const socket = new WebSocket(`${origin.replace(/^http:/u, 'ws:')}/nao-existe`);
    const timer = setTimeout(() => { socket.terminate(); reject(new Error('Upgrade inválido não foi recusado')); }, 2000);
    socket.on('open', () => { clearTimeout(timer); socket.terminate(); reject(new Error('Upgrade fora de /ws foi aceito')); });
    socket.on('error', () => { clearTimeout(timer); done(); });
  });
});

test('assinaturas mantêm filtros independentes e normalizam caixa e acentos', async (t) => {
  const fx = await fixture(t);
  const common = await fx.connect();
  const selective = await fx.connect();
  const commonSnapshot = await common.subscribe({
    requestId: 'comum', topic: 'coleta_comum',
    filters: { logradouro: 'r. japao', turno: 'tarde', tipo_residuo: 'organico' },
    location: HERE,
  });
  assertEnvelope(commonSnapshot, 'coleta_comum');
  assert.equal(commonSnapshot.simulation, false);
  assert.deepEqual(commonSnapshot.data.caminhoes.map((truck) => truck.caminhao_id), ['CAM-01']);
  assert.equal(commonSnapshot.data.mensagem, null);
  const selectiveSnapshot = await selective.subscribe({
    requestId: 'seletiva', topic: 'coleta_seletiva',
    filters: { material: 'plastico', busca: 'JAPAO' }, location: HERE,
  });
  assertEnvelope(selectiveSnapshot, 'coleta_seletiva');
  assert.deepEqual(selectiveSnapshot.data.pontos.map((point) => point.id).sort((a, b) => a - b), [34, 55, 56]);
  assert.equal(selectiveSnapshot.data.ponto_mais_proximo.id, 34);
  assert.ok(selectiveSnapshot.data.pontos.find((point) => point.id === 34).distancia_metros < 1);
  assert.equal(selectiveSnapshot.data.pontos.find((point) => point.id === 55).ocupacao_critica, true);
  assert.equal(selectiveSnapshot.data.pontos.find((point) => point.id === 56).ocupacao_critica, false);

  const commonAfter = common.messages.length;
  const selectiveAfter = selective.messages.length;
  fx.source.pontos_coleta_seletiva[0].nivel_ocupacao = 94;
  fx.source.frota_coleta_comum[0].posicao_atual = { ...FAR };
  await fx.save();
  const [commonUpdate, selectiveUpdate] = await Promise.all([
    common.next((item) => item.type === 'update', { after: commonAfter }),
    selective.next((item) => item.type === 'update', { after: selectiveAfter }),
  ]);
  assertEnvelope(commonUpdate, 'coleta_comum');
  assertEnvelope(selectiveUpdate, 'coleta_seletiva');
  assert.deepEqual(commonUpdate.data.caminhoes.map((truck) => truck.caminhao_id), ['CAM-01']);
  assert.ok(selectiveUpdate.data.pontos.every((point) => point.material === 'Plástico'));
  assert.equal(selectiveUpdate.data.pontos.find((point) => point.id === 34).nivel_ocupacao, 94);
  assert.equal(commonUpdate.requestId, undefined);
  assert.equal(selectiveUpdate.requestId, undefined);
});

test('rua sem rota retorna a mensagem da prova e localização ausente produz distância nula', async (t) => {
  const fx = await fixture(t);
  const client = await fx.connect();
  const absent = await client.subscribe({ requestId: 'ausente', topic: 'coleta_comum', filters: { logradouro: 'Rua inexistente' } });
  assert.deepEqual(absent.data.caminhoes, []);
  assert.equal(absent.data.mensagem, 'Nenhum caminhão em rota para este endereço');
  const selective = await client.subscribe({ requestId: 'sem-gps', topic: 'coleta_seletiva', filters: { material: 'Papel' } });
  assert.equal(selective.data.pontos.length, 1);
  assert.equal(selective.data.pontos[0].distancia_metros, null);
  assert.equal(selective.data.ponto_mais_proximo, null);
});

test('JSON e parâmetros inválidos geram erro sem interromper a conexão', async (t) => {
  const fx = await fixture(t);
  const client = await fx.connect();
  let after = client.messages.length;
  client.socket.send('{ isto não é JSON');
  assert.equal((await client.next((item) => item.type === 'error', { after })).code, 'INVALID_MESSAGE');
  const invalidMessages = [
    { type: 'subscribe', requestId: 'invalido-0', topic: 'desconhecido' },
    { type: 'subscribe', requestId: 'invalido-1', topic: 'coleta_comum', filters: { turno: 'Madrugada' } },
    { type: 'subscribe', requestId: 'invalido-2', topic: 'coleta_seletiva', filters: { material: 'Madeira' } },
    { type: 'subscribe', requestId: 'invalido-3', topic: 'coleta_comum', location: { lat: 91, lng: 0 } },
    { type: 'subscribe', requestId: 'invalido-4', topic: 'coleta_comum', filters: { logradouro: 123 } },
    { type: 'subscribe', requestId: 'invalido-5', topic: 'coleta_comum', filters: { tipo_residuo: 'Nuclear' } },
  ];
  for (const message of invalidMessages) {
    after = client.messages.length;
    client.send(message);
    const response = await client.next((item) => item.type === 'error' && item.requestId === message.requestId, { after });
    assert.equal(response.code, 'INVALID_MESSAGE');
    assert.equal(typeof response.message, 'string');
  }
  after = client.messages.length;
  client.send({ type: 'ping', requestId: 'ainda-conectado' });
  const pong = await client.next((item) => item.type === 'pong', { after });
  assert.equal(pong.requestId, 'ainda-conectado');
  assert.equal(client.socket.readyState, WebSocket.OPEN);
});

test('alerta de chegada exige opt-in e se repete somente após o caminhão se afastar', async (t) => {
  const fx = await fixture(t);
  const enabled = await fx.connect();
  const disabled = await fx.connect();
  await disabled.subscribe({ requestId: 'sem-alerta', topic: 'coleta_comum', location: HERE, notifyArrival: false });
  await enabled.subscribe({ requestId: 'com-alerta', topic: 'coleta_comum', location: HERE, notifyArrival: true });
  const first = await enabled.next((item) => item.type === 'arrival_alert');
  assert.equal(first.topic, 'coleta_comum');
  assert.equal(first.data.caminhao_id, 'CAM-01');
  assert.ok(first.data.distancia_metros < 200);
  assert.ok(enabled.messages.findIndex((item) => item.type === 'snapshot') < enabled.messages.indexOf(first));

  let after = enabled.messages.length;
  fx.source.frota_coleta_comum[0].posicao_atual.lat += 0.0001;
  await fx.save();
  await enabled.next((item) => item.type === 'update', { after });
  await pause(80);
  assert.equal(enabled.messages.filter((item) => item.type === 'arrival_alert').length, 1);
  assert.equal(disabled.messages.filter((item) => item.type === 'arrival_alert').length, 0);

  after = enabled.messages.length;
  fx.source.frota_coleta_comum[0].posicao_atual = { ...FAR };
  await fx.save();
  await enabled.next((item) => item.type === 'update', { after });
  assert.equal(enabled.messages.filter((item) => item.type === 'arrival_alert').length, 1);
  after = enabled.messages.length;
  fx.source.frota_coleta_comum[0].posicao_atual = { ...HERE };
  await fx.save();
  await enabled.next((item) => item.type === 'arrival_alert', { after });
  assert.equal(enabled.messages.filter((item) => item.type === 'arrival_alert').length, 2);
  assert.equal(disabled.messages.filter((item) => item.type === 'arrival_alert').length, 0);
});

test('trocar o filtro não repete o alerta de um caminhão que continua próximo', async (t) => {
  const fx = await fixture(t);
  const client = await fx.connect();
  await client.subscribe({ requestId: 'perto', topic: 'coleta_comum', location: HERE, notifyArrival: true });
  await client.next((item) => item.type === 'arrival_alert' && item.data.caminhao_id === 'CAM-01');

  const hidden = await client.subscribe({
    requestId: 'ocultar', topic: 'coleta_comum', filters: { turno: 'Manhã' }, location: HERE, notifyArrival: true,
  });
  assert.deepEqual(hidden.data.caminhoes.map((truck) => truck.caminhao_id), ['CAM-02']);
  const visible = await client.subscribe({
    requestId: 'mostrar', topic: 'coleta_comum', filters: { turno: 'Tarde' }, location: HERE, notifyArrival: true,
  });
  assert.deepEqual(visible.data.caminhoes.map((truck) => truck.caminhao_id), ['CAM-01']);
  const after = client.messages.length;
  client.send({ type: 'ping', requestId: 'apos-filtros' });
  await client.next((item) => item.type === 'pong' && item.requestId === 'apos-filtros', { after });
  assert.equal(client.messages.filter((item) => item.type === 'arrival_alert').length, 1);
});

test('encerramento fecha conexão HTTP com cabeçalhos incompletos em menos de um segundo', async (t) => {
  const { app } = await fixture(t);
  const address = app.server.address();
  const accepted = once(app.server, 'connection');
  const socket = createConnection({ host: '127.0.0.1', port: address.port });
  t.after(() => socket.destroy());
  await Promise.all([once(socket, 'connect'), accepted]);
  await new Promise((done, reject) => {
    socket.write('GET /health HTTP/1.1\r\nHost: localhost\r\n', (error) => error ? reject(error) : done());
  });
  const closed = new Promise((done, reject) => {
    socket.once('close', done);
    // O fechamento forçado de uma requisição incompleta pode produzir RST no Windows.
    socket.once('error', (error) => { if (error.code !== 'ECONNRESET') reject(error); });
  });
  const started = performance.now();
  let timer;
  try {
    await Promise.race([
      Promise.all([app.close(), closed]),
      new Promise((_, reject) => {
        timer = setTimeout(() => {
          socket.destroy();
          reject(new Error('A conexão HTTP incompleta bloqueou o encerramento por um segundo'));
        }, 1000);
      }),
    ]);
  } finally {
    clearTimeout(timer);
  }
  assert.ok(performance.now() - started < 1000);
  assert.equal(socket.destroyed, true);
});

test('recarga mantém último JSON válido, recupera-se de erro e entrega o estado atual na reconexão', async (t) => {
  const fx = await fixture(t);
  const client = await fx.connect();
  const initial = await client.subscribe({ requestId: 'inicial', topic: 'coleta_seletiva', filters: { material: 'Plástico' }, location: HERE });
  const after = client.messages.length;
  fx.source.pontos_coleta_seletiva[0].nivel_ocupacao = 98;
  fx.source.pontos_coleta_seletiva[0].coordenadas = { ...FAR };
  await fx.save();
  const updated = await client.next((item) => item.type === 'update', { after });
  assert.ok(updated.revision > initial.revision);
  assert.equal(updated.data.pontos.find((point) => point.id === 34).ocupacao_critica, true);
  assert.deepEqual(updated.data.pontos.find((point) => point.id === 34).coordenadas, FAR);

  await writeFile(fx.pontosPath, '{ arquivo incompleto', 'utf8');
  await pause(200);
  const reconnected = await fx.connect();
  const retained = await reconnected.subscribe({ requestId: 'reconectado', topic: 'coleta_seletiva', filters: { material: 'Plástico' } });
  assert.equal(retained.data.pontos.find((point) => point.id === 34).nivel_ocupacao, 98);
  assert.equal(retained.revision, updated.revision);

  const correctedAfter = client.messages.length;
  fx.source.pontos_coleta_seletiva[0].nivel_ocupacao = 25;
  await fx.save();
  const corrected = await client.next((item) => item.type === 'update', { after: correctedAfter });
  assert.ok(corrected.revision > updated.revision);
  assert.equal(corrected.data.pontos.find((point) => point.id === 34).nivel_ocupacao, 25);
  assert.equal(corrected.data.pontos.find((point) => point.id === 34).ocupacao_critica, false);
});

test('unsubscribe interrompe atualizações e a conexão continua respondendo', async (t) => {
  const fx = await fixture(t);
  const client = await fx.connect();
  await client.subscribe({ requestId: 'inicio', topic: 'coleta_seletiva' });
  let after = client.messages.length;
  client.send({ type: 'unsubscribe', requestId: 'parar', topic: 'coleta_seletiva' });
  const response = await client.next((item) => item.type === 'unsubscribed', { after });
  assert.equal(response.requestId, 'parar');
  after = client.messages.length;
  fx.source.pontos_coleta_seletiva[0].nivel_ocupacao = 92;
  await fx.save();
  await pause(200);
  assert.equal(client.messages.slice(after).some((item) => item.type === 'update'), false);
  client.send({ type: 'ping', requestId: 'apos-parar' });
  await client.next((item) => item.type === 'pong' && item.requestId === 'apos-parar', { after });
});

test('dados de autenticação e configurações privadas nunca aparecem nas mensagens', async (t) => {
  const fx = await fixture(t);
  const client = await fx.connect();
  await client.subscribe({ requestId: 'comum', topic: 'coleta_comum' });
  await client.subscribe({ requestId: 'seletiva', topic: 'coleta_seletiva' });
  const serialized = JSON.stringify(client.messages);
  for (const forbidden of ['usuarios', 'pin_acesso', '9876', 'score_persistente', 'configuracoes_sistema', 'CONFIG-NAO-PUBLICAR', 'mensagens_validacao']) {
    assert.equal(serialized.includes(forbidden), false, `Informação privada exposta: ${forbidden}`);
  }
});

test('seed sem tipo de resíduo continua válido sem inventar uma classificação', async (t) => {
  const fx = await fixture(t);
  delete fx.source.frota_coleta_comum[0].tipos_residuo;
  await fx.save();
  await pause(120);
  const client = await fx.connect();
  const response = await client.subscribe({ requestId: 'sem-tipo', topic: 'coleta_comum', filters: { tipo_residuo: 'Orgânico' } });
  assert.deepEqual(response.data.caminhoes, []);
  assert.equal(response.data.mensagem, 'Nenhum caminhão em rota para este endereço');
});

test('simulação publica movimento, ocupação e previsão identificados como simulados sem reescrever a fonte', async (t) => {
  const fx = await fixture(t, { simulation: true, tickMs: 100 });
  const originalFile = await readFile(fx.pontosPath, 'utf8');
  const client = await fx.connect();
  const common = await client.subscribe({ requestId: 'sim-comum', topic: 'coleta_comum', filters: { logradouro: 'R. Japão' }, location: HERE });
  const selective = await client.subscribe({ requestId: 'sim-seletiva', topic: 'coleta_seletiva', filters: { material: 'Plástico' } });
  assert.equal(common.simulation, true);
  assert.equal(selective.simulation, true);
  assert.equal(common.data.caminhoes[0].previsao_simulada, true);
  assert.ok(Number.isFinite(Date.parse(common.data.caminhoes[0].previsao_chegada)));
  const after = client.messages.length;
  const originalPosition = common.data.caminhoes[0].posicao_atual;
  const originalOccupation = selective.data.pontos.find((point) => point.id === 34).nivel_ocupacao;
  const [moving, occupation] = await Promise.all([
    client.next((item) => item.type === 'update' && item.topic === 'coleta_comum'
      && JSON.stringify(item.data.caminhoes[0].posicao_atual) !== JSON.stringify(originalPosition), { after }),
    client.next((item) => item.type === 'update' && item.topic === 'coleta_seletiva'
      && item.data.pontos.find((point) => point.id === 34).nivel_ocupacao !== originalOccupation, { after }),
  ]);
  assert.ok(moving.revision > common.revision);
  assert.equal(occupation.simulation, true);
  assert.equal(await readFile(fx.pontosPath, 'utf8'), originalFile);
});
