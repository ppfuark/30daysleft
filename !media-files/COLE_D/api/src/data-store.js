import { EventEmitter } from "node:events";
import { readFile } from "node:fs/promises";
import { distanceMeters, interpolateRoute, normalizeText } from "./geo.js";

const VALID_SHIFTS = new Set(["manha", "tarde", "noite"]);
const VALID_WASTE_TYPES = new Set(["organico", "rejeitos", "outros"]);

function object(value, label) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new TypeError(`${label} deve ser um objeto.`);
  }
  return value;
}

function array(value, label) {
  if (!Array.isArray(value)) throw new TypeError(`${label} deve ser uma lista.`);
  return value;
}

function text(value, label) {
  if (typeof value !== "string" || value.trim().length === 0 || value.length > 500) {
    throw new TypeError(`${label} deve ser um texto não vazio com até 500 caracteres.`);
  }
  return value;
}

function positiveInteger(value, label) {
  if (!Number.isSafeInteger(value) || value < 1) {
    throw new TypeError(`${label} deve ser um inteiro positivo.`);
  }
  return value;
}

function coordinate(value, label) {
  object(value, label);
  if (typeof value.lat !== "number" || !Number.isFinite(value.lat)
    || typeof value.lng !== "number" || !Number.isFinite(value.lng)
    || value.lat < -90 || value.lat > 90 || value.lng < -180 || value.lng > 180) {
    throw new TypeError(`${label} deve conter lat entre -90 e 90 e lng entre -180 e 180.`);
  }
  return { lat: value.lat, lng: value.lng };
}

function occupancy(value, label) {
  if (typeof value !== "number" || !Number.isFinite(value) || value < 0 || value > 100) {
    throw new TypeError(`${label} deve ser um número entre 0 e 100.`);
  }
  return value;
}

function unique(values, label) {
  if (new Set(values).size !== values.length) {
    throw new TypeError(`${label} contém identificadores ou valores duplicados.`);
  }
}

function wasteTypes(value, label) {
  const result = array(value, label).map((entry, index) => {
    const type = text(entry, `${label}[${index}]`);
    if (!VALID_WASTE_TYPES.has(normalizeText(type))) {
      throw new TypeError(`${label} aceita somente Orgânico, Rejeitos e Outros.`);
    }
    return type;
  });
  unique(result.map(normalizeText), label);
  return result;
}

function parseJson(content, label) {
  try {
    // Aceita a marca UTF-8 de arquivos salvos por alguns editores Windows.
    return JSON.parse(content.replace(/^\uFEFF/u, ""));
  } catch {
    // Não inclui trechos do arquivo: a semente original também pode conter credenciais.
    throw new SyntaxError(`${label} não contém JSON válido.`);
  }
}

function validateRouting(value, label) {
  object(value, label);
  if (value.provedor !== "OSRM" || value.perfil !== "driving") {
    throw new TypeError(`${label} deve usar provedor OSRM e perfil driving.`);
  }
  const fonte = text(value.fonte, `${label}.fonte`);
  let sourceUrl;
  try {
    sourceUrl = new URL(fonte);
  } catch {
    throw new TypeError(`${label}.fonte deve ser uma URL base HTTP ou HTTPS válida.`);
  }
  if (!["http:", "https:"].includes(sourceUrl.protocol)
    || fonte !== fonte.trim() || sourceUrl.username || sourceUrl.password
    || sourceUrl.search || sourceUrl.hash) {
    throw new TypeError(`${label}.fonte deve ser uma URL base HTTP ou HTTPS sem credenciais, consulta ou fragmento.`);
  }
  for (const field of ["distancia_metros", "duracao_segundos"]) {
    if (typeof value[field] !== "number" || !Number.isFinite(value[field]) || value[field] <= 0) {
      throw new TypeError(`${label}.${field} deve ser um número finito maior que zero.`);
    }
  }
  const gerado_em = text(value.gerado_em, `${label}.gerado_em`);
  const timestampParts = /^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})(?:\.(\d+))?Z$/u.exec(gerado_em);
  const timestamp = Date.parse(gerado_em);
  const canonicalTimestamp = timestampParts
    ? `${timestampParts[1]}.${(timestampParts[2] ?? "").padEnd(3, "0").slice(0, 3)}Z` : null;
  if (!timestampParts || !Number.isFinite(timestamp)
    || new Date(timestamp).toISOString() !== canonicalTimestamp) {
    throw new TypeError(`${label}.gerado_em deve ser uma data e hora ISO válida em UTC, terminada em Z.`);
  }
  const vias = array(value.vias, `${label}.vias`)
    .map((street, index) => text(street, `${label}.vias[${index}]`));
  const waypoints = array(value.waypoints, `${label}.waypoints`).map((waypoint, index) => {
    const waypointLabel = `${label}.waypoints[${index}]`;
    object(waypoint, waypointLabel);
    if (typeof waypoint.distancia_snap_metros !== "number" || !Number.isFinite(waypoint.distancia_snap_metros)
      || waypoint.distancia_snap_metros < 0 || waypoint.distancia_snap_metros > 200) {
      throw new TypeError(`${waypointLabel}.distancia_snap_metros deve ser um número entre 0 e 200.`);
    }
    if (typeof waypoint.nome !== "string" || waypoint.nome.length > 500) {
      throw new TypeError(`${waypointLabel}.nome deve ser um texto com até 500 caracteres.`);
    }
    return {
      solicitado: coordinate(waypoint.solicitado, `${waypointLabel}.solicitado`),
      ajustado: coordinate(waypoint.ajustado, `${waypointLabel}.ajustado`),
      distancia_snap_metros: waypoint.distancia_snap_metros,
      nome: waypoint.nome,
    };
  });
  if (waypoints.length < 3) throw new TypeError(`${label}.waypoints deve conter pelo menos três pontos.`);
  if (value.licenca !== "https://www.openstreetmap.org/copyright") {
    throw new TypeError(`${label}.licenca deve apontar para https://www.openstreetmap.org/copyright.`);
  }
  return {
    provedor: "OSRM",
    perfil: "driving",
    fonte,
    distancia_metros: value.distancia_metros,
    duracao_segundos: value.duracao_segundos,
    gerado_em,
    vias,
    waypoints,
    atribuicao: text(value.atribuicao, `${label}.atribuicao`),
    licenca: value.licenca,
  };
}

