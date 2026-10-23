# API WSConecta (json-server)

This project provides a mock API based on the PDF specification. It uses `json-server` with custom middleware for JWT authentication, password hashing and media uploads.

How to install

```bash
pnpm install
# or
npm install
```

Start server

```bash
npm start
```

Default port: `3000`

Important routes

- `POST /competidores` - criar competidor / registro (body: `email`, `password`, `name`, `modalidadeId`, `escolaId`)
- `POST /auth/login` - login (body: `email`, `password`) -> returns `{ token }` (uses `competidores`)
- `GET /modalidades` - list modalidades (requires Bearer token)
- `GET /modalidades/:id` - modalidade detail (requires token)
- `POST /modalidades/:id/comentarios` - add comment (body: `content`)
- `DELETE /comentarios/:id` - delete own comment
- `POST /modalidades/:id/likes` - add like
- `DELETE /modalidades/:id/likes` - remove like
- `GET|PUT /competidores/me` - get/update profile
- `POST /competidores/me/avatar` - upload avatar (multipart `image`)
Note: todas as rotas, exceto `POST /auth/login`, exigem autenticação via `Authorization: Bearer <token>`.

- `GET /escolas` - listar escolas (requer token)
- `POST /escolas` - criar escola (requer token)
- `GET /docs` - Swagger UI estático (requer token)

Notes

- Passwords are hashed on first server start if stored plaintext in `db.json`.
- Uploaded files are stored in `./uploads` and their filenames are saved to `db.json` in `uploads` and in `competidores.avatar`.
- Seeded credentials: `john.doe@example.com` / `senha123` (this password will be hashed on first run).

If you want to pre-populate media files, place them into `uploads/` and set the `modalidades.image` or `competidores.avatar` fields to the filename. Files are served via `/uploads/:filename` and require authentication.
# api_a2_wsconecta