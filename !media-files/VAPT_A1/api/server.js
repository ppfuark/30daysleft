const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const ROOT = __dirname;
const DB = process.env.DB_FILE || path.join(ROOT, 'data/db.json');
const SECRET = process.env.JWT_SECRET || crypto.randomBytes(48).toString('hex');
const steps = ['Preparando', 'Saiu para Entrega', 'Entregue'];
function seed() {
  const d = JSON.parse(fs.readFileSync(path.join(ROOT, 'data/seed.json'), 'utf8').replace(/^\uFEFF/, ''));
  d.products.push({id:301, restaurantId:1, category:'Entradas', name:'Batata Frita', description:'Porção de 100g', price:10.5, image:'batata.png'});
  for (const p of d.products) p.image = p.id === 301 ? 'batata.png' : p.category === 'Bebidas' ? 'image.png' : p.category === 'Pizza' ? 'pizza.png' : 'hamburguer.png';
  for (const c of d.categories) c.icon = ({1:'hamburguer.png',2:'pizza.png',3:'sobremesa.png',4:'japonesa.png'})[c.id];
  d.promotions[0].image='50_Off.png'; d.restaurants[0].image='burguer_tech.png'; d.restaurants[1].image='pizza_square.png';
  for (const u of d.users) { const salt=crypto.randomBytes(16).toString('hex'); u.passwordHash=salt+':'+crypto.scryptSync(u.password,salt,64).toString('hex'); delete u.password; delete u.token; u.avatar='avatar.png'; }
  for (const c of d.cart) { c.userId=1; c.drinkId=null; c.image=c.productId===301?'batata.png':'hamburguer.png'; }
  d.preferences={'1':{cutlery:false}};
  d.orders[0].status='Saiu para Entrega';
  d.recentOrders[0].userId=1; d.recentOrders[0].restaurantId=1; d.recentOrders[0].items=[{productId:102,quantity:1,price:45.9,name:'Classic Burger Gold'}];
  d.recentOrders[1].userId=1; d.recentOrders[1].restaurantId=2; d.recentOrders[1].items=[{productId:201,quantity:1,price:78,name:'Pizza Napolitana'}];
  return d;
}
let db = fs.existsSync(DB) ? JSON.parse(fs.readFileSync(DB,'utf8')) : seed();
// Compatibilidade com bases já utilizadas na versão inicial.
for (const product of db.products) product.available ??= true;
function save(){fs.mkdirSync(path.dirname(DB),{recursive:true});fs.writeFileSync(DB+'.tmp',JSON.stringify(db,null,2));fs.renameSync(DB+'.tmp',DB);}
function fail(status,message){throw Object.assign(new Error(message),{status});}
function sign(user){const enc=x=>Buffer.from(JSON.stringify(x)).toString('base64url');const s=enc({alg:'HS256',typ:'JWT'})+'.'+enc({sub:user.id,iat:Math.floor(Date.now()/1000),exp:Math.floor(Date.now()/1000)+86400});return s+'.'+crypto.createHmac('sha256',SECRET).update(s).digest('base64url');}
function auth(req){const token=(req.headers.authorization||'').replace(/^Bearer /i,'');const a=token.split('.');if(a.length!==3)fail(401,'Token ausente ou inválido');const expected=crypto.createHmac('sha256',SECRET).update(a[0]+'.'+a[1]).digest();const actual=Buffer.from(a[2],'base64url');if(actual.length!==expected.length||!crypto.timingSafeEqual(actual,expected))fail(401,'Token inválido');let p;try{p=JSON.parse(Buffer.from(a[1],'base64url'));}catch{fail(401,'Token inválido');}if(!p.exp||p.exp<=Date.now()/1000)fail(401,'Token expirado');const u=db.users.find(u=>u.id===p.sub);if(!u)fail(401,'Sessão inválida');return u;}
const publicUser=u=>{const {passwordHash,...safe}=u;return safe;};
const integer=(v)=>Number.isSafeInteger(v)&&v>0&&v<=999;
const money=n=>Math.round(n*100)/100;
const next=xs=>Math.max(0,...xs.map(x=>x.id||0))+1;
function summary(uid){const items=db.cart.filter(x=>x.userId===uid);const subtotal=money(items.reduce((s,x)=>s+x.price*x.quantity,0));const discount=money(subtotal*.5);return {subtotal,coupon:-discount,discount,deliveryFee:items.length?1:0,total:money(subtotal-discount+(items.length?1:0)),cutlery:db.preferences[uid]?.cutlery||false};}
function add(uid,b){if(!integer(b.quantity??1))fail(422,'Quantidade deve ser um inteiro entre 1 e 999');const p=db.products.find(x=>x.id===Number(b.productId));if(!p)fail(404,'Produto não encontrado');if(!p.available)fail(422,'Produto indisponível');const details=db.productDetails.find(x=>x.id===p.id);let drink=null;if(b.drinkId!=null){drink=details?.drinks.find(x=>x.id===Number(b.drinkId));if(!drink)fail(422,'Bebida inválida para este produto');}const drinkId=drink?.id||null;const old=db.cart.find(x=>x.userId===uid&&x.productId===p.id&&x.drinkId===drinkId);if(old){if(!integer(old.quantity+(b.quantity??1)))fail(422,'Limite de quantidade excedido');old.quantity+=b.quantity??1;return old;}const item={id:next(db.cart),userId:uid,productId:p.id,name:p.name,description:p.description,image:p.image,quantity:b.quantity??1,drinkId,drink,price:money(p.price+(drink?.price||0))};db.cart.push(item);return item;}
function tracking(order){
  const elapsed=order.simulationStartedAt?Math.max(0,Date.now()-order.simulationStartedAt):0;
  const stage=order.simulationStartedAt?Math.min(2,Math.floor(elapsed/15000)):Math.max(0,steps.indexOf(order.status));
  const progress=order.simulationStartedAt?Math.min(1,elapsed/30000):stage/2;
  const courier=db.couriers.find(c=>c.id===order.courierId);
  const remaining=stage===2?0:1-progress;
  return {orderId:order.id,status:steps[stage],items:order.items,subtotal:order.subtotal,discount:order.discount,deliveryFee:order.deliveryFee,total:order.total,
    estimatedMin:Math.ceil((order.estimatedMin??12)*remaining),estimatedMax:Math.ceil((order.estimatedMax??18)*remaining),
    courier:courier?{...courier,contactAuthorized:true}:null,
    location:{latitude:-22.8214+progress*.002,longitude:-47.2665+progress*.002},
    timeline:steps.map((step,i)=>({step,completed:i<=stage,state:i<stage?'completed':i===stage?(stage===2?'completed':'current'):'pending',current:i===stage&&stage<2})),
    updatedAt:new Date().toISOString(),simulation:true};
}
async function body(req){let chunks=[],size=0;for await(const c of req){size+=c.length;if(size>65536)fail(413,'Corpo da requisição muito grande');chunks.push(c);}try{return chunks.length?JSON.parse(Buffer.concat(chunks).toString()):{};}catch{fail(400,'JSON inválido');}}
const server=http.createServer(async(req,res)=>{
  const send=(status,data)=>{res.writeHead(status,{'Content-Type':'application/json; charset=utf-8'});res.end(JSON.stringify(data));};
  res.setHeader('Access-Control-Allow-Origin','*');res.setHeader('Access-Control-Allow-Headers','Content-Type, Authorization, X-Order-Id');res.setHeader('Access-Control-Allow-Methods','GET, POST, PUT, PATCH, DELETE, OPTIONS');
  if(req.method==='OPTIONS'){res.writeHead(204);return res.end();}
  try{
    const url=new URL(req.url,'http://localhost');let route=url.pathname.replace(/^\/api(?=\/|$)/,'').replace(/\/$/,'')||'/';const method=req.method;
    if(method==='GET'&&route==='/health')return send(200,{status:'ok',name:'VaptFood A1'});
    if(method==='GET'&&route.startsWith('/media/')){const filename=path.basename(route);const file=path.join(ROOT,'media',filename);if(!fs.existsSync(file))fail(404,'Imagem não encontrada');res.writeHead(200,{'Content-Type':'image/png'});return fs.createReadStream(file).pipe(res);}
    if(method==='POST'&&['/login','/auth/login'].includes(route)){const b=await body(req);const u=db.users.find(x=>x.email===String(b.email).trim().toLowerCase());let valid=false;if(u&&typeof b.password==='string'&&b.password.length<=1024){const [salt,hash]=u.passwordHash.split(':');valid=crypto.timingSafeEqual(crypto.scryptSync(b.password,salt,64),Buffer.from(hash,'hex'));}if(!valid)fail(401,'Dados de acesso inválidos');return send(200,{token:sign(u),tokenType:'Bearer',expiresIn:86400,user:publicUser(u)});}
    if(method==='POST'&&['/forgotPassword','/auth/forgot-password'].includes(route)){const b=await body(req);if(typeof b.email!=='string'||! /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(b.email))fail(422,'E-mail inválido');if(!db.users.some(u=>u.email===b.email.trim().toLowerCase()))fail(404,'E-mail não cadastrado');return send(200,{success:true,message:'Link de redefinição enviado.',simulation:true});}
    const u=auth(req);const uid=u.id;const b=['POST','PUT','PATCH'].includes(method)?await body(req):{};
    if(route==='/support'&&method==='GET')return send(200,{title:'Ajuda com o acompanhamento',instructions:['O rastreamento desta prova é simulado.','A atualização automática deve consultar a API periodicamente.','Sem conexão, mantenha os últimos dados e aguarde a reconexão.','Para falar com o entregador, pressione o botão de ligação por 2 segundos.'],channels:[],message:'Nenhum canal de suporte foi informado nos materiais da prova.'});
    if(route==='/auth/logout'&&method==='POST')return send(200,{message:'Remova o token do dispositivo para encerrar a sessão.'});
    if(['/profile','/users/me'].includes(route)&&method==='GET')return send(200,publicUser(u));
    if(['/notifications','/users/me/notifications'].includes(route)){if(['PUT','PATCH'].includes(method)){if(typeof b.active!=='boolean')fail(422,'active deve ser booleano');u.notifications=b.active;save();}else if(method!=='GET')fail(405,'Método não permitido');return send(200,{active:u.notifications});}
    if(method==='GET'&&['/categories','/promotions','/restaurants','/products'].includes(route)){let xs=db[route.slice(1)];for(const key of ['category','restaurantId','categoryId','featured'])if(url.searchParams.has(key))xs=xs.filter(x=>String(x[key])===url.searchParams.get(key));const q=url.searchParams.get('q')||url.searchParams.get('search');if(q)xs=xs.filter(x=>[x.name,x.title,x.description,...(x.keywords||[])].filter(Boolean).join(' ').toLocaleLowerCase().includes(q.toLocaleLowerCase()));return send(200,xs);}
    let match=route.match(/^\/(?:products|productDetails)\/(\d+)(?:\/details)?$/);if(method==='GET'&&match){const p=db.products.find(x=>x.id===+match[1]);if(!p)fail(404,'Produto não encontrado');const detail=db.productDetails.find(x=>x.id===p.id);return send(200,{...p,...detail,image:p.image,drinks:detail?.drinks||[]});}
    if(route==='/cartSummary'&&method==='GET')return send(200,summary(uid));
    if(route==='/cart/summary'&&method==='GET')return send(200,summary(uid));
    if(route==='/cart/preferences'&&['PUT','PATCH'].includes(method)){if(typeof b.cutlery!=='boolean')fail(422,'cutlery deve ser booleano');db.preferences[uid]={cutlery:b.cutlery};save();return send(200,summary(uid));}
    if(route==='/cart'&&method==='GET')return send(200,db.cart.filter(x=>x.userId===uid));
    if(['/cart','/cart/items'].includes(route)&&method==='POST'){const item=add(uid,b);save();return send(201,{message:'Produto adicionado ao carrinho!',item,summary:summary(uid)});}
    match=route.match(/^\/cart\/(?:items\/)?(\d+)$/);if(match){const i=db.cart.findIndex(x=>x.id===+match[1]&&x.userId===uid);if(i<0)fail(404,'Item não encontrado');if(method==='DELETE')db.cart.splice(i,1);else if(['PUT','PATCH','POST'].includes(method)){if(!integer(b.quantity))fail(422,'Quantidade deve ser um inteiro entre 1 e 999');db.cart[i].quantity=b.quantity;}else fail(405,'Método não permitido');save();return send(200,{items:db.cart.filter(x=>x.userId===uid),summary:summary(uid)});}
    if(route==='/recentOrders'&&method==='GET')return send(200,db.recentOrders.filter(x=>x.userId===uid));
    if(route==='/orders'&&method==='GET')return send(200,db.orders.filter(x=>x.userId===uid).map(o=>({...o,...tracking(o)})));
    if(route==='/orders'&&method==='POST'){const items=db.cart.filter(x=>x.userId===uid);if(!items.length)fail(422,'Carrinho vazio');if(b.cutlery!==undefined&&typeof b.cutlery!=='boolean')fail(422,'cutlery deve ser booleano');const totals=summary(uid);const order={id:next(db.orders),userId:uid,restaurantId:db.products.find(p=>p.id===items[0].productId).restaurantId,courierId:1,date:new Date().toISOString(),status:steps[0],estimatedMin:12,estimatedMax:18,...totals,cutlery:b.cutlery??totals.cutlery,items:structuredClone(items),simulationStartedAt:Date.now()};db.orders.push(order);db.cart=db.cart.filter(x=>x.userId!==uid);save();return send(201,order);}
    match=route.match(/^\/orders\/(\d+)(?:\/(reorder|tracking))?$/);if(match){const o=[...db.orders,...db.recentOrders].find(x=>x.id===+match[1]&&x.userId===uid);if(!o)fail(404,'Pedido não encontrado');if(match[2]==='reorder'&&method==='POST'){const snapshot=structuredClone(db.cart);try{for(const item of o.items)add(uid,{productId:item.productId,quantity:item.quantity,drinkId:item.drinkId});}catch(e){db.cart=snapshot;throw e;}save();return send(201,{items:db.cart.filter(x=>x.userId===uid),summary:summary(uid)});}if(match[2]==='tracking'&&method==='GET')return send(200,tracking(o));if(!match[2]&&method==='GET')return send(200,{...o,...tracking(o)});}
    if(route==='/tracking'&&method==='GET'){const id=Number(url.searchParams.get('orderId')||req.headers['x-order-id']);const o=db.orders.find(x=>x.id===id&&x.userId===uid);if(!o)fail(404,'Pedido não encontrado');return send(200,tracking(o));}
    fail(404,'Rota não encontrada');
  }catch(e){if(!e.status)console.error(e);send(e.status||500,{success:false,message:e.status?e.message:'Erro interno do servidor'});}
});
if(require.main===module)server.listen(Number(process.env.PORT||3000),process.env.HOST||'0.0.0.0',()=>console.log('VaptFood API na porta '+(process.env.PORT||3000)));
module.exports={server};

