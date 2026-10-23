import http from 'node:http';
import { fileURLToPath } from 'node:url';
import { WebSocket, WebSocketServer } from 'ws';
import { DataStore } from './data-store.js';
import { TOPICS, ProtocolError, validateCommand, snapshot, arrivalAlerts } from './protocol.js';

const DEFAULT_POINTS = fileURLToPath(new URL('../data/pontos.json', import.meta.url));
const DEFAULT_SIMULATION = fileURLToPath(new URL('../data/simulacao.json', import.meta.url));

export async function createApp(options = {}) {
  const { port = 8080, host = '127.0.0.1', heartbeatMs = 30000, logger = console } = options;
  const store = new DataStore({ pontosPath: DEFAULT_POINTS, simulacaoPath: DEFAULT_SIMULATION, ...options });
  await store.start();
  const sessions = new Map();
  const server = http.createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.setHeader('Cache-Control', 'no-store');
    if (req.method === 'GET' && req.url === '/health') {
      const state = store.getState();
      res.end(JSON.stringify({ status: 'ok', service: 'recicla-coleta-websocket', protocol: '1.0', simulation: state.simulation, revision: state.revision, updatedAt: state.updatedAt, clients: sessions.size }));
    } else {
      res.writeHead(404);
      res.end(JSON.stringify({ error: 'NOT_FOUND', message: 'Saúde: GET /health. WebSocket: /ws.' }));
    }
  });
  const wss = new WebSocketServer({ noServer: true, maxPayload: 16 * 1024, perMessageDeflate: false });
  const send = (ws, message) => {
    if (ws.readyState !== WebSocket.OPEN) return;
    if (ws.bufferedAmount > 1024 * 1024) return ws.terminate();
    ws.send(JSON.stringify(message), error => { if (error) ws.terminate(); });
  };
  const publish = (ws, sub, state, type, requestId) => {
    send(ws, snapshot(state, sub, type, requestId));
    for (const alert of arrivalAlerts(state, sub)) send(ws, alert);
  };
  const onUpdate = state => {
    for (const [ws, session] of sessions) {
      for (const sub of session.subscriptions.values()) publish(ws, sub, state, 'update');
    }
  };
  const onSourceError = error => logger.warn(`Falha ao reler pontos.json; último estado válido mantido: ${error.message}`);
  store.on('update', onUpdate);
  store.on('sourceError', onSourceError);

  server.on('upgrade', (request, socket, head) => {
    if (request.url !== '/ws') {
      socket.end('HTTP/1.1 404 Not Found\r\nConnection: close\r\nContent-Length: 0\r\n\r\n');
      return;
    }
    wss.handleUpgrade(request, socket, head, ws => wss.emit('connection', ws, request));
  });
  wss.on('connection', ws => {
    const session = { subscriptions: new Map(), alive: true, windowAt: Date.now(), messages: 0 };
    sessions.set(ws, session);
    ws.on('pong', () => { session.alive = true; });
    ws.on('error', () => { ws.terminate(); });
    ws.on('close', () => { sessions.delete(ws); });
    send(ws, { type: 'connected', protocol: '1.0', topics: TOPICS, timestamp: new Date().toISOString(), heartbeat_seconds: heartbeatMs / 1000 });
    ws.on('message', (bytes, isBinary) => {
      let requestId;
      try {
        if (Date.now() - session.windowAt > 1000) { session.windowAt = Date.now(); session.messages = 0; }
        if (++session.messages > 60) return ws.close(1008, 'Limite de mensagens excedido');
        if (isBinary) throw new ProtocolError('Envie mensagens JSON de texto.');
        let message;
        try { message = JSON.parse(bytes.toString('utf8')); }
        catch { throw new ProtocolError('JSON inválido.'); }
        if (message && typeof message.requestId === 'string' && message.requestId.length <= 100) requestId = message.requestId;
        const command = validateCommand(message);
        if (command.type === 'ping') send(ws, { type: 'pong', requestId, timestamp: new Date().toISOString() });
        else if (command.type === 'unsubscribe') {
          session.subscriptions.delete(command.topic);
          send(ws, { type: 'unsubscribed', requestId, topic: command.topic });
        } else {
          // Changing a filter or location replaces only this topic's subscription.
          // Keep notification memory when only location/filters are refreshed.
          const previous = session.subscriptions.get(command.topic);
          if (previous?.notifyArrival && command.notifyArrival) command.alerted = previous.alerted;
          session.subscriptions.set(command.topic, command);
          publish(ws, command, store.getState(), 'snapshot', requestId);
        }
      } catch (error) {
        if (!(error instanceof ProtocolError)) logger.error(error);
        send(ws, { type: 'error', requestId, code: error instanceof ProtocolError ? error.code : 'INTERNAL_ERROR', message: error instanceof ProtocolError ? error.message : 'Não foi possível processar a mensagem.' });
      }
    });
  });
  const heartbeat = setInterval(() => {
    for (const [ws, session] of sessions) {
      if (!session.alive) { ws.terminate(); continue; }
      session.alive = false;
      if (ws.readyState === WebSocket.OPEN) ws.ping();
    }
  }, heartbeatMs);
  heartbeat.unref();
  try {
    await new Promise((resolve, reject) => {
      const onError = error => reject(error);
      server.once('error', onError);
      server.listen(port, host, () => { server.off('error', onError); resolve(); });
    });
  } catch (error) {
    clearInterval(heartbeat);
    store.off('update', onUpdate);
    store.off('sourceError', onSourceError);
    await store.stop();
    wss.close();
    throw error;
  }
  const address = server.address();
  let closed = false;
  return {
    server, wss, store,
    url: `ws://${host.includes(':') ? `[${host}]` : host}:${address.port}/ws`,
    async close() {
      if (closed) return;
      closed = true;
      clearInterval(heartbeat);
      store.off('update', onUpdate);
      store.off('sourceError', onSourceError);
      await store.stop();
      for (const ws of wss.clients) ws.terminate();
      await Promise.all([
        new Promise(resolve => wss.close(resolve)),
        new Promise(resolve => { server.close(resolve); server.closeAllConnections(); }),
      ]);
    },
  };
}
