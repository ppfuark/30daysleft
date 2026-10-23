const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const os=require('node:os');
const path=require('node:path');
test('Fluxo A1 com autenticação, carrinho, pedidos, recompra e persistência',async()=>{
 const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'vaptfood-'));
 process.env.DB_FILE=path.join(tmp,'db.json');
 const {server}=require('../server');
 await new Promise(r=>server.listen(0,'127.0.0.1',r));
 let token='';const base='http://127.0.0.1:'+server.address().port;
 async function call(route,method='GET',body){const r=await fetch(base+route,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:'Bearer '+token}:{})},body:body===undefined?undefined:JSON.stringify(body)});return {status:r.status,data:await r.json()};}
 try{
 assert.equal((await call('/products')).status,401);
 assert.equal((await call('/login','POST',{email:'usuario@email.com',password:'errada'})).status,401);
 const login=await call('/api/auth/login','POST',{email:'usuario@email.com',password:'123456'});assert.equal(login.status,200);token=login.data.token;assert.equal(token.split('.').length,3);assert.equal(login.data.user.passwordHash,undefined);
 assert.equal((await call('/forgotPassword','POST',{email:'invalido'})).status,422);
 assert.equal((await call('/forgotPassword','POST',{email:'ausente@email.com'})).status,404);
 assert.equal((await call('/forgotPassword','POST',{email:'usuario@email.com'})).status,200);
 assert.equal((await call('/products?category=Bebidas')).data.length,2);
 assert.ok((await call('/products')).data.every(p=>typeof p.available==='boolean'));
 assert.equal((await call('/products?category=Bebidas&q=Natural')).data[0].id,104);
 assert.equal((await call('/products?category=Hamburguers&q=Natural')).data.length,0);
 assert.equal((await call('/support')).data.channels.length,0);
 assert.equal((await call('/products/102')).data.drinks.length,2);
 assert.equal((await call('/profile')).data.email,'usuario@email.com');
 assert.equal((await call('/cartSummary')).data.total,28.75);
 assert.equal((await call('/cart','POST',{productId:102,quantity:-1})).status,422);
 assert.equal((await call('/cart','POST',{productId:102,drinkId:500})).status,422);
 const added=await call('/cart','POST',{productId:102,quantity:2,drinkId:1});assert.equal(added.status,201);assert.equal(added.data.item.price,53);
 assert.equal((await call('/cart/'+added.data.item.id,'PUT',{quantity:3})).status,200);
 assert.equal((await call('/cart/'+added.data.item.id,'DELETE')).status,200);
 assert.equal((await call('/cart/preferences','PUT',{cutlery:true})).data.cutlery,true);
 const order=await call('/orders','POST',{});assert.equal(order.status,201);assert.equal(order.data.total,28.75);assert.equal(order.data.cutlery,true);
 assert.equal((await call('/cart')).data.length,0);
 assert.equal((await call('/orders','POST',{})).status,422);
 assert.equal((await call('/orders/'+order.data.id+'/tracking')).data.timeline.length,3);
 const track=(await call('/orders/'+order.data.id+'/tracking')).data;
 assert.equal(track.total,track.subtotal-track.discount+track.deliveryFee);
 assert.ok(track.items.length>0);assert.equal(track.courier.contactAuthorized,true);
 assert.equal(track.timeline[0].state,'current');assert.equal(track.timeline[1].state,'pending');
 assert.ok(track.estimatedMin>0);assert.ok(track.updatedAt);
 const realNow=Date.now;
 try {
   Date.now=()=>order.data.simulationStartedAt+16000;
   const moving=(await call('/orders/'+order.data.id+'/tracking')).data;
   assert.equal(moving.timeline[0].state,'completed');assert.equal(moving.timeline[1].state,'current');
   assert.ok(moving.estimatedMax<track.estimatedMax);assert.ok(moving.location.latitude>track.location.latitude);
   Date.now=()=>order.data.simulationStartedAt+31000;
   const delivered=(await call('/orders/'+order.data.id)).data;
   assert.equal(delivered.status,'Entregue');assert.equal(delivered.estimatedMax,0);
   assert.ok(delivered.timeline.every(s=>s.state==='completed'));
 } finally {Date.now=realNow;}
 assert.equal((await call('/tracking?orderId=8821')).data.courier.name,'Carlos Alberto');
 assert.equal((await call('/orders/1001/reorder','POST',{})).status,201);
 assert.equal((await call('/cart')).data[0].productId,102);
 assert.equal((await call('/notifications','PUT',{active:false})).data.active,false);
 const persisted=JSON.parse(fs.readFileSync(process.env.DB_FILE));assert.equal(persisted.orders.length,2);assert.equal(persisted.users[0].password,undefined);
 token=token.slice(0,-6)+'xxxxxx';assert.equal((await call('/profile')).status,401);
 }finally{await new Promise(r=>server.close(r));fs.rmSync(tmp,{recursive:true,force:true});}
});
