'use strict';

const express = require('express');
const cors    = require('cors');
const path    = require('path');
const fs      = require('fs');

const authRoutes          = require('./src/routes.auth');
const coletasRoutes       = require('./src/routes.coletas');
const colaboradoresRoutes = require('./src/routes.colaboradores');
const dashboardRoutes     = require('./src/routes.dashboard');

const app  = express();
const PORT = process.env.PORT || 8080;

// ─── Middlewares globais ──────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Garante que a pasta de uploads existe
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });

// ─── Log simples de requisições ──────────────────────────────
app.use((req, res, next) => {
  const ts = new Date().toISOString();
  console.log(`[${ts}]  ${req.method.padEnd(7)} ${req.path}`);
  next();
});

// ─── Rotas ───────────────────────────────────────────────────
app.use('/api/v1/auth',          authRoutes);
app.use('/api/v1/coletas',       coletasRoutes);
app.use('/api/v1/colaboradores', colaboradoresRoutes);
app.use('/api/v1/dashboard',     dashboardRoutes);

// ─── Health check ────────────────────────────────────────────
app.get('/api/v1/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Coleta Já API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// ─── Rota raiz com resumo dos endpoints ──────────────────────
app.get('/', (req, res) => {
  res.json({
    name: 'Coleta Já API',
    version: '1.0.0',
    baseUrl: `/api/v1`,
    endpoints: {
      auth: {
        'POST /api/v1/auth/login':   'Login com e-mail e senha → JWT',
        'POST /api/v1/auth/refresh': 'Renovar token JWT',
      },
      coletas: {
        'GET    /api/v1/coletas':               'Listar coletas (filtros: situacao, tipoResiduo, urgencia, search, page, limit)',
        'GET    /api/v1/coletas/:id':           'Detalhe de uma coleta',
        'POST   /api/v1/coletas':               'Criar coleta',
        'PUT    /api/v1/coletas/:id':           'Atualizar coleta completa',
        'PATCH  /api/v1/coletas/:id':           'Atualizar campos da coleta',
        'DELETE /api/v1/coletas/:id':           'Excluir coleta',
        'POST   /api/v1/coletas/:id/upload-pdf':'Enviar PDF de relatório (multipart/form-data, campo: arquivo)',
      },
      colaboradores: {
        'GET    /api/v1/colaboradores':              'Listar colaboradores (filtros: status, nivel, search)',
        'GET    /api/v1/colaboradores/:id':          'Detalhe de um colaborador',
        'POST   /api/v1/colaboradores':              'Criar colaborador',
        'PATCH  /api/v1/colaboradores/:id':          'Atualizar colaborador',
        'POST   /api/v1/colaboradores/:id/promover': 'Promover ao próximo nível',
        'DELETE /api/v1/colaboradores/:id':          'Excluir colaborador',
      },
      dashboard: {
        'GET /api/v1/dashboard': 'Dados do dashboard (query: ?periodo=semana|mes|trimestre)',
      },
    },
    credenciaisDemo: {
      gestor:   { email: 'admin@coletaja.com.br',    password: 'Admin@123' },
      operador: { email: 'operador@coletaja.com.br', password: 'Op@12345'  },
    },
  });
});

// ─── Erros 404 ───────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: 'NOT_FOUND', message: `Rota não encontrada: ${req.method} ${req.path}` });
});

// ─── Erros globais ───────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('[ERROR]', err.message);
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: 'FILE_TOO_LARGE', message: 'Arquivo excede o limite de 10 MB.' });
  }
  if (err.message && err.message.includes('PDF')) {
    return res.status(400).json({ error: 'INVALID_FILE_TYPE', message: err.message });
  }
  res.status(500).json({ error: 'SERVER_ERROR', message: 'Erro interno do servidor.' });
});

// ─── Start ───────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('╔══════════════════════════════════════════════╗');
  console.log('║        COLETA JÁ — API REST v1.0.0          ║');
  console.log('╠══════════════════════════════════════════════╣');
  console.log(`║  Rodando em: http://0.0.0.0:${PORT}             ║`);
  console.log('║  Docs:       GET /                           ║');
  console.log('║  Health:     GET /api/v1/health              ║');
  console.log('╠══════════════════════════════════════════════╣');
  console.log('║  Credenciais de teste:                       ║');
  console.log('║  admin@coletaja.com.br   / Admin@123         ║');
  console.log('║  operador@coletaja.com.br / Op@12345         ║');
  console.log('╚══════════════════════════════════════════════╝');
  console.log('');
});

module.exports = app;
