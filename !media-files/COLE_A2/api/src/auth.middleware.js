'use strict';

const jwt = require('jsonwebtoken');
const SECRET = process.env.JWT_SECRET || 'coletaja_secret_2025';

function authMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Token não fornecido.' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Token inválido ou expirado.' });
  }
}

module.exports = { authMiddleware, SECRET };
