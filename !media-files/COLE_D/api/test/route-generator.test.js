import test from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRoadScenario } from '../src/route-generator.js';
import { DataStore } from '../src/data-store.js';

const ORIGIN = { lat: -22.107, lng: -50.173 };
const SNAP = { lat: -22.1071, lng: -50.173 };
const NOW = new Date('2026-10-19T15:00:00.000Z');
const SOURCE = 'https://router.example.invalid';

function input() {
  return {
    seed: {
      usuarios: [{ nome: 'Privado', pin_acesso: '9876' }],
      configuracoes_sistema: { segredo: 'NAO-PUBLICAR-SEED' },
      frota_coleta_comum: [{
        caminhao_id: 'CAM-01', motorista: 'Carlos Silva', turno: 'Tarde',
        posicao_atual: { ...ORIGIN }, itinerario_ruas: ['R. Japão'],
      }],
      pontos_coleta_seletiva: [
        { id: 34, logradouro: 'R. Japão, 1055', material: 'Plástico', nivel_ocupacao: 85, coordenadas: { lat: -22.1085, lng: -50.1742 } },
        { id: 31, logradouro: 'R. Manoel Rafael da Cruz', material: 'Papel', nivel_ocupacao: 30, coordenadas: { lat: -22.109, lng: -50.175 } },
      ],
    },
    scenario: {
      descricao: 'Cenário de teste',
      caminhoes: [{
        caminhao_id: 'CAM-01', velocidade_kmh: 36, tipos_residuo: ['Orgânico'],
        trajeto: [{ ...ORIGIN }, { lat: -22.11, lng: -50.18 }],
      }],
      pontos: [{ ponto_id: 34, ciclo_ocupacao: [85, 95, 35] }],
    },
  };
}

function osrm(seed = input().seed, origin = ORIGIN) {
  const adjustedOrigin = { lat: origin.lat - 0.0001, lng: origin.lng };
  const requested = [origin, ...seed.pontos_coleta_seletiva.map((point) => point.coordenadas), origin];
  return {
    code: 'Ok',
    routes: [{
      distance: 1234.5,
      duration: 300.25,
      geometry: {
        type: 'LineString',
        coordinates: [
          [adjustedOrigin.lng, adjustedOrigin.lat],
          [adjustedOrigin.lng - 0.0005, adjustedOrigin.lat],
          [-50.1742, -22.1085],
          [-50.175, -22.109],
          [-50.175, adjustedOrigin.lat],
          [adjustedOrigin.lng, adjustedOrigin.lat],
        ],
      },
      legs: [
        { steps: [{ name: 'R. Japão' }, { name: '' }, { name: 'R. Manoel Rafael da Cruz' }] },
        { steps: [{ name: 'R. Japão' }, { name: 'R. Eng. Freire' }] },
      ],
    }],
    waypoints: requested.map((point, index) => ({
      location: index === 0 || index === requested.length - 1
        ? [adjustedOrigin.lng, adjustedOrigin.lat] : [point.lng, point.lat],
      distance: index === 0 || index === requested.length - 1 ? 11.12 : 0,
      name: index === 0 || index === requested.length - 1 ? 'R. Japão' : `Ecoponto ${index}`,
    })),
  };
}

function response(body) {
  return { ok: true, json: async () => structuredClone(body) };
}

function expectedWaypoints(seed) {
  return [seed.frota_coleta_comum[0].posicao_atual, ...seed.pontos_coleta_seletiva.map((point) => point.coordenadas), seed.frota_coleta_comum[0].posicao_atual];
}