function validateSeed(value) {
  object(value, "A semente");
  const caminhoes = array(value.frota_coleta_comum, "frota_coleta_comum").map((entry, index) => {
    const label = `frota_coleta_comum[${index}]`;
    object(entry, label);
    const turno = text(entry.turno, `${label}.turno`);
    if (!VALID_SHIFTS.has(normalizeText(turno))) {
      throw new TypeError(`${label}.turno deve ser Manhã, Tarde ou Noite.`);
    }
    // Lista explícita: usuarios, PINs e configurações nunca entram no estado público.
    return {
      caminhao_id: text(entry.caminhao_id, `${label}.caminhao_id`),
      motorista: text(entry.motorista, `${label}.motorista`),
      turno,
      posicao_atual: coordinate(entry.posicao_atual, `${label}.posicao_atual`),
      itinerario_ruas: array(entry.itinerario_ruas, `${label}.itinerario_ruas`)
        .map((street, streetIndex) => text(street, `${label}.itinerario_ruas[${streetIndex}]`)),
      tipos_residuo: entry.tipos_residuo === undefined
        ? [] : wasteTypes(entry.tipos_residuo, `${label}.tipos_residuo`),
    };
  });
  const pontos = array(value.pontos_coleta_seletiva, "pontos_coleta_seletiva").map((entry, index) => {
    const label = `pontos_coleta_seletiva[${index}]`;
    object(entry, label);
    return {
      id: positiveInteger(entry.id, `${label}.id`),
      logradouro: text(entry.logradouro, `${label}.logradouro`),
      material: text(entry.material, `${label}.material`),
      nivel_ocupacao: occupancy(entry.nivel_ocupacao, `${label}.nivel_ocupacao`),
      coordenadas: coordinate(entry.coordenadas, `${label}.coordenadas`),
    };
  });
  unique(caminhoes.map((truck) => truck.caminhao_id), "frota_coleta_comum");
  unique(pontos.map((point) => point.id), "pontos_coleta_seletiva");
  return { caminhoes, pontos };
}

