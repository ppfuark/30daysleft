'use strict';

const express = require('express');
const { dashboardData } = require('./database');
const { authMiddleware } = require('./auth.middleware');

const router = express.Router();
router.use(authMiddleware);

/**
 * GET /dashboard
 * Query: ?periodo=semana|mes|trimestre  (default: semana)
 */
router.get('/', (req, res) => {
  const periodo = req.query.periodo || 'semana';
  const data = dashboardData[periodo];

  if (!data) {
    return res.status(400).json({
      error: 'VALIDATION_ERROR',
      message: 'Período inválido. Use: semana, mes ou trimestre.',
    });
  }

  // Simula delay leve de rede
  setTimeout(() => {
    return res.json({
      periodo,
      kpis: {
        totalColetas: data.totalColetas,
        totalKg: data.totalKg,
        colaboradoresAtivos: data.colaboradoresAtivos,
        cumprimentoRotas: data.cumprimentoRotas,
      },
      graficos: {
        rosca: data.porTipoResiduo,
        barras: data.porColaborador,
        linha: data.evolucaoSemanal,
      },
    });
  }, 300);
});

module.exports = router;
