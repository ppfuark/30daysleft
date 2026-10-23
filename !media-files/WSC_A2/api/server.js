import jsonServer from "json-server";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import fs from "fs/promises";
import path from "path";
import multer from "multer";
import cors from "cors";

const DB_FILE = path.join(process.cwd(), "db.json");
const UPLOAD_DIR = path.join(process.cwd(), "uploads");
const SWAGGER_DIR = path.join(process.cwd(), "swagger");
const JWT_SECRET = process.env.JWT_SECRET || "change_this_secret";

async function ensureUploadsDir() {
  try {
    await fs.mkdir(UPLOAD_DIR, { recursive: true });
    await fs.mkdir(SWAGGER_DIR, { recursive: true });
  } catch (e) {}
}

async function ensureHashedPasswords() {
  const text = await fs.readFile(DB_FILE, "utf8");
  const db = JSON.parse(text);

  let changed = false;

  if (Array.isArray(db.users)) {
    for (const u of db.users) {
      if (u.password && !u.password.startsWith("$2")) {
        const hash = await bcrypt.hash(u.password, 10);
        u.password = hash;
        changed = true;
      }
    }
  }

  if (Array.isArray(db.competidores)) {
    for (const c of db.competidores) {
      if (c.password && !c.password.startsWith("$2")) {
        const hash = await bcrypt.hash(c.password, 10);
        c.password = hash;
        changed = true;
      }
    }
  }

  if (changed) {
    await fs.writeFile(DB_FILE, JSON.stringify(db, null, 2), "utf8");
  }
}

await ensureUploadsDir();
await ensureHashedPasswords();

const server = jsonServer.create();
const router = jsonServer.router(DB_FILE);

// ==========================================
// MIDDLEWARES BASE
// ==========================================

server.use(cors());
server.use(jsonServer.bodyParser);

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOAD_DIR);
  },

  filename: (req, file, cb) => {
    const name = `${Date.now()}_${file.originalname}`.replace(/\s+/g, "_");

    cb(null, name);
  },
});

const upload = multer({ storage });

// ==========================================
// AUTENTICAÇÃO HEPLER
// ==========================================

function getUserFromToken(req) {
  let auth = req.headers.authorization;

  if (!auth) return null;

  // Remove "Bearer "
  auth = auth.replace(/^Bearer\s+/i, "").trim();

  if (!auth) return null;

  try {
    const payload = jwt.verify(auth, JWT_SECRET);
    return payload;
  } catch (e) {
    return null;
  }
}

// ==========================================
// ROTAS DE DOCUMENTAÇÃO (PÚBLICAS)
// ==========================================

// Swagger na raiz
server.get("/", (req, res) => {
  res.sendFile(path.join(process.cwd(), "swagger", "swagger.html"));
});

// Swagger em /docs
server.get("/docs", (req, res) => {
  res.sendFile(path.join(process.cwd(), "swagger", "swagger.html"));
});

// Especificação OpenAPI
server.get("/openapi.json", (req, res) => {
  res.sendFile(path.join(process.cwd(), "swagger", "openapi.json"));
});

// ==========================================
// LOGIN (PÚBLICO)
// ==========================================

server.post("/auth/login", (req, res) => {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return res.status(400).json({
      message: "E-mail e senha são obrigatórios",
    });
  }

  const db = router.db;

  const comp = db.get("competidores").find({ email }).value();

  if (!comp || !comp.password) {
    return res.status(401).json({
      message: "Credenciais inválidas",
    });
  }

  bcrypt
    .compare(password, comp.password)
    .then((match) => {
      if (!match) {
        return res.status(401).json({
          message: "Credenciais inválidas",
        });
      }

      const safe = { ...comp };

      delete safe.password;

      const token = jwt.sign(
        {
          competidorId: comp.id,
          email: comp.email,
          competidor: safe,
        },
        JWT_SECRET,
        {
          expiresIn: "1h",
        },
      );

      res.json({
        token,
      });
    })
    .catch((err) => {
      res.status(500).json({
        message: "Erro no servidor",
      });
    });
});

// ==========================================
// CADASTRO DE COMPETIDOR (PÚBLICO)
// ==========================================

