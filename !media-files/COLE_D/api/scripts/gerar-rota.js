import { readFile, writeFile, rename, unlink } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { createRoadScenario } from '../src/route-generator.js';

const local = relative => fileURLToPath(new URL(relative, import.meta.url));
const pointsPath = process.env.PONTOS_PATH ? path.resolve(process.env.PONTOS_PATH) : local('../data/pontos.json');
const scenarioPath = process.env.SIMULACAO_PATH ? path.resolve(process.env.SIMULACAO_PATH) : local('../data/simulacao.json');
const parse = content => JSON.parse(content.replace(/^\uFEFF/u, ''));
let temporaryPath;
try {
  const seed = parse(await readFile(pointsPath, 'utf8'));
  const scenario = parse(await readFile(scenarioPath, 'utf8'));
  const routed = await createRoadScenario({ seed, scenario, ...(process.env.OSRM_URL ? { baseUrl: process.env.OSRM_URL } : {}) });
  temporaryPath = `${scenarioPath}.${process.pid}.tmp`;
  await writeFile(temporaryPath, `${JSON.stringify(routed, null, 2)}\n`, { encoding: 'utf8', flag: 'wx' });
  await rename(temporaryPath, scenarioPath);
  temporaryPath = null;
  for (const truck of routed.caminhoes) {
    const route = truck.roteamento;
    console.log(`${truck.caminhao_id}: ${(route.distancia_metros / 1000).toFixed(2)} km; ${truck.trajeto.length} coordenadas; vias: ${route.vias.join(', ') || 'sem nome no mapa'}.`);
    console.log(`Maior ajuste até a via: ${Math.max(...route.waypoints.map(p => p.distancia_snap_metros)).toFixed(1)} m.`);
  }
  console.log(`Cenário salvo em ${scenarioPath}. Reinicie a API para aplicar. A execução da simulação não depende de internet.`);
} catch (error) {
  if (temporaryPath) await unlink(temporaryPath).catch(() => {});
  console.error(`Falha ao gerar rota: ${error.message}. O cenário existente não foi substituído.`);
  process.exitCode = 1;
}