test('gera uma rota fechada por vias, com origem e ecopontos em ordem, usando GeoJSON completo', async () => {
  const args = input();
  const before = structuredClone(args);
  const raw = osrm(args.seed);
  const calls = [];
  const result = await createRoadScenario({
    ...args, baseUrl: SOURCE, now: () => NOW,
    fetchImpl: async (url, options) => {
      calls.push({ url: new URL(url), options });
      return response(raw);
    },
  });
  assert.equal(calls.length, 1);
  const { url, options } = calls[0];
  const wanted = expectedWaypoints(args.seed);
  assert.equal(url.origin, SOURCE);
  assert.equal(decodeURIComponent(url.pathname), `/route/v1/driving/${wanted.map((point) => `${point.lng},${point.lat}`).join(';')}`);
  assert.equal(url.searchParams.get('geometries'), 'geojson');
  assert.equal(url.searchParams.get('overview'), 'full');
  assert.equal(url.searchParams.get('steps'), 'true');
  assert.equal(url.searchParams.get('alternatives'), 'false');
  assert.equal(url.searchParams.get('continue_straight'), 'true');
  assert.equal(url.searchParams.get('radiuses'), wanted.map(() => '200').join(';'));
  assert.ok(options.signal instanceof AbortSignal);
  assert.equal(typeof result.descricao, 'string');
  assert.ok(result.descricao.length > 0);
  assert.deepEqual(result.pontos, args.scenario.pontos);
  const truck = result.caminhoes[0];
  assert.equal(truck.velocidade_kmh, 36);
  assert.deepEqual(truck.tipos_residuo, ['Orgânico']);
  assert.deepEqual(truck.trajeto, raw.routes[0].geometry.coordinates.map(([lng, lat]) => ({ lat, lng })));
  assert.deepEqual(truck.trajeto[0], SNAP);
  assert.deepEqual(truck.trajeto.at(-1), SNAP);
  assert.deepEqual(truck.roteamento, {
    provedor: 'OSRM', perfil: 'driving', fonte: SOURCE,
    distancia_metros: 1234.5, duracao_segundos: 300.25, gerado_em: NOW.toISOString(),
    vias: ['R. Japão', 'R. Manoel Rafael da Cruz', 'R. Eng. Freire'],
    waypoints: raw.waypoints.map((waypoint, index) => ({
      solicitado: wanted[index], ajustado: { lat: waypoint.location[1], lng: waypoint.location[0] },
      distancia_snap_metros: waypoint.distance, nome: waypoint.name,
    })),
    atribuicao: '© OpenStreetMap contributors', licenca: 'https://www.openstreetmap.org/copyright',
  });
  assert.deepEqual(args, before, 'A geração não modifica a semente nem o cenário recebidos');
  assert.notEqual(result, args.scenario);
  assert.notEqual(result.pontos, args.scenario.pontos);
  assert.notEqual(truck, args.scenario.caminhoes[0]);
  const serialized = JSON.stringify(result);
  for (const secret of ['usuarios', 'pin_acesso', '9876', 'configuracoes_sistema', 'NAO-PUBLICAR-SEED']) {
    assert.equal(serialized.includes(secret), false, `Dado privado copiado para o cenário: ${secret}`);
  }
});

test('gera um percurso para cada caminhão configurado, com a posição inicial correspondente', async () => {
  const args = input();
  const secondOrigin = { lat: -22.106, lng: -50.171 };
  args.seed.frota_coleta_comum.push({ ...structuredClone(args.seed.frota_coleta_comum[0]), caminhao_id: 'CAM-02', posicao_atual: secondOrigin });
  args.scenario.caminhoes.push({ ...structuredClone(args.scenario.caminhoes[0]), caminhao_id: 'CAM-02' });
  const requestedOrigins = [];
  const result = await createRoadScenario({
    ...args, baseUrl: SOURCE,
    fetchImpl: async (url) => {
      const coordinates = decodeURIComponent(new URL(url).pathname).split('/').at(-1).split(';');
      const [lng, lat] = coordinates[0].split(',').map(Number);
      const origin = { lat, lng };
      requestedOrigins.push(origin);
      assert.equal(coordinates.at(-1), coordinates[0]);
      return response(osrm(args.seed, origin));
    },
  });
  assert.deepEqual(requestedOrigins, [ORIGIN, secondOrigin]);
  assert.equal(result.caminhoes.length, 2);
  assert.deepEqual(result.caminhoes[1].trajeto[0], { lat: secondOrigin.lat - 0.0001, lng: secondOrigin.lng });
});

test('falhas de rede, HTTP e OSRM rejeitam a geração sem alterar o cenário original', async (t) => {
  const cases = [
    ['rede indisponível', async () => { throw new Error('Rede indisponível'); }],
    ['HTTP 503', async () => ({ ok: false, status: 503 })],
    ['OSRM sem rota', async () => response({ code: 'NoRoute', routes: [], waypoints: [] })],
  ];
  for (const [name, fetchImpl] of cases) {
    await t.test(name, async () => {
      const args = input();
      const before = structuredClone(args);
      await assert.rejects(createRoadScenario({ ...args, baseUrl: SOURCE, fetchImpl }));
      assert.deepEqual(args, before);
    });
  }
});

