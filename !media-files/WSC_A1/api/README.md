# API WSConecta — A2 rev.2

API local da prova WorldSkills, modalidade 08. Não requer MariaDB, Docker ou configuração externa: o banco JSON é criado automaticamente em `data/db.json`.

## Requisitos e início

- Node.js 20 ou superior
- Na pasta da API, execute:

```bash
npm install
npm start
```

Servidor: `http://localhost:3000`  
Documentação: `http://localhost:3000/docs`  
OpenAPI: `http://localhost:3000/docs.json`

No emulador Android, use `http://10.0.2.2:3000` como URL-base. Em um dispositivo físico, use o IP da máquina na rede local e libere a porta 3000 no firewall.

## Credenciais

| E-mail | Senha |
|---|---|
| `john.doe@example.com` | `senha123` |
| `maria.silva@example.com` | `senha123` |

## Rotas oficiais

| Método | Rota | JWT | Finalidade |
|---|---|---:|---|
| POST | `/auth/login` | não | autenticação |
| GET | `/modalidades` | sim | feed com totais |
| GET | `/modalidades/:id` | sim | detalhe e comentários |
| GET | `/modalidades/:id/comentarios` | sim | comentários |
| POST | `/modalidades/:id/comentarios` | sim | publicar comentário |
| DELETE | `/comentarios/:id` | sim | excluir comentário próprio |
| POST | `/modalidades/:id/likes` | sim | curtir |
| DELETE | `/modalidades/:id/likes` | sim | remover curtida |
| GET | `/competidores/me` | sim | perfil autenticado |
| PUT | `/competidores/me` | sim | editar perfil |
| PUT | `/competidores/me/senha` | sim | alterar senha com hash |
| POST | `/competidores/me/avatar` | sim | upload multipart no campo `imagem` |

Envie o JWT no cabeçalho `Authorization: Bearer <token>`.

## Exemplos

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","senha":"senha123"}'
```

```bash
curl http://localhost:3000/modalidades \
  -H "Authorization: Bearer SEU_TOKEN"
```

```bash
curl -X POST http://localhost:3000/competidores/me/avatar \
  -H "Authorization: Bearer SEU_TOKEN" \
  -F "imagem=@avatar.png"
```

## Administração da prova

- `npm test`: executa o teste de fumaça completo.
- `npm run reset`: restaura os dados iniciais antes de uma nova sessão.
- `PORT=3001 npm start`: altera a porta.
- Configure `JWT_SECRET` no ambiente para mudar a chave de assinatura.
- Avatares aceitos: PNG, JPEG e WebP, até 5 MB.

O banco é persistente entre reinicializações. Para cada competidor, execute `npm run reset` antes do início da avaliação.
