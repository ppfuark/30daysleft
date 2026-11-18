import path from 'node:path';
import { createApp } from './server.js';

function integer(name, fallback, minimum, maximum) {
  if (process.env[name] === undefined) return fallback;
  const raw = process.env[name];
  const value = /^\d+$/.test(raw) ? Number(raw) : NaN;
  if (!Number.isSafeInteger(value) || value < minimum || value > maximum) throw new Error(`${name} deve estar entre ${minimum} e ${maximum}.`);
  return value;
}

try {
  const simulation = process.env.SIMULATION ?? 'true';
  if (!['true', 'false'].includes(simulation)) throw new Error('SIMULATION deve ser true ou false.');
  const app = await createApp({
    host: process.env.HOST ?? '0.0.0.0',
    port: integer('PORT', 8080, 1, 65535),
    tickMs: integer('TICK_MS', 2000, 100, 60000),
    watchMs: integer('WATCH_MS', 1000, 100, 60000),
    simulation: simulation === 'true',
    ...(process.env.PONTOS_PATH ? { pontosPath: path.resolve(process.env.PONTOS_PATH) } : {}),
    ...(process.env.SIMULACAO_PATH ? { simulacaoPath: path.resolve(process.env.SIMULACAO_PATH) } : {}),
  });
  console.log(`API Recicla+ em ${app.url}`);
  console.log(`Modo: ${simulation === 'true' ? 'simulação em arquivo' : 'atualizações do JSON'}. Saúde: http://${process.env.HOST ?? '0.0.0.0'}:${app.server.address().port}/health`);
  let stopping = false;
  const shutdown = async () => {
    if (stopping) return;
    stopping = true;
    await app.close();
  };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
} catch (error) {
  console.error(`Falha ao iniciar: ${error.message}`);
  process.exitCode = 1;
}