test('geometrias e waypoints inválidos são recusados em vez de criar ligações retas', async (t) => {
  const cases = [
    ['sem rotas', (body) => { body.routes = []; }],
    ['geometria de outro tipo', (body) => { body.routes[0].geometry.type = 'Point'; }],
    ['geometria curta', (body) => { body.routes[0].geometry.coordinates = [[SNAP.lng, SNAP.lat]]; }],
    ['coordenada não finita', (body) => { body.routes[0].geometry.coordinates[1][0] = NaN; }],
    ['latitude fora do intervalo', (body) => { body.routes[0].geometry.coordinates[1][1] = 91; }],
    ['longitude fora do intervalo', (body) => { body.routes[0].geometry.coordinates[1][0] = -181; }],
    ['geometria aberta', (body) => { body.routes[0].geometry.coordinates.pop(); }],
    ['distância zerada', (body) => { body.routes[0].distance = 0; }],
    ['distância não finita', (body) => { body.routes[0].distance = Infinity; }],
    ['duração zerada', (body) => { body.routes[0].duration = 0; }],
    ['waypoint ausente', (body) => { body.waypoints.pop(); }],
    ['snap negativo', (body) => { body.waypoints[0].distance = -1; }],
    ['snap distante', (body) => { body.waypoints[0].distance = 201; }],
    ['snap não finito', (body) => { body.waypoints[0].distance = NaN; }],
    ['snap em coordenada inválida', (body) => { body.waypoints[0].location = [181, 0]; }],
    ['snap declarado curto mas distante da origem', (body) => { body.waypoints[0].location = [-50.19, -22.12]; body.waypoints[0].distance = 1; }],
    ['extremo da geometria diferente do waypoint', (body) => {
      body.routes[0].geometry.coordinates[0] = [SNAP.lng + 0.0002, SNAP.lat];
      body.routes[0].geometry.coordinates[body.routes[0].geometry.coordinates.length - 1] = [SNAP.lng + 0.0002, SNAP.lat];
    }],
  ];
  for (const [name, mutate] of cases) {
    await t.test(name, async () => {
      const args = input();
      const before = structuredClone(args);
      const body = osrm(args.seed);
      mutate(body);
      await assert.rejects(createRoadScenario({ ...args, baseUrl: SOURCE, fetchImpl: async () => response(body) }));
      assert.deepEqual(args, before);
    });
  }
});

test('caminhão desconhecido é recusado sem consultar o roteador', async () => {
  const args = input();
  args.scenario.caminhoes[0].caminhao_id = 'CAM-INEXISTENTE';
  let called = false;
  await assert.rejects(createRoadScenario({ ...args, fetchImpl: async () => { called = true; return response(osrm()); } }));
  assert.equal(called, false);
});

async function storeFixture(t, { seed, scenario }, options = {}) {
  const directory = await mkdtemp(join(tmpdir(), 'recicla-road-route-test-'));
  const pontosPath = join(directory, 'pontos.json');
  const simulacaoPath = join(directory, 'simulacao.json');
  await writeFile(pontosPath, JSON.stringify(seed), 'utf8');
  await writeFile(simulacaoPath, JSON.stringify(scenario), 'utf8');
  const store = new DataStore({ pontosPath, simulacaoPath, simulation: true, tickMs: 100, watchMs: 1000, ...options });
  t.after(async () => {
    await store.stop();
    assert.ok(resolve(directory).startsWith(resolve(tmpdir()) + sep));
    await rm(directory, { recursive: true, force: true });
  });
  return store;
}

async function routedInput() {
  const args = input();
  const scenario = await createRoadScenario({ ...args, baseUrl: SOURCE, now: () => NOW, fetchImpl: async () => response(osrm(args.seed)) });
  return { seed: args.seed, scenario };
}

test('store inicia no ponto ajustado da via e move-se sem ligar a posição original à rota', async (t) => {
  const args = await routedInput();
  const store = await storeFixture(t, args);
  await store.start();
  const initial = store.getState().caminhoes[0];
  assert.deepEqual(initial.posicao_atual, SNAP);
  assert.deepEqual(initial.percurso_simulado, args.scenario.caminhoes[0].trajeto);
  assert.notDeepEqual(initial.percurso_simulado[0], ORIGIN);
  const [updated] = await once(store, 'update');
  const moved = updated.caminhoes[0].posicao_atual;
  assert.ok(Math.abs(moved.lat - SNAP.lat) < 1e-9, 'O primeiro segmento da via segue a mesma latitude');
  assert.ok(moved.lng < SNAP.lng, 'O caminhão avança para oeste no primeiro segmento');
  assert.ok(moved.lng > args.scenario.caminhoes[0].trajeto[1].lng);
});

