'use strict';

const express  = require('express');
const jwt      = require('jsonwebtoken');
const bcrypt   = require('bcryptjs');
const { users } = require('./database');
const { SECRET } = require('./auth.middleware');

const router = express.Router();

/**
 * POST /auth/login
 * Body: { email, password }
 * Response: { token, expiresIn, user }
 */
router.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'VALIDATION_ERROR', message: 'E-mail e senha são obrigatórios.' });
  }

  const user = users.find(u => u.email === email);
  if (!user) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'E-mail ou senha incorretos.' });
  }

  const valid = bcrypt.compareSync(password, user.password);
  if (!valid) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'E-mail ou senha incorretos.' });
  }

  const expiresIn = 3600; // 1 hora
  const token = jwt.sign(
    { id: user.id, name: user.name, email: user.email, role: user.role },
    SECRET,
    { expiresIn }
  );

  return res.status(200).json({
    token,
    expiresIn,
    user: { id: user.id, name: user.name, email: user.email, role: user.role },
  });
});

/**
 * POST /auth/refresh
 * Header: Authorization: Bearer <token>
 * Response: { token, expiresIn }
 */
router.post('/refresh', (req, res) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Token não fornecido.' });
  }
  const oldToken = authHeader.split(' ')[1];
  try {
    // Permite renovar mesmo se expirado recentemente (ignoreExpiration)
    const decoded = jwt.verify(oldToken, SECRET, { ignoreExpiration: true });
    const expiresIn = 3600;
    const token = jwt.sign(
      { id: decoded.id, name: decoded.name, email: decoded.email, role: decoded.role },
      SECRET,
      { expiresIn }
    );
    return res.status(200).json({ token, expiresIn });
  } catch {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Token inválido.' });
  }
});

module.exports = router;
