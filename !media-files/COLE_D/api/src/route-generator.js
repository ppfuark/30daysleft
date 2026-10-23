import { distanceMeters } from './geo.js';

const MAX_SNAP_METERS = 200;
const DEFAULT_BASE_URL = 'https://router.project-osrm.org';

function requireValue(condition, message) {
  if (!condition) throw new Error(message);
}

function coordinate(value, label) {
  requireValue(value && Number.isFinite(value.lat) && Number.isFinite(value.lng)
    && Math.abs(value.lat) <= 90 && Math.abs(value.lng) <= 180, `${label}: coordenada inválida.`);
  return { lat: value.lat, lng: value.lng };
}

function fromGeoJson(value, label) {
  requireValue(Array.isArray(value) && value.length >= 2, `${label}: coordenada GeoJSON inválida.`);
  return coordinate({ lat: value[1], lng: value[0] }, label);
}

/** Fetch once, then persist the complete routed geometry for offline simulation. */
export async function createRoadScenario({ seed, scenario, baseUrl = DEFAULT_BASE_URL, fetchImpl = fetch, now = () => new Date() }) {
  const base = new URL(baseUrl);
  requireValue(['http:', 'https:'].includes(base.protocol) && !base.username && !base.password && !base.search && !base.hash, 'OSRM_URL deve ser uma URL HTTP(S) sem credenciais ou query string.');
  const source = base.toString().replace(/\/$/u, '');
  requireValue(source.length <= 500, 'OSRM_URL excede 500 caracteres.');
  requireValue(Array.isArray(seed?.frota_coleta_comum) && Array.isArray(seed?.pontos_coleta_seletiva), 'A fonte precisa conter frota_coleta_comum e pontos_coleta_seletiva.');
  requireValue(Array.isArray(scenario?.caminhoes) && scenario.caminhoes.length > 0, 'O cenário precisa conter pelo menos um caminhão.');
  const result = structuredClone(scenario);
  for (const truck of result.caminhoes) {
    const original = seed.frota_coleta_comum.find(entry => entry.caminhao_id === truck.caminhao_id);
    requireValue(original, `Caminhão ${truck.caminhao_id} não encontrado na fonte.`);
    const origin = coordinate(original.posicao_atual, 'Origem');
    const requested = [origin, ...seed.pontos_coleta_seletiva.map(p => coordinate(p.coordenadas, `Ponto ${p.id}`)), { ...origin }];
    requireValue(requested.length >= 3 && requested.length <= 25, 'Use entre 1 e 23 ecopontos por circuito.');
    const coordinates = requested.map(p => `${p.lng},${p.lat}`).join(';');
    const url = new URL(`${source}/route/v1/driving/${coordinates}`);
    url.search = new URLSearchParams({
      geometries: 'geojson', overview: 'full', steps: 'true', alternatives: 'false',
      continue_straight: 'true', radiuses: requested.map(() => MAX_SNAP_METERS).join(';'),
    });
    const response = await fetchImpl(url.toString(), { signal: AbortSignal.timeout(30000), headers: { Accept: 'application/json', 'User-Agent': 'Recicla-Coleta-Demo/1.0' } });
    requireValue(response.ok, `O serviço de rotas respondeu HTTP ${response.status ?? 'inválido'}. O cenário anterior foi preservado.`);
    const payload = await response.json();
    requireValue(payload?.code === 'Ok', `Não foi possível rotear o circuito: ${payload?.code ?? 'resposta inválida'}.`);
    const route = payload.routes?.[0];
    requireValue(route?.geometry?.type === 'LineString' && Array.isArray(route.geometry.coordinates)
      && route.geometry.coordinates.length >= 2 && route.geometry.coordinates.length <= 50000, 'A resposta não contém uma geometria completa válida.');
    const path = route.geometry.coordinates.map((p, index) => fromGeoJson(p, `Geometria[${index}]`));
    requireValue(path[0].lat === path.at(-1).lat && path[0].lng === path.at(-1).lng, 'A rota precisa voltar exatamente à origem pelas vias. Nenhum fechamento em linha reta será acrescentado.');
    requireValue(path.some(p => distanceMeters(path[0], p) > 0), 'A geometria precisa conter posições distintas.');
    requireValue(Number.isFinite(route.distance) && route.distance > 0 && Number.isFinite(route.duration) && route.duration > 0, 'Distância ou duração da rota inválida.');
    requireValue(Array.isArray(payload.waypoints) && payload.waypoints.length === requested.length, 'A resposta não contém todos os pontos de passagem.');
    const waypoints = payload.waypoints.map((w, index) => {
      const adjusted = fromGeoJson(w.location, `Waypoint[${index}]`);
      const actualDistance = distanceMeters(requested[index], adjusted);
      requireValue(Number.isFinite(w.distance) && w.distance >= 0 && w.distance <= MAX_SNAP_METERS
        && actualDistance <= MAX_SNAP_METERS, `Ponto ${index}: não há via roteável a até ${MAX_SNAP_METERS} metros da coordenada informada.`);
      return { solicitado: requested[index], ajustado: adjusted, distancia_snap_metros: w.distance, nome: typeof w.name === 'string' ? w.name : '' };
    });
    requireValue(distanceMeters(waypoints[0].ajustado, path[0]) <= 1
      && distanceMeters(waypoints.at(-1).ajustado, path.at(-1)) <= 1, 'Os extremos da geometria não correspondem aos pontos ajustados.');
    const names = (route.legs ?? []).flatMap(leg => (leg.steps ?? []).map(step => step.name))
      .filter(name => typeof name === 'string' && name.trim()).map(name => name.trim());
    truck.trajeto = path;
    truck.roteamento = {
      provedor: 'OSRM', perfil: 'driving', fonte: source,
      distancia_metros: route.distance, duracao_segundos: route.duration,
      gerado_em: now().toISOString(), vias: [...new Set(names)], waypoints,
      atribuicao: '© OpenStreetMap contributors', licenca: 'https://www.openstreetmap.org/copyright',
    };
  }
  result.descricao = 'Geometria viária calculada pelo OSRM sobre OpenStreetMap. Circuito demonstrativo entre a origem e os ecopontos, com retorno roteado à origem. Deslocamento a velocidade constante, categorias e ocupações continuam simulados. Perfil de automóvel; não valida restrições específicas de caminhões nem um itinerário oficial de coleta.';
  return result;
}
