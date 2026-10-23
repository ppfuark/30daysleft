import test from 'node:test';
import assert from 'node:assert/strict';
import { buildRanking } from '../src/ranking.js';

const FIXED_TIME = '2026-10-20T12:34:56.789Z';
const CLOCK = { now: () => new Date(FIXED_TIME) };

function user(id, score = 100, extra = {}) {
  return { id, nome: `Participante ${id}`, score_persistente: score, ...extra };
}

function freezeDeep(value) {
  if (value !== null && typeof value === 'object') {
    for (const child of Object.values(value)) freezeDeep(child);
    Object.freeze(value);
  }
  return value;
}

function assertEnvelope(result) {
  assert.equal(result.atualizado_em, FIXED_TIME);
  assert.deepEqual(Object.keys(result).sort(), ['atualizado_em', 'ranking']);
  for (const entry of result.ranking) {
    assert.deepEqual(Object.keys(entry).sort(), ['nome', 'score', 'usuario_id']);
  }
}

test('preserva a ordem dos participantes na fonte e exporta os scores sem classificação', () => {
  const document = { usuarios: [user(4, 50), user(2, 250), user(5, 10), user(1, 450), user(3, 100)] };
  const result = buildRanking(document, CLOCK);
  assertEnvelope(result);
  assert.deepEqual(result.ranking.map((entry) => entry.usuario_id), [4, 2, 5, 1, 3]);
  assert.deepEqual(result.ranking.map((entry) => entry.score), [50, 250, 10, 450, 100]);
  assert.deepEqual(result.ranking[0], {
    usuario_id: 4, nome: 'Participante 4', score: 50,
  });
});

test('mantém a ordem da fonte com mais de sete registros e scores repetidos', () => {
  const document = {
    usuarios: [user(11, 500), user(6, 600), user(10, 500), user(4, 800), user(2, 500), user(7, 400), user(5, 700), user(3, 900), user(1, 1000)],
  };
  const result = buildRanking(document, CLOCK);
  assertEnvelope(result);
  assert.deepEqual(result.ranking.map((entry) => entry.usuario_id), [11, 6, 10, 4, 2, 7, 5, 3, 1]);
  assert.deepEqual(result.ranking.map((entry) => entry.score), [500, 600, 500, 800, 500, 400, 700, 900, 1000]);
});

test('acompanha a ordem recebida também quando todos os scores são iguais', () => {
  const first = [10, 2, 8, 7, 1, 6, 3, 9, 5, 4].map((id) => user(id));
  const second = [...first].reverse();
  const result = buildRanking({ usuarios: first }, CLOCK);
  const reversed = buildRanking({ usuarios: second }, CLOCK);
  assertEnvelope(result);
  assertEnvelope(reversed);
  assert.deepEqual(result.ranking.map((entry) => entry.usuario_id), [10, 2, 8, 7, 1, 6, 3, 9, 5, 4]);
  assert.deepEqual(reversed.ranking.map((entry) => entry.usuario_id), [4, 5, 9, 3, 6, 1, 7, 8, 2, 10]);
});

test('aceita scores negativos de penalidades e preserva a ordem de zero e negativos', () => {
  const result = buildRanking({ usuarios: [user(10, -10), user(3, -20), user(1, 0), user(2, -10), user(4, 10)] }, CLOCK);
  assertEnvelope(result);
  assert.deepEqual(result.ranking.map((entry) => [entry.usuario_id, entry.score]), [[10, -10], [3, -20], [1, 0], [2, -10], [4, 10]]);
});

test('exporta todos os registros de listas vazias, pequenas ou maiores que sete', async (t) => {
  for (const count of [0, 1, 3, 6, 7, 8, 15]) {
    await t.test(`${count} participantes`, () => {
      const usuarios = Array.from({ length: count }, (_, index) => user(index + 1, index * 10));
      const result = buildRanking({ usuarios }, CLOCK);
      assertEnvelope(result);
      assert.equal(result.ranking.length, count);
      assert.deepEqual(result.ranking, usuarios.map((entry) => ({ usuario_id: entry.id, nome: entry.nome, score: entry.score_persistente })));
    });
  }
});

test('quantidade futura de participantes não limita o ranking aos dez registros atuais', () => {
  const usuarios = Array.from({ length: 37 }, (_, index) => user(index + 1, index * 10)).reverse();
  const result = buildRanking({ usuarios }, CLOCK);
  assertEnvelope(result);
  assert.equal(result.ranking.length, 37);
  assert.equal(result.ranking[0].usuario_id, 37);
  assert.equal(result.ranking.at(-1).usuario_id, 1);
  assert.deepEqual(result.ranking.map((entry) => entry.usuario_id), usuarios.map((entry) => entry.id));
});

