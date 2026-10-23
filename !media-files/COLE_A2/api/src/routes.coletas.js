'use strict';

const express  = require('express');
const multer   = require('multer');
const path     = require('path');
const fs       = require('fs');
const { coletas } = require('./database');
const { authMiddleware } = require('./auth.middleware');

const router = express.Router();

// Configuração do multer para upload de PDF
const upload = multer({
  dest: path.join(__dirname, '../uploads/'),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'application/pdf') cb(null, true);
    else cb(new Error('Apenas arquivos PDF são aceitos.'));
  },
});

// Todas as rotas exigem autenticação
router.use(authMiddleware);

/**
 * GET /coletas
 * Query: ?situacao=agendada|concluida&tipoResiduo=papel&urgencia=true&page=1&limit=20
 */
router.get('/', (req, res) => {
  let result = [...coletas];

  if (req.query.situacao) {
    result = result.filter(c => c.situacao === req.query.situacao);
  }
  if (req.query.tipoResiduo) {
    result = result.filter(c => c.tipoResiduo === req.query.tipoResiduo);
  }
  if (req.query.urgencia !== undefined) {
    const urg = req.query.urgencia === 'true';
    result = result.filter(c => c.urgencia === urg);
  }
  if (req.query.search) {
    const q = req.query.search.toLowerCase();
    result = result.filter(c => c.nome.toLowerCase().includes(q) || c.tag.toLowerCase().includes(q));
  }

  const page  = Math.max(1, parseInt(req.query.page)  || 1);
  const limit = Math.min(50, parseInt(req.query.limit) || 20);
  const total = result.length;
  const totalPages = Math.ceil(total / limit);
  const data  = result.slice((page - 1) * limit, page * limit);

  return res.json({ data, total, page, totalPages });
});

/**
 * GET /coletas/:id
 */
router.get('/:id', (req, res) => {
  const coleta = coletas.find(c => c.id === parseInt(req.params.id));
  if (!coleta) return res.status(404).json({ error: 'NOT_FOUND', message: 'Coleta não encontrada.' });
  return res.json(coleta);
});

/**
 * POST /coletas
 */
router.post('/', (req, res) => {
  const { nome, tag, tipoResiduo, dataHoraAgendada, rota, observacoes } = req.body;
  if (!nome || !tag || !tipoResiduo || !dataHoraAgendada) {
    return res.status(400).json({ error: 'VALIDATION_ERROR', message: 'Campos obrigatórios: nome, tag, tipoResiduo, dataHoraAgendada.' });
  }
  const newId = coletas.length ? Math.max(...coletas.map(c => c.id)) + 1 : 1;
  const nova = {
    id: newId, nome, tag, tipoResiduo, dataHoraAgendada,
    foto: 'https://cdn-icons-png.flaticon.com/512/2933/2933116.png',
    situacao: 'agendada', urgencia: false,
    responsavelId: req.user.id,
    rota: rota || '', observacoes: observacoes || '',
  };
  coletas.push(nova);
  return res.status(201).json(nova);
});

/**
 * PUT /coletas/:id
 */
router.put('/:id', (req, res) => {
  const idx = coletas.findIndex(c => c.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'NOT_FOUND', message: 'Coleta não encontrada.' });
  const allowed = ['nome', 'tipoResiduo', 'dataHoraAgendada', 'situacao', 'urgencia', 'rota', 'observacoes'];
  allowed.forEach(k => { if (req.body[k] !== undefined) coletas[idx][k] = req.body[k]; });
  return res.json(coletas[idx]);
});

/**
 * PATCH /coletas/:id
 */
router.patch('/:id', (req, res) => {
  const idx = coletas.findIndex(c => c.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'NOT_FOUND', message: 'Coleta não encontrada.' });
  Object.assign(coletas[idx], req.body);
  return res.json(coletas[idx]);
});

/**
 * DELETE /coletas/:id
 */
router.delete('/:id', (req, res) => {
  const idx = coletas.findIndex(c => c.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'NOT_FOUND', message: 'Coleta não encontrada.' });
  coletas.splice(idx, 1);
  return res.status(204).send();
});

/**
 * POST /coletas/:id/upload-pdf
 * Simula upload de relatório PDF
 */
router.post('/:id/upload-pdf', upload.single('arquivo'), (req, res) => {
  const coleta = coletas.find(c => c.id === parseInt(req.params.id));
  if (!coleta) return res.status(404).json({ error: 'NOT_FOUND', message: 'Coleta não encontrada.' });

  if (!req.file) {
    return res.status(400).json({ error: 'VALIDATION_ERROR', message: 'Nenhum arquivo enviado.' });
  }

  // Simula delay de processamento e retorna sucesso
  const filePath = req.file.path;
  setTimeout(() => {
    // Remove o arquivo após "processar"
    try { fs.unlinkSync(filePath); } catch {}
    return res.json({
      success: true,
      message: 'Relatório enviado com sucesso!',
      arquivo: req.file.originalname,
      coletaId: coleta.id,
      timestamp: new Date().toISOString(),
    });
  }, 1500); // Simula 1,5 s de processamento
});

module.exports = router;