function validateScenario(value, seed) {
  object(value, "O cenário de simulação");
  const truckIds = new Set(seed.caminhoes.map((truck) => truck.caminhao_id));
  const pointIds = new Set(seed.pontos.map((point) => point.id));
  const caminhoes = array(value.caminhoes, "simulacao.caminhoes").map((entry, index) => {
    const label = `simulacao.caminhoes[${index}]`;
    object(entry, label);
    const caminhao_id = text(entry.caminhao_id, `${label}.caminhao_id`);
    if (!truckIds.has(caminhao_id)) throw new TypeError(`${label} referencia um caminhão inexistente.`);
    if (typeof entry.velocidade_kmh !== "number" || !Number.isFinite(entry.velocidade_kmh)
      || entry.velocidade_kmh <= 0 || entry.velocidade_kmh > 130) {
      throw new TypeError(`${label}.velocidade_kmh deve ser maior que 0 e até 130.`);
    }
    const trajeto = array(entry.trajeto, `${label}.trajeto`)
      .map((point, pointIndex) => coordinate(point, `${label}.trajeto[${pointIndex}]`));
    if (trajeto.length < 2
      || !trajeto.some((point) => distanceMeters(point, trajeto[0]) > 0)) {
      throw new TypeError(`${label}.trajeto deve conter pelo menos duas coordenadas distintas.`);
    }
    const roteamento = entry.roteamento === undefined
      ? null : validateRouting(entry.roteamento, `${label}.roteamento`);
    if (roteamento) {
      const first = trajeto[0];
      const last = trajeto.at(-1);
      if (first.lat !== last.lat || first.lng !== last.lng) {
        throw new TypeError(`${label}.trajeto roteado deve retornar exatamente ao primeiro ponto pelas vias, sem fechamento implícito.`);
      }
    }
    return {
      caminhao_id,
      velocidade_kmh: entry.velocidade_kmh,
      tipos_residuo: wasteTypes(entry.tipos_residuo, `${label}.tipos_residuo`),
      trajeto,
      ...(roteamento ? { roteamento } : {}),
    };
  });
  const pontos = array(value.pontos, "simulacao.pontos").map((entry, index) => {
    const label = `simulacao.pontos[${index}]`;
    object(entry, label);
    const ponto_id = positiveInteger(entry.ponto_id, `${label}.ponto_id`);
    if (!pointIds.has(ponto_id)) throw new TypeError(`${label} referencia um ponto inexistente.`);
    const ciclo_ocupacao = array(entry.ciclo_ocupacao, `${label}.ciclo_ocupacao`)
      .map((level, levelIndex) => occupancy(level, `${label}.ciclo_ocupacao[${levelIndex}]`));
    if (ciclo_ocupacao.length < 2) {
      throw new TypeError(`${label}.ciclo_ocupacao deve conter pelo menos dois valores.`);
    }
    return { ponto_id, ciclo_ocupacao };
  });
  unique(caminhoes.map((truck) => truck.caminhao_id), "simulacao.caminhoes");
  unique(pontos.map((point) => point.ponto_id), "simulacao.pontos");
  return { caminhoes, pontos };
}

export class DataStore extends EventEmitter {
  constructor({ pontosPath, simulacaoPath, simulation = true, tickMs = 2000, watchMs = 1000 } = {}) {
    super();
    if (pontosPath === undefined) throw new TypeError("pontosPath é obrigatório.");
    if (typeof simulation !== "boolean") throw new TypeError("simulation deve ser booleano.");
    if (simulation && simulacaoPath === undefined) throw new TypeError("simulacaoPath é obrigatório na simulação.");
    for (const [label, value] of [["tickMs", tickMs], ["watchMs", watchMs]]) {
      if (!Number.isSafeInteger(value) || value < 1 || value > 2_147_483_647) {
        throw new TypeError(`${label} deve ser um inteiro positivo até 2147483647.`);
      }
    }
    this.pontosPath = pontosPath;
    this.simulacaoPath = simulacaoPath;
    this.simulation = simulation;
    this.tickMs = tickMs;
    this.watchMs = watchMs;
    this._state = null;
    this._scenario = { caminhoes: [], pontos: [] };
    this._scenarioSource = null;
    this._lastValidContent = null;
    this._pendingRead = null;
    this._startPromise = null;
    this._running = false;
    this._generation = 0;
    this._truckDistances = new Map();
    this._pointCycleIndices = new Map();
  }

  async start() {
    if (this._running) return this.getState();
    if (this._startPromise) return this._startPromise;
    const generation = ++this._generation;
    const task = this._initialize(generation);
    this._startPromise = task;
    try {
      return await task;
    } finally {
      if (this._startPromise === task) this._startPromise = null;
    }
  }

  async _initialize(generation) {
    const content = await readFile(this.pontosPath, "utf8");
    const seed = validateSeed(parseJson(content, "O arquivo de pontos"));
    let scenarioSource = null;
    let scenario = { caminhoes: [], pontos: [] };
    if (this.simulation) {
      scenarioSource = parseJson(await readFile(this.simulacaoPath, "utf8"), "O cenário de simulação");
      scenario = validateScenario(scenarioSource, seed);
    }
    if (generation !== this._generation) throw new Error("Inicialização interrompida pelo encerramento do DataStore.");
    this._scenarioSource = scenarioSource;
    this._scenario = scenario;
    this._replaceState(seed, 1);
    this._lastValidContent = content;
    this._running = true;
    if (this.simulation) {
      this._tickTimer = setInterval(() => this._tick(), this.tickMs);
    }
    this._watchTimer = setInterval(() => { void this._pollSource(); }, this.watchMs);
    return this.getState();
  }