server.post("/competidores", async (req, res) => {
  const { email, password, name, modalidadeId, escolaId, birthdate, phone } =
    req.body || {};

  if (!email || !password) {
    return res.status(400).json({
      message: "E-mail e senha são obrigatórios",
    });
  }

  const db = router.db;

  const exists = db.get("competidores").find({ email }).value();

  if (exists) {
    return res.status(409).json({
      message: "E-mail já cadastrado",
    });
  }

  const hash = await bcrypt.hash(password, 10);

  const comps = db.get("competidores").value();

  const nextId = comps.length ? Math.max(...comps.map((c) => c.id)) + 1 : 1;

  // Procura o avatar padrão
  let defaultUpload = db
    .get("uploads")
    .find({ filename: "defaultUser.jpg" })
    .value();

  if (!defaultUpload) {
    defaultUpload = db
      .get("uploads")
      .value()
      .find(
        (u) =>
          u.originalname && u.originalname.toLowerCase() === "defaultuser.jpg",
      );
  }

  // Cria registro do avatar padrão se necessário
  if (!defaultUpload) {
    const uploads = db.get("uploads").value();

    const nextU = uploads.length
      ? Math.max(...uploads.map((u) => u.id)) + 1
      : 1;

    defaultUpload = {
      id: nextU,
      filename: "defaultUser.jpg",
      originalname: "defaultUser.jpg",
      createdAt: new Date().toISOString(),
    };

    db.get("uploads").push(defaultUpload).write();
  }

  const chosenAvatarId = defaultUpload.id;

  const newComp = {
    id: nextId,
    email,
    password: hash,
    name: name || "",
    birthdate: birthdate || "",
    phone: phone || "",
    modalidadeId: modalidadeId || null,
    escolaId: escolaId || null,
    avatarId: chosenAvatarId,
  };

  db.get("competidores").push(newComp).write();

  const responseComp = {
    ...newComp,
  };

  delete responseComp.password;

  res.status(201).json(responseComp);
});

// ==========================================
// MIDDLEWARE DE AUTENTICAÇÃO (PROTEGE AS DEMAIS ROTAS)
// ==========================================

server.use((req, res, next) => {
  // Apenas documentação, login e POST /competidores são públicos
  const isOpen =
    req.path === "/" ||
    req.path === "/docs" ||
    req.path === "/openapi.json" ||
    req.path === "/swagger.html" ||
    req.path === "/auth/login" ||
    (req.path === "/competidores" && req.method === "POST");

  if (isOpen) {
    return next();
  }

  const payload = getUserFromToken(req);

  if (!payload) {
    return res.status(401).json({
      message: "Token ausente ou inválido",
    });
  }

  req.user = payload;

  next();
});

// ==========================================
// ESCOLAS (PRIVADAS)
// ==========================================

// GET todas as escolas
server.get("/escolas", (req, res) => {
  const db = router.db;

  res.json(db.get("escolas").value());
});

// GET escola por ID
server.get("/escolas/:id", (req, res) => {
  const id = Number(req.params.id);

  const db = router.db;

  const escola = db.get("escolas").find({ id }).value();

  if (!escola) {
    return res.status(404).json({
      message: "Escola não encontrada",
    });
  }

  res.json(escola);
});

// ==========================================
// CATEGORIAS (PRIVADAS)
// ==========================================

// GET todas as categorias
server.get("/categorias", (req, res) => {
  const db = router.db;

  res.json(db.get("categorias").value());
});

// GET categoria por ID
server.get("/categorias/:id", (req, res) => {
  const id = Number(req.params.id);

  const db = router.db;

  const categoria = db.get("categorias").find({ id }).value();

  if (!categoria) {
    return res.status(404).json({
      message: "Categoria não encontrada",
    });
  }

  res.json(categoria);
});

// ==========================================
// MEDALHAS (PRIVADAS)
// ==========================================

// GET todas as medalhas
server.get("/medalhas", (req, res) => {
  const db = router.db;

  res.json(db.get("medalhas").value());
});

// GET medalha por ID
server.get("/medalhas/:id", (req, res) => {
  const id = Number(req.params.id);

  const db = router.db;

  const medalha = db.get("medalhas").find({ id }).value();

  if (!medalha) {
    return res.status(404).json({
      message: "Medalha não encontrada",
    });
  }

  res.json(medalha);
});

// ==========================================
// UPLOADS (PRIVADAS)
// ==========================================

// GET arquivo por filename
server.get("/uploads/:filename", (req, res) => {
  const filename = req.params.filename;

  const filePath = path.join(UPLOAD_DIR, filename);

  res.sendFile(filePath, (err) => {
    if (err) {
      res.status(404).json({
        message: "Arquivo não encontrado",
      });
    }
  });
});

// GET arquivo por ID
server.get("/uploads/id/:id", (req, res) => {
  const id = Number(req.params.id);

  const db = router.db;

  const uploadRecord = db.get("uploads").find({ id }).value();

  if (!uploadRecord) {
    return res.status(404).json({
      message: "Upload não encontrado",
    });
  }

  const filePath = path.join(UPLOAD_DIR, uploadRecord.filename);

  res.sendFile(filePath, (err) => {
    if (err) {
      res.status(404).json({
        message: "Arquivo não encontrado",
      });
    }
  });
});

