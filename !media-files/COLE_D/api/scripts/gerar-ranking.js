import { readFile, writeFile, rename, unlink, mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { buildRanking } from '../src/ranking.js';

const usersPath = process.env.USUARIOS_PATH
  ? path.resolve(process.env.USUARIOS_PATH)
  : fileURLToPath(new URL('../../JSON/usuarios.json', import.meta.url));
const rankingPath = process.env.RANKING_PATH
  ? path.resolve(process.env.RANKING_PATH)
  : path.join(path.dirname(usersPath), 'ranking.json');
let temporaryPath;
try {
  const normalizePath = value => process.platform === 'win32' ? value.toLowerCase() : value;
  if (normalizePath(usersPath) === normalizePath(rankingPath)) throw new Error('O ranking deve ser salvo em arquivo diferente de usuarios.json.');
  if (path.extname(rankingPath).toLowerCase() !== '.json') throw new Error('RANKING_PATH deve apontar para um arquivo .json.');
  const users = JSON.parse((await readFile(usersPath, 'utf8')).replace(/^\uFEFF/u, ''));
  const ranking = buildRanking(users);
  const content = `${JSON.stringify(ranking, null, 2)}\n`;
  await mkdir(path.dirname(rankingPath), { recursive: true });
  const candidatePath = `${rankingPath}.${process.pid}.${Date.now()}.tmp`;
  await writeFile(candidatePath, content, { encoding: 'utf8', flag: 'wx' });
  temporaryPath = candidatePath;
  await rename(temporaryPath, rankingPath);
  temporaryPath = null;
  console.log(`Dados para ranking salvos em ${rankingPath}: ${ranking.ranking.length} usuários, sem posição ou destaque calculados.`);
} catch (error) {
  if (temporaryPath) await unlink(temporaryPath).catch(() => {});
  console.error(`Falha ao gerar ranking: ${error.message}`);
  process.exitCode = 1;
}