test('aceita limites inteiros seguros para IDs e scores, além de nomes com 500 caracteres', () => {
  const result = buildRanking({ usuarios: [
    user(Number.MAX_SAFE_INTEGER, Number.MIN_SAFE_INTEGER, { nome: 'A'.repeat(500) }),
    user(2, Number.MAX_SAFE_INTEGER),
  ] }, CLOCK);
  assertEnvelope(result);
  assert.equal(result.ranking[0].usuario_id, Number.MAX_SAFE_INTEGER);
  assert.equal(result.ranking[0].score, Number.MIN_SAFE_INTEGER);
  assert.equal(result.ranking[0].nome.length, 500);
  assert.equal(result.ranking[1].score, Number.MAX_SAFE_INTEGER);
});

test('retorna somente campos públicos e mantém a entrada imutável', () => {
  const document = {
    usuarios: [user(2, 100), user(1, 450, {
      pin_acesso: 'PIN-PRIVADO-TESTE',
      coletas_ids: ['COL-PRIVADA-TESTE'],
      detalhe_privado: { pin: 'PIN-ANINHADO-TESTE', coletas: [{ id: 'COL-ANINHADA-TESTE' }] },
      posicao: 999, destaque_top7: true, criterios: { campo: 'IGNORAR' },
    })],
    configuracao_privada: { segredo: 'CONFIG-PRIVADA-TESTE' },
    criterios: { ordenacao: 'IGNORAR' },
  };
  const before = structuredClone(document);
  freezeDeep(document);
  const result = buildRanking(document, CLOCK);
  assertEnvelope(result);
  assert.deepEqual(document, before);
  assert.deepEqual(result.ranking.map((entry) => entry.usuario_id), [2, 1]);
  const serialized = JSON.stringify(result);
  const privateMarkers = ['pin_acesso', 'coletas_ids', 'detalhe_privado', 'configuracao_privada', 'PIN-PRIVADO-TESTE', 'COL-PRIVADA-TESTE', 'PIN-ANINHADO-TESTE', 'COL-ANINHADA-TESTE', 'CONFIG-PRIVADA-TESTE'];
  assert.equal(privateMarkers.some((marker) => serialized.includes(marker)), false, 'O ranking contém informação privada');
});

test('rejeita documento ou lista de usuários inválidos', async (t) => {
  const cases = [undefined, null, [], 'texto', 42, {}, { usuarios: null }, { usuarios: {} }, { usuarios: 'texto' }];
  for (const [index, document] of cases.entries()) {
    await t.test(`estrutura inválida ${index + 1}`, () => {
      assert.throws(() => buildRanking(document, CLOCK));
    });
  }
});

test('rejeita IDs inválidos ou repetidos, nomes inválidos e scores sem valor inteiro seguro', async (t) => {
  const missingId = user(1);
  delete missingId.id;
  const missingName = user(1);
  delete missingName.nome;
  const missingScore = user(1);
  delete missingScore.score_persistente;
  const cases = [
    ['usuário nulo', [null]],
    ['usuário como lista', [[]]],
    ['usuário como texto', ['texto']],
    ['ID ausente', [missingId]],
    ['ID zerado', [user(0)]],
    ['ID negativo', [user(-1)]],
    ['ID fracionário', [user(1.5)]],
    ['ID como texto', [user('1')]],
    ['ID nulo', [user(null)]],
    ['ID não finito', [user(Infinity)]],
    ['ID NaN', [user(NaN)]],
    ['ID não seguro', [user(Number.MAX_SAFE_INTEGER + 1)]],
    ['ID repetido', [user(1, 100), user(1, 200)]],
    ['nome ausente', [missingName]],
    ['nome vazio', [user(1, 100, { nome: '' })]],
    ['nome em branco', [user(1, 100, { nome: ' \t\n ' })]],
    ['nome numérico', [user(1, 100, { nome: 42 })]],
    ['nome nulo', [user(1, 100, { nome: null })]],
    ['nome maior que 500 caracteres', [user(1, 100, { nome: 'A'.repeat(501) })]],
    ['score ausente', [missingScore]],
    ['score nulo', [user(1, null)]],
    ['score como texto', [user(1, '100')]],
    ['score fracionário', [user(1, 1.5)]],
    ['score infinito', [user(1, Infinity)]],
    ['score infinito negativo', [user(1, -Infinity)]],
    ['score NaN', [user(1, NaN)]],
    ['score positivo não seguro', [user(1, Number.MAX_SAFE_INTEGER + 1)]],
    ['score negativo não seguro', [user(1, Number.MIN_SAFE_INTEGER - 1)]],
    ['score booleano', [user(1, true)]],
  ];
  for (const [name, usuarios] of cases) {
    await t.test(name, () => {
      assert.throws(() => buildRanking({ usuarios }, CLOCK));
    });
  }
});
