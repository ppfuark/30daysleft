const app = require('../server');
const { reset } = require('../lib/db');
const assert = require('node:assert/strict');

async function run() {
  reset();
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  try {
    let r = await fetch(`${base}/health`); assert.equal(r.status, 200);
    r = await fetch(`${base}/auth/login`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ email: 'john.doe@example.com', senha: 'senha123' }) });
    assert.equal(r.status, 200); const login = await r.json(); assert.ok(login.token); const headers = { authorization: `Bearer ${login.token}`, 'content-type': 'application/json' };
    r = await fetch(`${base}/modalidades`, { headers }); assert.equal(r.status, 200); const mods = await r.json(); assert.equal(mods.length, 4); assert.equal(mods[0].totalLikes, 2);
    r = await fetch(`${base}/modalidades/1/comentarios`, { method: 'POST', headers, body: JSON.stringify({ texto: 'Teste automatizado' }) }); assert.equal(r.status, 201); const comment = await r.json();
    r = await fetch(`${base}/comentarios/${comment.id}`, { method: 'DELETE', headers }); assert.equal(r.status, 204);
    r = await fetch(`${base}/modalidades/2/likes`, { method: 'POST', headers }); assert.equal(r.status, 201);
    r = await fetch(`${base}/modalidades/2/likes`, { method: 'DELETE', headers }); assert.equal(r.status, 204);
    r = await fetch(`${base}/competidores/me`, { headers }); assert.equal(r.status, 200); const me = await r.json(); assert.equal(me.email, 'john.doe@example.com'); assert.equal(me.senha, undefined);
    r = await fetch(`${base}/competidores/me`, { method: 'PUT', headers, body: JSON.stringify({ telefone: '(11) 98888-7777' }) }); assert.equal(r.status, 200);
    r = await fetch(`${base}/docs.json`); assert.equal(r.status, 200);
    console.log('OK: health, login/JWT, feed, comentários, likes, perfil e OpenAPI.');
  } finally { server.close(); reset(); }
}
run().catch(e => { console.error(e); process.exitCode = 1; });