// ==========================================
// FOTO DO COMPETIDOR AUTENTICADO (PRIVADA)
// ==========================================

server.get("/competidores/me/photo", (req, res) => {
  const db = router.db;

  const comp = db
    .get("competidores")
    .find({
      id: req.user.competidorId,
    })
    .value();

  if (!comp) {
    return res.status(404).json({
      message: "Competidor não encontrado",
    });
  }

  const avatarId = comp.avatarId;

  if (!avatarId) {
    return res.status(404).json({
      message: "Avatar não definido",
    });
  }

  const uploadRecord = db
    .get("uploads")
    .find({
      id: avatarId,
    })
    .value();

  if (!uploadRecord) {
    return res.status(404).json({
      message: "Arquivo de avatar não encontrado",
    });
  }

  const filePath = path.join(UPLOAD_DIR, uploadRecord.filename);

  res.sendFile(filePath, (err) => {
    if (err) {
      res.status(404).json({
        message: "Arquivo não encontrado",
      });
    }
  });
});

// ==========================================
// MODALIDADES (PRIVADAS)
// ==========================================

// GET todas as modalidades
server.get("/modalidades", (req, res) => {
  const db = router.db;

  res.json(db.get("modalidades").value());
});

// GET modalidade por ID
server.get("/modalidades/:id", (req, res) => {
  const id = Number(req.params.id);

  const db = router.db;

  const mod = db.get("modalidades").find({ id }).value();

  if (!mod) {
    return res.status(404).json({
      message: "Modalidade não encontrada",
    });
  }

  res.json(mod);
});

// ==========================================
// COMENTÁRIOS (PRIVADAS)
// ==========================================

// POST comentário
server.post("/modalidades/:id/comentarios", (req, res) => {
  const modalidadeId = Number(req.params.id);

  const { content } = req.body || {};

  if (!content || content.trim() === "" || content.length > 500) {
    return res.status(400).json({
      message: "Comentário inválido",
    });
  }

  const db = router.db;

  const comments = db.get("comentarios").value();

  const nextId = comments.length
    ? Math.max(...comments.map((c) => c.id)) + 1
    : 1;

  const comment = {
    id: nextId,
    modalidadeId,
    authorId: req.user.competidorId,
    content,
    createdAt: new Date().toISOString(),
  };

  db.get("comentarios").push(comment).write();

  res.status(201).json(comment);
});

// GET comentários por modalidade
server.get("/modalidades/:id/comentarios", (req, res) => {
  const modalidadeId = Number(req.params.id);

  const db = router.db;

  const comments = db.get("comentarios").filter({ modalidadeId }).value();

  res.json(comments);
});

// GET todos comentários
server.get("/comentarios", (req, res) => {
  const db = router.db;

  const comments = db.get("comentarios").value();

  res.json(comments);
});

// DELETE comentário
server.delete("/comentarios/:id", (req, res) => {
  const id = Number(req.params.id);

  const db = router.db;

  const comment = db.get("comentarios").find({ id }).value();

  if (!comment) {
    return res.status(404).json({
      message: "Comentário não encontrado",
    });
  }

  if (comment.authorId !== req.user.competidorId) {
    return res.status(403).json({
      message: "Somente o autor pode excluir",
    });
  }

  db.get("comentarios").remove({ id }).write();

  res.status(200).json({
    message: "Comentário excluído com sucesso",
  });
});

// ==========================================
// CURTIDAS (PRIVADAS)
// ==========================================

// POST curtida
server.post("/modalidades/:id/curtidas", (req, res) => {
  const modalidadeId = Number(req.params.id);

  const db = router.db;

  const existing = db
    .get("likes")
    .find({
      modalidadeId,
      competidorId: req.user.competidorId,
    })
    .value();

  if (existing) {
    return res.status(409).json({
      message: "Já curtiu",
    });
  }

  const likes = db.get("likes").value();

  const nextId = likes.length ? Math.max(...likes.map((l) => l.id)) + 1 : 1;

  const like = {
    id: nextId,
    modalidadeId,
    competidorId: req.user.competidorId,
    createdAt: new Date().toISOString(),
  };

  db.get("likes").push(like).write();

  res.status(201).json(like);
});

// DELETE curtida
server.delete("/modalidades/:id/curtidas", (req, res) => {
  const modalidadeId = Number(req.params.id);

  const db = router.db;

  const existing = db
    .get("likes")
    .find({
      modalidadeId,
      competidorId: req.user.competidorId,
    })
    .value();

  if (!existing) {
    return res.status(404).json({
      message: "Curtida não encontrada",
    });
  }

  db.get("likes")
    .remove({
      id: existing.id,
    })
    .write();

  res.status(200).json({
    message: "Curtida removida com sucesso",
  });
});

