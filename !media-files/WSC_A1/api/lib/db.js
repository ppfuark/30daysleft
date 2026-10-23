const fs = require('node:fs');
const path = require('node:path');
const { hashPassword } = require('./security');
const file = path.join(__dirname, '..', 'data', 'db.json');

const seed = () => ({
  modalidades: [
    { id: 1, titulo: 'Desenvolvimento de Aplicativos Móveis', resumo: 'Criação de soluções móveis modernas.', conteudo: 'A modalidade 08 avalia análise, experiência do usuário, integração de serviços e desenvolvimento de aplicativos móveis.', nomeImagem: 'mobile-apps.jpg' },
    { id: 2, titulo: 'Tecnologias Web', resumo: 'Experiências digitais para a web.', conteudo: 'Desenvolvimento front-end e back-end com foco em qualidade, desempenho e acessibilidade.', nomeImagem: 'web-tech.jpg' },
    { id: 3, titulo: 'Cibersegurança', resumo: 'Proteção de sistemas e informações.', conteudo: 'Análise, defesa e resposta a incidentes em ambientes computacionais.', nomeImagem: 'cybersecurity.jpg' },
    { id: 4, titulo: 'Robótica Móvel', resumo: 'Automação e sistemas autônomos.', conteudo: 'Projeto, programação e operação de robôs móveis em desafios industriais.', nomeImagem: 'robotics.jpg' }
  ],
  competidores: [
    { id: 1, nome: 'John Doe', email: 'john.doe@example.com', senha: hashPassword('senha123'), nascimento: '2005-01-01', avatar: null, telefone: '(11) 99999-0001', escola: 'SENAI São Paulo', modalidadeId: 1 },
    { id: 2, nome: 'Maria Silva', email: 'maria.silva@example.com', senha: hashPassword('senha123'), nascimento: '2005-06-15', avatar: null, telefone: '(11) 99999-0002', escola: 'SENAI Roberto Simonsen', modalidadeId: 2 }
  ],
  comentarios: [
    { id: 1, texto: 'Uma modalidade incrível!', modalidadeId: 1, competidorId: 2, criadoEm: '2026-08-20T12:00:00.000Z' },
    { id: 2, texto: 'Preparação para a WorldSkills!', modalidadeId: 1, competidorId: 1, criadoEm: '2026-08-21T14:30:00.000Z' }
  ],
  likes: [{ id: 1, modalidadeId: 1, competidorId: 1 }, { id: 2, modalidadeId: 1, competidorId: 2 }]
});

function ensure() { if (!fs.existsSync(file)) { fs.mkdirSync(path.dirname(file), { recursive: true }); fs.writeFileSync(file, JSON.stringify(seed(), null, 2)); } }
function read() { ensure(); return JSON.parse(fs.readFileSync(file, 'utf8')); }
function write(db) { fs.writeFileSync(file, JSON.stringify(db, null, 2)); }
function reset() { fs.mkdirSync(path.dirname(file), { recursive: true }); fs.writeFileSync(file, JSON.stringify(seed(), null, 2)); }
function nextId(list) { return list.reduce((n, x) => Math.max(n, x.id), 0) + 1; }
module.exports = { read, write, reset, nextId, file };
