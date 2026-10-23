const url = process.argv[2] ?? 'ws://127.0.0.1:8080/ws';
const socket = new WebSocket(url);
socket.addEventListener('open', () => {
  socket.send(JSON.stringify({ type: 'subscribe', requestId: 'tela3', topic: 'coleta_comum', filters: { turno: 'Tarde' }, location: { lat: -22.1085, lng: -50.1742 }, notifyArrival: true }));
  socket.send(JSON.stringify({ type: 'subscribe', requestId: 'tela4', topic: 'coleta_seletiva', filters: { material: 'Plástico' }, location: { lat: -22.1085, lng: -50.1742 } }));
});
socket.addEventListener('message', event => console.log(JSON.stringify(JSON.parse(event.data), null, 2)));
socket.addEventListener('error', () => { console.error(`Não foi possível conectar a ${url}. Inicie a API com npm start.`); process.exitCode = 1; });
socket.addEventListener('close', event => console.log(`Conexão encerrada (${event.code}).`));
process.on('SIGINT', () => socket.close());
