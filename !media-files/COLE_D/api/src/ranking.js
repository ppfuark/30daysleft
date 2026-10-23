/** Dados para o programador calcular o ranking, sem classificação pronta. */
export function buildRanking(document, { now = () => new Date() } = {}) {
  if (!document || !Array.isArray(document.usuarios)) {
    throw new TypeError('O documento deve conter uma lista usuarios.');
  }
  const ids = new Set();
  const entries = document.usuarios.map((user, index) => {
    if (!user || !Number.isSafeInteger(user.id) || user.id < 1 || ids.has(user.id)) {
      throw new TypeError(`usuarios[${index}].id deve ser um inteiro positivo único.`);
    }
    ids.add(user.id);
    if (typeof user.nome !== 'string' || !user.nome.trim() || user.nome.length > 500) {
      throw new TypeError(`usuarios[${index}].nome deve conter texto de até 500 caracteres.`);
    }
    // A prova prevê penalidade de -10; preserva também pontuações negativas.
    if (!Number.isSafeInteger(user.score_persistente)) {
      throw new TypeError(`usuarios[${index}].score_persistente deve ser um inteiro válido.`);
    }
    return { usuario_id: user.id, nome: user.nome.trim(), score: user.score_persistente };
  });
  const timestamp = now();
  if (!(timestamp instanceof Date) || !Number.isFinite(timestamp.getTime())) {
    throw new TypeError('A data de atualização deve ser válida.');
  }
  return {
    atualizado_em: timestamp.toISOString(),
    ranking: entries,
  };
}
