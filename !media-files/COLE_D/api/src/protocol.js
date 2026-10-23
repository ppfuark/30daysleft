import { normalizeText, distanceMeters } from './geo.js';

export const TOPICS = ['coleta_comum', 'coleta_seletiva'];
const SHIFTS = ['Manhã', 'Tarde', 'Noite'];
const WASTE = ['Orgânico', 'Rejeitos', 'Outros'];
const MATERIALS = ['Metal', 'Plástico', 'Papel', 'Vidro'];
const NO_TRUCK = 'Nenhum caminhão em rota para este endereço';
const record = value => value !== null && typeof value === 'object' && !Array.isArray(value);

export class ProtocolError extends Error {
  constructor(message, code = 'INVALID_MESSAGE') {
    super(message);
    this.code = code;
  }
}

function assert(condition, message) {
  if (!condition) throw new ProtocolError(message);
}

function textField(value, name) {
  assert(typeof value === 'string' && value.length <= 200, `${name} deve ser um texto com até 200 caracteres.`);
  return value.trim();
}

function enumField(value, allowed, name) {
  const text = textField(value, name);
  const match = allowed.find(item => normalizeText(item) === normalizeText(text));
  assert(match, `${name} deve ser um de: ${allowed.join(', ')}.`);
  return match;
}

export function validateCommand(message) {
  assert(record(message), 'Envie um objeto JSON.');
  if (message.requestId !== undefined) {
    assert(typeof message.requestId === 'string' && message.requestId.length <= 100, 'requestId deve ser texto com até 100 caracteres.');
  }
  assert(['subscribe', 'unsubscribe', 'ping'].includes(message.type), 'Comando permitido: subscribe, unsubscribe ou ping.');
  if (message.type === 'ping') return { type: 'ping', requestId: message.requestId };
  assert(TOPICS.includes(message.topic), 'Tópico permitido: coleta_comum ou coleta_seletiva.');
  if (message.type === 'unsubscribe') return { type: message.type, topic: message.topic, requestId: message.requestId };
  const filters = message.filters ?? {};
  assert(record(filters), 'filters deve ser um objeto.');
  const allowed = message.topic === 'coleta_comum' ? ['logradouro', 'turno', 'tipo_residuo'] : ['material', 'busca'];
  assert(Object.keys(filters).every(key => allowed.includes(key)), 'Filtro desconhecido para este tópico.');
  const validated = {};
  for (const [key, value] of Object.entries(filters)) {
    if (key === 'turno') validated[key] = enumField(value, SHIFTS, key);
    else if (key === 'tipo_residuo') validated[key] = enumField(value, WASTE, key);
    else if (key === 'material') validated[key] = enumField(value, MATERIALS, key);
    else validated[key] = textField(value, key);
  }
  let location = null;
  if (message.location !== undefined && message.location !== null) {
    const p = message.location;
    assert(record(p) && Number.isFinite(p.lat) && Number.isFinite(p.lng) && Math.abs(p.lat) <= 90 && Math.abs(p.lng) <= 180, 'location deve conter lat e lng numéricos válidos.');
    location = { lat: p.lat, lng: p.lng };
  }
  assert(message.notifyArrival === undefined || typeof message.notifyArrival === 'boolean', 'notifyArrival deve ser booleano.');
  assert(message.topic === 'coleta_comum' || !message.notifyArrival, 'Notificação de chegada pertence à coleta_comum.');
  assert(!message.notifyArrival || location, 'Informe location para ativar notifyArrival.');
  return { type: 'subscribe', requestId: message.requestId, topic: message.topic, filters: validated, location, notifyArrival: message.notifyArrival ?? false, alerted: new Set() };
}

function matches(text, filter) {
  return !filter || normalizeText(text).includes(normalizeText(filter));
}

export function topicData(state, subscription) {
  const { filters: f, location } = subscription;
  if (subscription.topic === 'coleta_comum') {
    const caminhoes = state.caminhoes
      .filter(c => c.itinerario_ruas.some(street => matches(street, f.logradouro)) || !f.logradouro)
      .filter(c => !f.turno || normalizeText(c.turno) === normalizeText(f.turno))
      .filter(c => !f.tipo_residuo || c.tipos_residuo.some(t => normalizeText(t) === normalizeText(f.tipo_residuo)))
      .map(c => {
        const distance = location ? distanceMeters(location, c.posicao_atual) : null;
        // A straight-line estimate is not a prediction based on street traffic or timetables.
        const eta = state.simulation && distance !== null && c.velocidade_kmh > 0
          ? new Date(Date.parse(state.updatedAt) + distance / (c.velocidade_kmh / 3.6) * 1000).toISOString() : null;
        return { ...c, distancia_metros: distance === null ? null : Math.round(distance), previsao_chegada: eta, previsao_simulada: eta !== null };
      });
    return { caminhoes, mensagem: caminhoes.length ? null : NO_TRUCK };
  }
  const pontos = state.pontos
    .filter(p => !f.material || normalizeText(p.material) === normalizeText(f.material))
    .filter(p => matches(p.logradouro, f.busca) || (f.busca && matches(`Ponto de coleta - ${p.id}`, f.busca)))
    .map(p => ({ ...p, ocupacao_critica: p.nivel_ocupacao > 90, distancia_metros: location ? Math.round(distanceMeters(location, p.coordenadas)) : null }));
  const nearest = location && pontos.length
    ? pontos.reduce((best, p) => distanceMeters(location, p.coordenadas) < distanceMeters(location, best.coordenadas) ? p : best) : null;
  return {
    pontos,
    ponto_mais_proximo: nearest,
    destino_rota: nearest ? { ponto_id: nearest.id, origem: location, destino: nearest.coordenadas } : null,
  };
}

export function snapshot(state, subscription, type = 'update', requestId) {
  return { type, ...(requestId === undefined ? {} : { requestId }), topic: subscription.topic, revision: state.revision, timestamp: state.updatedAt, simulation: state.simulation, data: topicData(state, subscription) };
}

export function arrivalAlerts(state, subscription) {
  if (!subscription.notifyArrival || !subscription.location || subscription.topic !== 'coleta_comum') return [];
  const trucks = topicData(state, subscription).caminhoes;
  // Keep already-notified trucks remembered even when a filter hides them.
  // Only physically leaving the radius (or leaving the source) rearms an alert.
  const stillNear = new Set(state.caminhoes
    .filter(c => distanceMeters(subscription.location, c.posicao_atual) < 200)
    .map(c => c.caminhao_id));
  const remembered = new Set([...subscription.alerted].filter(id => stillNear.has(id)));
  const alerts = [];
  for (const c of trucks) {
    const exact = distanceMeters(subscription.location, c.posicao_atual);
    if (exact < 200) {
      if (!subscription.alerted.has(c.caminhao_id)) {
        alerts.push({ type: 'arrival_alert', topic: 'coleta_comum', timestamp: state.updatedAt, data: { caminhao_id: c.caminhao_id, distancia_metros: Math.round(exact), limite_metros: 200 } });
      }
      remembered.add(c.caminhao_id);
    }
  }
  subscription.alerted = remembered;
  return alerts;
}