test('store publica os metadados de roteamento por lista explícita de campos', async (t) => {
  const args = await routedInput();
  const expected = structuredClone(args.scenario.caminhoes[0].roteamento);
  args.scenario.caminhoes[0].pin_acesso = '9876';
  args.scenario.caminhoes[0].roteamento.pin_acesso = '9876';
  args.scenario.caminhoes[0].roteamento.waypoints[0].segredo = 'NAO-PUBLICAR-WAYPOINT';
  const store = await storeFixture(t, args);
  await store.start();
  const state = store.getState();
  assert.deepEqual(state.caminhoes[0].roteamento, expected);
  const serialized = JSON.stringify(state);
  for (const secret of ['usuarios', 'pin_acesso', '9876', 'configuracoes_sistema', 'NAO-PUBLICAR-SEED', 'NAO-PUBLICAR-WAYPOINT']) {
    assert.equal(serialized.includes(secret), false, `Dado privado exposto pelo store: ${secret}`);
  }
});

test('store rejeita geometria aberta com metadados de vias para impedir retorno em linha reta', async (t) => {
  const args = await routedInput();
  args.scenario.caminhoes[0].trajeto.pop();
  const store = await storeFixture(t, args);
  await assert.rejects(store.start());
});

test('store recusa metadados de roteamento inválidos antes de publicar o estado', async (t) => {
  const cases = [
    ['provedor inesperado', (routing) => { routing.provedor = 'Outro'; }],
    ['perfil inesperado', (routing) => { routing.perfil = 'walking'; }],
    ['fonte com credenciais', (routing) => { routing.fonte = 'https://usuario:senha@router.example.invalid'; }],
    ['distância zerada', (routing) => { routing.distancia_metros = 0; }],
    ['duração inválida', (routing) => { routing.duracao_segundos = -1; }],
    ['data inexistente', (routing) => { routing.gerado_em = '2026-02-30T12:00:00.000Z'; }],
    ['via sem texto', (routing) => { routing.vias = [42]; }],
    ['snap fora do limite', (routing) => { routing.waypoints[0].distancia_snap_metros = 201; }],
    ['waypoint com coordenada inválida', (routing) => { routing.waypoints[0].ajustado.lat = 91; }],
    ['licença desconhecida', (routing) => { routing.licenca = 'https://example.invalid/licenca'; }],
  ];
  for (const [name, mutate] of cases) {
    await t.test(name, async (subtest) => {
      const args = await routedInput();
      mutate(args.scenario.caminhoes[0].roteamento);
      const store = await storeFixture(subtest, args);
      await assert.rejects(store.start());
      assert.throws(() => store.getState());
    });
  }
});

test('cenário viário salvo no projeto passa pela validação e mantém a geometria gerada no runtime', async (t) => {
  const pontosPath = fileURLToPath(new URL('../data/pontos.json', import.meta.url));
  const simulacaoPath = fileURLToPath(new URL('../data/simulacao.json', import.meta.url));
  const [seedText, scenarioText] = await Promise.all([
    readFile(pontosPath, 'utf8'), readFile(simulacaoPath, 'utf8'),
  ]);
  const seed = JSON.parse(seedText.replace(/^\uFEFF/u, ''));
  const scenario = JSON.parse(scenarioText.replace(/^\uFEFF/u, ''));
  const store = new DataStore({ pontosPath, simulacaoPath, simulation: true, tickMs: 60000, watchMs: 60000 });
  t.after(() => store.stop());
  await store.start();
  const state = store.getState();
  assert.equal(state.simulation, true);
  assert.deepEqual(state.pontos, seed.pontos_coleta_seletiva);
  assert.ok(scenario.caminhoes.length > 0);
  for (const configured of scenario.caminhoes) {
    const actual = state.caminhoes.find((truck) => truck.caminhao_id === configured.caminhao_id);
    const original = seed.frota_coleta_comum.find((truck) => truck.caminhao_id === configured.caminhao_id);
    assert.ok(actual);
    assert.ok(original);
    assert.ok(configured.trajeto.length >= 2);
    assert.deepEqual(actual.posicao_atual, configured.trajeto[0]);
    assert.deepEqual(actual.percurso_simulado, configured.trajeto);
    assert.deepEqual(actual.percurso_simulado.at(-1), actual.percurso_simulado[0]);
    assert.equal(actual.roteamento.provedor, 'OSRM');
    assert.ok(actual.roteamento.distancia_metros > 0);
    assert.deepEqual(actual.itinerario_ruas, configured.roteamento.vias);
    assert.deepEqual(actual.itinerario_ruas_cadastrado, original.itinerario_ruas);
    assert.deepEqual(actual.roteamento.waypoints.at(-1).ajustado, actual.roteamento.waypoints[0].ajustado);
  }
});
