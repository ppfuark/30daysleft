const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('node:path');
const fs = require('node:fs');
const { read, write, nextId } = require('./lib/db');
const { verifyPassword, hashPassword, signToken, verifyToken } = require('./lib/security');

const app = express();
const PORT = Number(process.env.PORT || 3000);
const SECRET = process.env.JWT_SECRET || 'wsconecta-rev2-chave-local';
const TTL = Number(process.env.TOKEN_TTL_SECONDS || 14400);
const uploadDir = path.join(__dirname, 'uploads'); fs.mkdirSync(uploadDir, { recursive: true });
const upload = multer({ storage: multer.diskStorage({ destination: uploadDir, filename: (_r, f, cb) => cb(null, `${Date.now()}-${f.originalname.replace(/[^a-zA-Z0-9._-]/g, '_')}`) }), limits: { fileSize: 5 * 1024 * 1024 }, fileFilter: (_r, f, cb) => cb(null, /^image\/(png|jpe?g|webp)$/.test(f.mimetype)) });

app.use(cors()); app.use(express.json({ limit: '1mb' })); app.use('/uploads', express.static(uploadDir));
const cleanUser = u => { const { senha, ...safe } = u; return safe; };
const intId = value => Number.isInteger(Number(value)) && Number(value) > 0 ? Number(value) : null;
const fail = (res, status, mensagem, detalhes) => res.status(status).json({ erro: status, mensagem, ...(detalhes ? { detalhes } : {}) });

function auth(req, res, next) {
  try { const [type, token] = String(req.headers.authorization || '').split(' '); if (type !== 'Bearer' || !token) return fail(res, 401, 'Token de acesso ausente.'); req.user = verifyToken(token, SECRET); next(); }
  catch (e) { return fail(res, 401, e.message === 'Token expirado' ? 'Sessão expirada.' : 'Token de acesso inválido.'); }
}
function modalityView(db, m, userId) {
  const likes = db.likes.filter(x => x.modalidadeId === m.id);
  const comments = db.comentarios.filter(x => x.modalidadeId === m.id);
  return { ...m, totalLikes: likes.length, totalComentarios: comments.length, curtidoPorMim: userId ? likes.some(x => x.competidorId === userId) : false };
}

app.get('/', (_q, r) => r.json({ nome: 'API WSConecta', versao: '2.0.0', status: 'online', docs: '/docs' }));
app.get('/health', (_q, r) => r.json({ status: 'ok', timestamp: new Date().toISOString() }));
app.post('/auth/login', (req, res) => {
  const { email, senha } = req.body || {}; if (!email || !senha) return fail(res, 400, 'E-mail e senha são obrigatórios.');
  const user = read().competidores.find(x => x.email.toLowerCase() === String(email).trim().toLowerCase());
  if (!user || !verifyPassword(senha, user.senha)) return fail(res, 401, 'Credenciais inválidas.');
  res.json({ token: signToken({ sub: user.id, email: user.email, nome: user.nome }, SECRET, TTL), expiresIn: TTL, competidor: cleanUser(user) });
});

app.get('/modalidades', auth, (req, res) => { const db = read(); res.json(db.modalidades.map(m => modalityView(db, m, req.user.sub))); });
app.get('/modalidades/:id', auth, (req, res) => { const db = read(), id = intId(req.params.id), m = db.modalidades.find(x => x.id === id); if (!m) return fail(res, 404, 'Modalidade não encontrada.'); const comentarios = db.comentarios.filter(x => x.modalidadeId === id).map(c => ({ ...c, competidor: cleanUser(db.competidores.find(u => u.id === c.competidorId)) })); res.json({ ...modalityView(db, m, req.user.sub), comentarios }); });

