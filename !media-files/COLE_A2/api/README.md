# Coleta Já — API REST v1.0.0

API de suporte para a Prova Prática WorldSkills Brasil 2025 — Modalidade #08.

## Instalação e Execução

```bash
# Instalar dependências
npm install

# Iniciar o servidor
npm start
# ou
node server.js
```

O servidor iniciará em `http://0.0.0.0:8080`.

---

## Base URL

```
http://<IP_DA_MAQUINA>:8080/api/v1
```

> Para descobrir o IP da máquina: `ipconfig` (Windows) ou `ip addr` / `ifconfig` (Linux/Mac).

---

## Credenciais de Teste

| Role      | E-mail                        | Senha      |
|-----------|-------------------------------|------------|
| Gestor    | admin@coletaja.com.br         | Admin@123  |
| Operador  | operador@coletaja.com.br      | Op@12345   |

---

## Endpoints

### Autenticação

#### `POST /api/v1/auth/login`
```json
// Request
{ "email": "admin@coletaja.com.br", "password": "Admin@123" }

// Response 200
{
  "token": "eyJ...",
  "expiresIn": 3600,
  "user": { "id": 1, "name": "Admin Coleta Já", "email": "...", "role": "gestor" }
}
```

#### `POST /api/v1/auth/refresh`
```
Header: Authorization: Bearer <token>
Response 200: { "token": "...", "expiresIn": 3600 }
```

---

### Coletas (todas exigem Authorization header)

| Método | Endpoint                          | Descrição                        |
|--------|-----------------------------------|----------------------------------|
| GET    | `/api/v1/coletas`                 | Listar coletas                   |
| GET    | `/api/v1/coletas/:id`             | Detalhe de uma coleta            |
| POST   | `/api/v1/coletas`                 | Criar coleta                     |
| PUT    | `/api/v1/coletas/:id`             | Atualizar coleta (completo)      |
| PATCH  | `/api/v1/coletas/:id`             | Atualizar campos da coleta       |
| DELETE | `/api/v1/coletas/:id`             | Excluir coleta                   |
| POST   | `/api/v1/coletas/:id/upload-pdf`  | Enviar PDF de relatório          |

**Filtros GET /coletas:**
- `?situacao=agendada|concluida`
- `?tipoResiduo=organico|papel|plastico|metal|vidro|eletronico`
- `?urgencia=true|false`
- `?search=texto`
- `?page=1&limit=20`

**Upload de PDF:**
- Método: `multipart/form-data`
- Campo do arquivo: `arquivo`
- Simula 1,5 s de processamento antes de retornar sucesso

---

### Colaboradores (todas exigem Authorization header)

| Método | Endpoint                                 | Descrição                  |
|--------|------------------------------------------|----------------------------|
| GET    | `/api/v1/colaboradores`                  | Listar colaboradores       |
| GET    | `/api/v1/colaboradores/:id`              | Detalhe de um colaborador  |
| POST   | `/api/v1/colaboradores`                  | Criar colaborador          |
| PATCH  | `/api/v1/colaboradores/:id`              | Atualizar colaborador      |
| POST   | `/api/v1/colaboradores/:id/promover`     | Promover ao próximo nível  |
| DELETE | `/api/v1/colaboradores/:id`              | Excluir colaborador        |

**Hierarquia de níveis:** `operador → supervisor → gestor`

---

### Dashboard (exige Authorization header)

#### `GET /api/v1/dashboard?periodo=semana`
Parâmetros: `periodo = semana | mes | trimestre` (padrão: `semana`)

```json
// Response 200
{
  "periodo": "semana",
  "kpis": {
    "totalColetas": 28,
    "totalKg": 1240,
    "colaboradoresAtivos": 4,
    "cumprimentoRotas": 89
  },
  "graficos": {
    "rosca":  [{ "tipo": "Orgânico", "percentual": 35, "total": 12 }, ...],
    "barras": [{ "nome": "Carlos Eduardo", "total": 9 }, ...],
    "linha":  [{ "semana": "Sem 1", "kg": 180 }, ...]
  }
}
```

---

## Códigos de Erro

| HTTP | Código interno    | Significado                              |
|------|-------------------|------------------------------------------|
| 400  | VALIDATION_ERROR  | Dados inválidos no corpo da requisição   |
| 401  | UNAUTHORIZED      | Token ausente, inválido ou expirado      |
| 404  | NOT_FOUND         | Recurso não encontrado                   |
| 413  | FILE_TOO_LARGE    | Arquivo excede 10 MB                     |
| 422  | MAX_NIVEL         | Colaborador já está no nível máximo      |
| 500  | SERVER_ERROR      | Erro interno do servidor                 |

---

## Observações para o Competidor

- A API roda em memória — os dados são **resetados** a cada reinicialização.
- Todos os endpoints (exceto `/auth/login` e `/`) exigem o header `Authorization: Bearer <token>`.
- O token JWT expira em **1 hora** — use `POST /auth/refresh` para renovar sem novo login.
- O upload de PDF simula 1,5 s de delay proposital para testar a barra de progresso.
