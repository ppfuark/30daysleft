'use strict';

const express = require('express');
const { colaboradores } = require('./database');
const { authMiddleware } = require('./auth.middleware');

const router = express.Router();
router.use(authMiddleware);

const NIVEIS = ['operador', 'supervisor', 'gestor'];

/**
 * GET /colaboradores
 * Query: ?status=ativo|inativo|afastado&nivel=operador|supervisor|gestor&search=nome
 */
router.get('/', (req, res) => {
  let result = [...colaboradores];

  if (req.query.status) result = result.filter(c => c.status === req.query.status);
  if (req.query.nivel)  result = result.filter(c => c.nivel  === req.query.nivel);
  if (req.query.search) {
    const q = req.query.search.toLowerCase();
    result = result.filter(c => c.nome.toLowerCase().includes(q) || c.cargo.toLowerCase().includes(q));
  }

  return res.json({ data: result, total: result.length });
});

/**
 * GET /colaboradores/:id
 */
router.get('/:id', (req, res) => {
  const col = colaboradores.find(c => c.id === parseInt(req.params.id));
  if (!col) return res.status(404).json({ error: 'NOT_FOUND', message: 'Colaborador não encontrado.' });
  return res.json(col);
});

/**
 * POST /colaboradores
 */
router.post('/', (req, res) => {
  const { nome, cargo, nivel, status } = req.body;
  if (!nome || !cargo) {
    return res.status(400).json({ error: 'VALIDATION_ERROR', message: 'Campos obrigatórios: nome, cargo.' });
  }
  const newId = colaboradores.length ? Math.max(...colaboradores.map(c => c.id)) + 1 : 1;
  const novo = {
    id: newId, nome, cargo,
    nivel: nivel || 'operador',
    status: status || 'ativo',
    avatar: `https://i.pravatar.cc/150?img=${newId + 10}`,
    dataCadastro: new Date().toISOString().split('T')[0],
    rotasAtribuidas: [],
  };
  colaboradores.push(novo);
  return res.status(201).json(novo);
});

/**
 * PATCH /colaboradores/:id
 * Atualiza campos parcialmente (nível, status, etc.)
 */
router.patch('/:id', (req, res) => {
  const idx = colaboradores.findIndex(c => c.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'NOT_FOUND', message: 'Colaborador não encontrado.' });

  const allowed = ['nome', 'cargo', 'nivel', 'status', 'rotasAtribuidas'];
  allowed.forEach(k => { if (req.body[k] !== undefined) colaboradores[idx][k] = req.body[k]; });

  return res.json(colaboradores[idx]);
});

/**
 * POST /colaboradores/:id/promover
 * Promove automaticamente para o próximo nível
 */
router.post('/:id/promover', (req, res) => {
  const idx = colaboradores.findIndex(c => c.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'NOT_FOUND', message: 'Colaborador não encontrado.' });

  const atual = colaboradores[idx].nivel;
  const idxNivel = NIVEIS.indexOf(atual);

  if (idxNivel === NIVEIS.length - 1) {
    return res.status(422).json({
      error: 'MAX_NIVEL',
      message: `${colaboradores[idx].nome} já possui o nível máximo (Gestor).`,
    });
  }

  const proximo = NIVEIS[idxNivel + 1];
  colaboradores[idx].nivel = proximo;

  return res.json({
    message: `${colaboradores[idx].nome} promovido(a) para ${proximo}!`,
    colaborador: colaboradores[idx],
  });
});

/**
 * DELETE /colaboradores/:id
 */
router.delete('/:id', (req, res) => {
  const idx = colaboradores.findIndex(c => c.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'NOT_FOUND', message: 'Colaborador não encontrado.' });
  colaboradores.splice(idx, 1);
  return res.status(204).send();
});

module.exports = router;