// GET curtidas por modalidade
server.get("/modalidades/:id/curtidas", (req, res) => {
  const modalidadeId = Number(req.params.id);

  const db = router.db;

  const likes = db.get("likes").filter({ modalidadeId }).value();

  res.json(likes);
});

// GET todas as curtidas
server.get("/curtidas", (req, res) => {
  const db = router.db;

  const likes = db.get("likes").value();

  res.json(likes);
});

// ==========================================
// COMPETIDORES (PRIVADAS, EXCETO POST)
// ==========================================

// GET competidor autenticado
server.get("/competidores/me", (req, res) => {
  const db = router.db;

  const comp = db
    .get("competidores")
    .find({
      id: req.user.competidorId,
    })
    .value();

  if (!comp) {
    return res.status(404).json({
      message: "Competidor não encontrado",
    });
  }

  const safe = {
    ...comp,
  };

  delete safe.password;

  res.json(safe);
});

// GET todos competidores
server.get("/competidores", (req, res) => {
  const db = router.db;

  const comps = db
    .get("competidores")
    .value()
    .map((c) => {
      const copy = {
        ...c,
      };

      delete copy.password;

      return copy;
    });

  res.json(comps);
});

// GET competidor por ID
server.get("/competidores/:id", (req, res) => {
  const id = Number(req.params.id);

  const db = router.db;

  const comp = db.get("competidores").find({ id }).value();

  if (!comp) {
    return res.status(404).json({
      message: "Competidor não encontrado",
    });
  }

  const copy = {
    ...comp,
  };

  delete copy.password;

  res.json(copy);
});

// PATCH competidor autenticado
server.patch("/competidores/me", (req, res) => {
  const db = router.db;

  const comp = db
    .get("competidores")
    .find({
      id: req.user.competidorId,
    })
    .value();

  if (!comp) {
    return res.status(404).json({
      message: "Competidor não encontrado",
    });
  }

  const updates = req.body || {};

  // password NÃO pode ser alterado aqui
  const allowed = [
    "name",
    "birthdate",
    "phone",
    "modalidadeId",
    "escolaId",
    "avatarId",
    "email",
  ];

  const patch = {};

  for (const key of allowed) {
    if (key in updates) {
      patch[key] = updates[key];
    }
  }

  db.get("competidores")
    .find({
      id: req.user.competidorId,
    })
    .assign(patch)
    .write();

  const updated = db
    .get("competidores")
    .find({
      id: req.user.competidorId,
    })
    .value();

  const { password, ...responseBody } = updated;

  res.json(responseBody);
});

// ==========================================
// UPLOAD DE AVATAR DO COMPETIDOR
// ==========================================

server.post("/competidores/me/avatar", upload.single("image"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      message: "Arquivo não enviado",
    });
  }

  const db = router.db;

  const comp = db
    .get("competidores")
    .find({
      id: req.user.competidorId,
    })
    .value();

  if (!comp) {
    return res.status(404).json({
      message: "Competidor não encontrado",
    });
  }

  const uploads = db.get("uploads").value();

  const nextId = uploads.length ? Math.max(...uploads.map((u) => u.id)) + 1 : 1;

  const record = {
    id: nextId,
    filename: req.file.filename,
    originalname: req.file.originalname,
    createdAt: new Date().toISOString(),
  };

  db.get("uploads").push(record).write();

  db.get("competidores")
    .find({
      id: req.user.competidorId,
    })
    .assign({
      avatarId: record.id,
    })
    .write();

  res.json(record);
});

// ==========================================
// UPLOAD DE IMAGEM DA MODALIDADE
// ==========================================

server.post("/modalidades/:id/image", upload.single("image"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      message: "Arquivo não enviado",
    });
  }

  const modalidadeId = Number(req.params.id);

  const db = router.db;

  const mod = db
    .get("modalidades")
    .find({
      id: modalidadeId,
    })
    .value();

  if (!mod) {
    return res.status(404).json({
      message: "Modalidade não encontrada",
    });
  }

  const uploads = db.get("uploads").value();

  const nextId = uploads.length ? Math.max(...uploads.map((u) => u.id)) + 1 : 1;

  const record = {
    id: nextId,
    filename: req.file.filename,
    originalname: req.file.originalname,
    createdAt: new Date().toISOString(),
  };

  db.get("uploads").push(record).write();

  db.get("modalidades")
    .find({
      id: modalidadeId,
    })
    .assign({
      imageId: record.id,
    })
    .write();

  res.status(201).json(record);
});

// ==========================================
// JSON SERVER ROUTER
// ==========================================

server.use(router);

// ==========================================
// INICIAR SERVIDOR
// ==========================================

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`JSON Server running with auth on port ${PORT}`);

  console.log(`Swagger: http://localhost:${PORT}/`);
});