  _replaceState(seed, revision) {
    const scenarios = new Map(this._scenario.caminhoes.map((truck) => [truck.caminhao_id, truck]));
    this._truckDistances = new Map();
    this._pointCycleIndices = new Map(this._scenario.pontos.map((point) => [point.ponto_id, 0]));
    this._state = {
      revision,
      updatedAt: new Date().toISOString(),
      simulation: this.simulation,
      caminhoes: seed.caminhoes.map((truck) => {
        const scenario = scenarios.get(truck.caminhao_id);
        const routing = scenario?.roteamento;
        let route = scenario ? structuredClone(scenario.trajeto) : [];
        // Cenários legados partem da semente. Rotas OSRM começam no ponto ajustado à via.
        if (!routing && route.length && distanceMeters(truck.posicao_atual, route[0]) > 0.001) {
          route = [structuredClone(truck.posicao_atual), ...route];
        }
        this._truckDistances.set(truck.caminhao_id, 0);
        return {
          ...truck,
          ...(routing ? {
            posicao_atual: structuredClone(route[0]),
            itinerario_ruas_cadastrado: [...truck.itinerario_ruas],
            itinerario_ruas: [...routing.vias],
            roteamento: structuredClone(routing),
          } : {}),
          tipos_residuo: truck.tipos_residuo.length
            ? [...truck.tipos_residuo] : [...(scenario?.tipos_residuo ?? [])],
          velocidade_kmh: scenario?.velocidade_kmh ?? null,
          percurso_simulado: route,
        };
      }),
      pontos: structuredClone(seed.pontos),
    };
  }

  getState() {
    if (!this._state) throw new Error("DataStore ainda não foi iniciado.");
    return structuredClone(this._state);
  }

  _tick() {
    if (!this._running || !this.simulation) return;
    for (const truck of this._state.caminhoes) {
      if (!truck.percurso_simulado.length || truck.velocidade_kmh === null) continue;
      const distance = this._truckDistances.get(truck.caminhao_id)
        + (truck.velocidade_kmh / 3.6) * (this.tickMs / 1000);
      this._truckDistances.set(truck.caminhao_id, distance);
      truck.posicao_atual = interpolateRoute(truck.percurso_simulado, distance);
    }
    const points = new Map(this._state.pontos.map((point) => [point.id, point]));
    for (const scenario of this._scenario.pontos) {
      const nextIndex = (this._pointCycleIndices.get(scenario.ponto_id) + 1) % scenario.ciclo_ocupacao.length;
      this._pointCycleIndices.set(scenario.ponto_id, nextIndex);
      points.get(scenario.ponto_id).nivel_ocupacao = scenario.ciclo_ocupacao[nextIndex];
    }
    this._state.revision += 1;
    this._state.updatedAt = new Date().toISOString();
    this.emit("update", this.getState());
  }

  _pollSource() {
    if (!this._running) return Promise.resolve();
    if (this._pendingRead) return this._pendingRead;
    const generation = this._generation;
    const task = (async () => {
      let content;
      let seed;
      let scenario;
      try {
        content = await readFile(this.pontosPath, "utf8");
        if (!this._running || generation !== this._generation || content === this._lastValidContent) return;
        seed = validateSeed(parseJson(content, "O arquivo de pontos"));
        scenario = this.simulation
          ? validateScenario(this._scenarioSource, seed) : { caminhoes: [], pontos: [] };
      } catch (error) {
        if (this._running && generation === this._generation) this.emit("sourceError", error);
        return;
      }
      if (!this._running || generation !== this._generation) return;
      this._scenario = scenario;
      this._replaceState(seed, this._state.revision + 1);
      this._lastValidContent = content;
      this.emit("update", this.getState());
    })();
    this._pendingRead = task;
    // Limpa o marcador sem criar uma segunda leitura enquanto a primeira estiver pendente.
    void task.then(
      () => { if (this._pendingRead === task) this._pendingRead = null; },
      () => { if (this._pendingRead === task) this._pendingRead = null; },
    );
    return task;
  }

  async stop() {
    this._running = false;
    this._generation += 1;
    clearInterval(this._tickTimer);
    clearInterval(this._watchTimer);
    this._tickTimer = null;
    this._watchTimer = null;
    const pending = [this._pendingRead, this._startPromise].filter(Boolean);
    await Promise.allSettled(pending);
  }
}