app.get('/modalidades/:id/comentarios', auth, (req, res) => { const db = read(), id = intId(req.params.id); if (!db.modalidades.some(x => x.id === id)) return fail(res, 404, 'Modalidade não encontrada.'); res.json(db.comentarios.filter(x => x.modalidadeId === id).map(c => ({ ...c, competidor: cleanUser(db.competidores.find(u => u.id === c.competidorId)) }))); });
app.post('/modalidades/:id/comentarios', auth, (req, res) => { const db = read(), id = intId(req.params.id), texto = String(req.body?.texto || '').trim(); if (!db.modalidades.some(x => x.id === id)) return fail(res, 404, 'Modalidade não encontrada.'); if (!texto || texto.length > 500) return fail(res, 422, 'O comentário deve ter entre 1 e 500 caracteres.'); const item = { id: nextId(db.comentarios), texto, modalidadeId: id, competidorId: req.user.sub, criadoEm: new Date().toISOString() }; db.comentarios.push(item); write(db); res.status(201).json(item); });
app.delete('/comentarios/:id', auth, (req, res) => { const db = read(), id = intId(req.params.id), i = db.comentarios.findIndex(x => x.id === id); if (i < 0) return fail(res, 404, 'Comentário não encontrado.'); if (db.comentarios[i].competidorId !== req.user.sub) return fail(res, 403, 'Você só pode excluir seu próprio comentário.'); db.comentarios.splice(i, 1); write(db); res.status(204).end(); });

app.post('/modalidades/:id/likes', auth, (req, res) => { const db = read(), id = intId(req.params.id); if (!db.modalidades.some(x => x.id === id)) return fail(res, 404, 'Modalidade não encontrada.'); if (db.likes.some(x => x.modalidadeId === id && x.competidorId === req.user.sub)) return fail(res, 409, 'Modalidade já curtida pelo usuário.'); const item = { id: nextId(db.likes), modalidadeId: id, competidorId: req.user.sub }; db.likes.push(item); write(db); res.status(201).json({ ...item, totalLikes: db.likes.filter(x => x.modalidadeId === id).length }); });
app.delete('/modalidades/:id/likes', auth, (req, res) => { const db = read(), id = intId(req.params.id), i = db.likes.findIndex(x => x.modalidadeId === id && x.competidorId === req.user.sub); if (i < 0) return fail(res, 404, 'Curtida não encontrada para o usuário.'); db.likes.splice(i, 1); write(db); res.status(204).end(); });

app.get('/competidores/me', auth, (req, res) => { const user = read().competidores.find(x => x.id === req.user.sub); if (!user) return fail(res, 404, 'Competidor não encontrado.'); res.json(cleanUser(user)); });
app.put('/competidores/me', auth, (req, res) => { const db = read(), i = db.competidores.findIndex(x => x.id === req.user.sub); if (i < 0) return fail(res, 404, 'Competidor não encontrado.'); const allowed = ['nome','email','nascimento','telefone','escola','modalidadeId']; const patch = {}; for (const k of allowed) if (req.body?.[k] !== undefined) patch[k] = req.body[k]; if (!String(patch.nome ?? db.competidores[i].nome).trim()) return fail(res, 422, 'Nome é obrigatório.'); const email = String(patch.email ?? db.competidores[i].email).trim().toLowerCase(); if (!/^\S+@\S+\.\S+$/.test(email)) return fail(res, 422, 'E-mail inválido.'); if (db.competidores.some((x,n) => n !== i && x.email.toLowerCase() === email)) return fail(res, 409, 'E-mail já cadastrado.'); if (patch.modalidadeId !== undefined && !db.modalidades.some(x => x.id === Number(patch.modalidadeId))) return fail(res, 422, 'Modalidade inválida.'); db.competidores[i] = { ...db.competidores[i], ...patch, email, modalidadeId: Number(patch.modalidadeId ?? db.competidores[i].modalidadeId) }; write(db); res.json(cleanUser(db.competidores[i])); });
app.put('/competidores/me/senha', auth, (req, res) => { const { senhaAtual, novaSenha } = req.body || {}, db = read(), user = db.competidores.find(x => x.id === req.user.sub); if (!user || !verifyPassword(senhaAtual, user.senha)) return fail(res, 401, 'Senha atual inválida.'); if (String(novaSenha || '').length < 6) return fail(res, 422, 'A nova senha deve ter pelo menos 6 caracteres.'); user.senha = hashPassword(novaSenha); write(db); res.status(204).end(); });
app.post('/competidores/me/avatar', auth, upload.single('imagem'), (req, res) => { if (!req.file) return fail(res, 422, 'Envie uma imagem PNG, JPEG ou WebP no campo imagem.'); const db = read(), user = db.competidores.find(x => x.id === req.user.sub); if (!user) return fail(res, 404, 'Competidor não encontrado.'); user.avatar = `/uploads/${req.file.filename}`; write(db); res.status(201).json({ avatar: user.avatar }); });

