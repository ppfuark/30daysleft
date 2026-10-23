'use strict';

const bcrypt = require('bcryptjs');

// ─── Usuários ────────────────────────────────────────────────
const users = [
  {
    id: 1,
    name: 'Admin Coleta Já',
    email: 'admin@coletaja.com.br',
    password: bcrypt.hashSync('Admin@123', 10),
    role: 'gestor',
  },
  {
    id: 2,
    name: 'Operador Teste',
    email: 'operador@coletaja.com.br',
    password: bcrypt.hashSync('Op@12345', 10),
    role: 'operador',
  },
];

// ─── Colaboradores ───────────────────────────────────────────
const colaboradores = [
  {
    id: 1,
    nome: 'Carlos Eduardo Silva',
    cargo: 'Coletor de Resíduos',
    nivel: 'operador',
    status: 'ativo',
    avatar: 'https://i.pravatar.cc/150?img=11',
    dataCadastro: '2022-03-15',
    rotasAtribuidas: ['Rota Centro', 'Rota Norte'],
  },
  {
    id: 2,
    nome: 'Mariana Costa Souza',
    cargo: 'Supervisora de Rotas',
    nivel: 'supervisor',
    status: 'ativo',
    avatar: 'https://i.pravatar.cc/150?img=47',
    dataCadastro: '2021-07-20',
    rotasAtribuidas: ['Rota Sul', 'Rota Leste'],
  },
  {
    id: 3,
    nome: 'João Pedro Almeida',
    cargo: 'Gestor Operacional',
    nivel: 'gestor',
    status: 'ativo',
    avatar: 'https://i.pravatar.cc/150?img=68',
    dataCadastro: '2020-01-10',
    rotasAtribuidas: ['Todas as Rotas'],
  },
  {
    id: 4,
    nome: 'Fernanda Lima Ramos',
    cargo: 'Coletora',
    nivel: 'operador',
    status: 'afastado',
    avatar: 'https://i.pravatar.cc/150?img=32',
    dataCadastro: '2023-05-02',
    rotasAtribuidas: ['Rota Oeste'],
  },
  {
    id: 5,
    nome: 'Roberto Nunes Barros',
    cargo: 'Auxiliar de Coleta',
    nivel: 'operador',
    status: 'inativo',
    avatar: 'https://i.pravatar.cc/150?img=53',
    dataCadastro: '2022-11-18',
    rotasAtribuidas: [],
  },
  {
    id: 6,
    nome: 'Patricia Vieira Santos',
    cargo: 'Supervisora',
    nivel: 'supervisor',
    status: 'ativo',
    avatar: 'https://i.pravatar.cc/150?img=25',
    dataCadastro: '2021-09-30',
    rotasAtribuidas: ['Rota Centro', 'Rota Sul'],
  },
];

// ─── Coletas ─────────────────────────────────────────────────
const now = new Date();
const future = (h) => new Date(now.getTime() + h * 3600000).toISOString();
const past   = (h) => new Date(now.getTime() - h * 3600000).toISOString();

const coletas = [
  {
    id: 1,
    nome: 'Coleta Centro — Manhã',
    tag: 'CCT-001',
    tipoResiduo: 'papel',
    dataHoraAgendada: future(2),
    foto: 'https://cdn-icons-png.flaticon.com/512/2933/2933116.png',
    situacao: 'agendada',
    urgencia: false,
    responsavelId: 1,
    rota: 'Rota Centro',
    observacoes: 'Recolher papelão das bancas do mercado municipal.',
  },
  {
    id: 2,
    nome: 'Coleta Norte — Plástico',
    tag: 'CNT-002',
    tipoResiduo: 'plastico',
    dataHoraAgendada: future(5),
    foto: 'https://cdn-icons-png.flaticon.com/512/3082/3082048.png',
    situacao: 'agendada',
    urgencia: false,
    responsavelId: 2,
    rota: 'Rota Norte',
    observacoes: 'Incluir garrafas PET das escolas municipais.',
  },
  {
    id: 3,
    nome: 'Coleta Sul — Orgânico',
    tag: 'CSL-003',
    tipoResiduo: 'organico',
    dataHoraAgendada: past(1),
    foto: 'https://cdn-icons-png.flaticon.com/512/2917/2917995.png',
    situacao: 'concluida',
    urgencia: false,
    responsavelId: 1,
    rota: 'Rota Sul',
    observacoes: 'Coleta de restos de feira livre.',
  },
  {
    id: 4,
    nome: 'Coleta Leste — Metal',
    tag: 'CLE-004',
    tipoResiduo: 'metal',
    dataHoraAgendada: future(8),
    foto: 'https://cdn-icons-png.flaticon.com/512/5726/5726532.png',
    situacao: 'agendada',
    urgencia: true,
    responsavelId: 6,
    rota: 'Rota Leste',
    observacoes: 'Recolher latões e sucatas do distrito industrial.',
  },
  {
    id: 5,
    nome: 'Coleta Oeste — Vidro',
    tag: 'COT-005',
    tipoResiduo: 'vidro',
    dataHoraAgendada: past(3),
    foto: 'https://cdn-icons-png.flaticon.com/512/3082/3082044.png',
    situacao: 'concluida',
    urgencia: false,
    responsavelId: 4,
    rota: 'Rota Oeste',
    observacoes: 'Coleta de garrafas e vidros de bares da região.',
  },
  {
    id: 6,
    nome: 'Coleta Centro — Eletrônico',
    tag: 'CCT-006',
    tipoResiduo: 'eletronico',
    dataHoraAgendada: future(24),
    foto: 'https://cdn-icons-png.flaticon.com/512/2933/2933116.png',
    situacao: 'agendada',
    urgencia: false,
    responsavelId: 3,
    rota: 'Rota Centro',
    observacoes: 'Ponto de coleta no shopping — pilhas e baterias.',
  },
];