const spec = { openapi: '3.0.3', info: { title: 'API WSConecta', version: '2.0.0', description: 'API oficial da prova A2 rev.2.' }, servers: [{ url: `http://localhost:${PORT}` }], components: { securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' } } }, paths: { '/auth/login': { post: { summary: 'Autenticar', responses: { 200: { description: 'JWT emitido' }, 401: { description: 'Credenciais inválidas' } } } }, '/modalidades': { get: { summary: 'Listar modalidades', security: [{ bearerAuth: [] }], responses: { 200: { description: 'Lista com totais' } } } }, '/modalidades/{id}': { get: { summary: 'Detalhar modalidade', security: [{ bearerAuth: [] }], responses: { 200: { description: 'Detalhe com comentários' } } } }, '/modalidades/{id}/comentarios': { get: { summary: 'Listar comentários', security: [{ bearerAuth: [] }], responses: { 200: { description: 'Lista' } } }, post: { summary: 'Criar comentário', security: [{ bearerAuth: [] }], responses: { 201: { description: 'Criado' } } } }, '/comentarios/{id}': { delete: { summary: 'Excluir comentário próprio', security: [{ bearerAuth: [] }], responses: { 204: { description: 'Excluído' } } } }, '/modalidades/{id}/likes': { post: { summary: 'Curtir', security: [{ bearerAuth: [] }], responses: { 201: { description: 'Criada' } } }, delete: { summary: 'Remover curtida', security: [{ bearerAuth: [] }], responses: { 204: { description: 'Removida' } } } }, '/competidores/me': { get: { summary: 'Obter perfil', security: [{ bearerAuth: [] }], responses: { 200: { description: 'Perfil' } } }, put: { summary: 'Editar perfil', security: [{ bearerAuth: [] }], responses: { 200: { description: 'Atualizado' } } } }, '/competidores/me/avatar': { post: { summary: 'Enviar avatar multipart', security: [{ bearerAuth: [] }], responses: { 201: { description: 'Enviado' } } } } } };
app.get('/docs.json', (_q, r) => r.json(spec));
app.get('/docs', (_q, r) => r.type('html').send(`<!doctype html><html lang="pt-br"><meta charset="utf-8"><title>API WSConecta</title><style>body{font:16px Arial;max-width:900px;margin:40px auto;color:#20242a}code{background:#eee;padding:3px}li{margin:9px}</style><h1>API WSConecta 2.0</h1><p>Especificação OpenAPI: <a href="/docs.json">/docs.json</a></p><p>Login: <code>john.doe@example.com</code> / <code>senha123</code></p><h2>Fluxo</h2><ol><li>POST /auth/login</li><li>Copie o token retornado</li><li>Envie <code>Authorization: Bearer TOKEN</code></li></ol><p>Consulte o README para todos os exemplos.</p></html>`));
app.use((err, _req, res, _next) => { console.error(err); if (err instanceof multer.MulterError) return fail(res, 422, err.code === 'LIMIT_FILE_SIZE' ? 'Imagem excede 5 MB.' : 'Falha no upload.'); return fail(res, 500, 'Erro interno do servidor.'); });

if (require.main === module) app.listen(PORT, '0.0.0.0', () => console.log(`API WSConecta: http://localhost:${PORT} | docs: /docs`));
module.exports = app;