// ─── Dashboard ───────────────────────────────────────────────
const dashboardData = {
  semana: {
    totalColetas: 28,
    totalKg: 1240,
    colaboradoresAtivos: 4,
    cumprimentoRotas: 89,
    porTipoResiduo: [
      { tipo: 'Orgânico',   percentual: 35, total: 12 },
      { tipo: 'Papel',      percentual: 22, total: 8  },
      { tipo: 'Plástico',   percentual: 18, total: 6  },
      { tipo: 'Metal',      percentual: 14, total: 5  },
      { tipo: 'Vidro',      percentual: 11, total: 4  },
    ],
    porColaborador: [
      { nome: 'Carlos Eduardo',  total: 9  },
      { nome: 'Mariana Costa',   total: 8  },
      { nome: 'Patricia Vieira', total: 7  },
      { nome: 'João Pedro',      total: 4  },
    ],
    evolucaoSemanal: [
      { semana: 'Sem 1', kg: 180 },
      { semana: 'Sem 2', kg: 210 },
      { semana: 'Sem 3', kg: 195 },
      { semana: 'Sem 4', kg: 240 },
    ],
  },
  mes: {
    totalColetas: 112,
    totalKg: 5320,
    colaboradoresAtivos: 4,
    cumprimentoRotas: 92,
    porTipoResiduo: [
      { tipo: 'Orgânico',   percentual: 33, total: 48 },
      { tipo: 'Papel',      percentual: 24, total: 35 },
      { tipo: 'Plástico',   percentual: 19, total: 27 },
      { tipo: 'Metal',      percentual: 15, total: 21 },
      { tipo: 'Vidro',      percentual:  9, total: 13 },
    ],
    porColaborador: [
      { nome: 'Carlos Eduardo',  total: 36 },
      { nome: 'Mariana Costa',   total: 32 },
      { nome: 'Patricia Vieira', total: 28 },
      { nome: 'João Pedro',      total: 16 },
    ],
    evolucaoSemanal: [
      { semana: 'Sem 1', kg: 1200 },
      { semana: 'Sem 2', kg: 1380 },
      { semana: 'Sem 3', kg: 1310 },
      { semana: 'Sem 4', kg: 1430 },
    ],
  },
  trimestre: {
    totalColetas: 342,
    totalKg: 16450,
    colaboradoresAtivos: 5,
    cumprimentoRotas: 87,
    porTipoResiduo: [
      { tipo: 'Orgânico',   percentual: 32, total: 148 },
      { tipo: 'Papel',      percentual: 25, total: 115 },
      { tipo: 'Plástico',   percentual: 20, total:  91 },
      { tipo: 'Metal',      percentual: 14, total:  64 },
      { tipo: 'Vidro',      percentual:  9, total:  41 },
    ],
    porColaborador: [
      { nome: 'Carlos Eduardo',  total: 110 },
      { nome: 'Mariana Costa',   total:  98 },
      { nome: 'Patricia Vieira', total:  87 },
      { nome: 'João Pedro',      total:  47 },
    ],
    evolucaoSemanal: [
      { semana: 'Jan S1', kg: 1800 },
      { semana: 'Jan S2', kg: 1950 },
      { semana: 'Fev S1', kg: 2100 },
      { semana: 'Fev S2', kg: 2080 },
      { semana: 'Mar S1', kg: 2200 },
      { semana: 'Mar S2', kg: 2320 },
    ],
  },
};

module.exports = { users, colaboradores, coletas, dashboardData };
