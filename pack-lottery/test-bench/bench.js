'use strict';
const byId = id => document.getElementById(id);
const canvas = byId('lcd'), ctx = canvas.getContext('2d');
let worker, deadline, timer, source, adapter, filename, generation=0, busy=false, pending=[];
let images=new Map(), epoch=Math.floor(Date.now()/1000), last='';
const wallpaperRoot='../../wallpaper-shuffle/';
const stock=['workshop.png','manc.png','karen.png','dealer.png'];
const wallMode=new URLSearchParams(location.search).has('wallpaper');
const show = text => { byId('status').textContent=text; };
function stop(){
  if(worker) worker.terminate();
  worker=null; busy=false; pending=[];
  clearTimeout(deadline);clearTimeout(timer);
}
function fail(message){stop();show('Stopped · '+message);}
function color(flags, fallback='#f2f2ef'){
  return flags & 0x1000000 ? '#'+(flags & 0xffffff).toString(16).padStart(6,'0') : fallback;
}
function textStyle(flags){
  const size=flags&0x10000000?44:flags&0x08000000?32:flags&0x04000000?22:flags&0x02000000?13:16;
  ctx.font=size+'px sans-serif';
  ctx.textBaseline='top';ctx.textAlign=flags&0x40000000?'center':flags&0x20000000?'right':'left';
  ctx.fillStyle=color(flags);
  return size;
}
function paint([op,x,y,a,b,c,d]){
  if(op==='drawBitmap'){
    const im=images.get(String(a).split('/').pop());
    if(im)ctx.drawImage(im,x,y,im.naturalWidth*b/100,im.naturalHeight*b/100);
    return;
  }
  if(op==='clear'){ctx.fillStyle=color(x,'#151a20');ctx.fillRect(0,0,canvas.width,canvas.height);return;}
  if(op==='drawText'){textStyle(b);ctx.fillText(String(a),x,y);return;}
  if(op==='drawTextLines'){
    const line=textStyle(d)+2;
    ctx.save();ctx.beginPath();ctx.rect(x,y,a,b);ctx.clip();
    let top=y;
    const left=ctx.textAlign==='center'?x+a/2:ctx.textAlign==='right'?x+a:x;
    for(const paragraph of String(c).split('\n')){
      let row='';
      for(const word of paragraph.split(/\s+/)){
        const next=row?row+' '+word:word;
        if(row && ctx.measureText(next).width>a){ctx.fillText(row,left,top);top+=line;row=word;}
        else row=next;
      }
      ctx.fillText(row,left,top);top+=line;
    }
    ctx.restore();return;
  }
  if(op==='drawCircle'||op==='drawFilledCircle'){
    ctx.fillStyle=ctx.strokeStyle=color(b);ctx.beginPath();ctx.arc(x,y,Math.max(0,a),0,Math.PI*2);
    if(op==='drawCircle')ctx.stroke();else ctx.fill();return;
  }
  if(op==='drawLine'){
    ctx.strokeStyle=color(d);ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(a,b);ctx.stroke();return;
  }
  ctx.fillStyle=ctx.strokeStyle=color(c);
  if(op==='drawRectangle')ctx.strokeRect(x,y,a,b);else ctx.fillRect(x,y,a,b);
}
function send(data){
  if(!worker)return;
  clearTimeout(timer);busy=true;
  deadline=setTimeout(()=>fail('Widget exceeded the frame time limit.'),2500);
  worker.postMessage(data);
}
function run(){
  stop();if(!source||!adapter)return;
  const [width,height]=byId('size').value.split('×').map(Number);
  const tile=byId('view').selectedIndex===1;
  canvas.width=tile?Math.floor(width/2):width;canvas.height=tile?Math.floor(height/2):height;
  worker=new Worker('worker.js');show('Starting '+filename+'…');
  let first=true;
  worker.onerror=e=>fail(e.message||'Lua engine could not start.');
  worker.onmessage=({data})=>{
    if(typeof data.saved==='string'){last=data.saved;return;}
    clearTimeout(deadline);busy=false;
    if(data.error){fail(data.error);return;}
    try{data.commands.forEach(paint);}catch(err){fail(String(err));return;}
    if(first){show(filename+' · '+(tile?'Tile preview':'Running'));first=false;}
    if(pending.length)send(pending.shift());
    else timer=setTimeout(()=>send({event:0}),120);
  };
  send({source,adapter,width,height,tile,epoch,last,images:[...images].map(([name,im])=>({name,width:im.naturalWidth,height:im.naturalHeight}))});
}
function input(event,x,y){
  if(!worker||byId('view').selectedIndex)return;
  const data={event,x,y};
  if(!busy)send(data);else if(pending.length<12)pending.push(data);
}
canvas.onpointerup=e=>{
  const r=canvas.getBoundingClientRect();
  input(4,Math.floor((e.clientX-r.left)*canvas.width/r.width),Math.floor((e.clientY-r.top)*canvas.height/r.height));
};
document.querySelectorAll('[data-key]').forEach(b=>b.onclick=()=>input(Number(b.dataset.key)));
document.onkeydown=e=>{
  if(['INPUT','SELECT','BUTTON','SUMMARY','A'].includes(e.target.tagName))return;
  const k={ArrowRight:1,ArrowDown:1,ArrowLeft:2,ArrowUp:2,Enter:3}[e.key];
  if(k){e.preventDefault();input(k);}
};
async function read(url){const r=await fetch(url);if(!r.ok)throw Error('Could not load '+url);return r.text();}
async function load(file,wall=false){
  const ticket=++generation;stop();source=null;
  try{
    if(file && file.size>512*1024)throw Error('Choose a Lua file under 512 KB.');
    const [code,shim]=await Promise.all([file?file.text():read(wall?wallpaperRoot+'WIDGETS/SQWall/main.lua':'../main.lua'),adapter||read('runtime.lua')]);
    if(wall && !images.size){
      const entries=await Promise.all(stock.map(async name=>[name,await decodeImage(wallpaperRoot+'IMAGES/SQWALL/'+name)]));
      if(ticket!==generation)return;
      images=new Map(entries);
    }
    if(ticket!==generation)return;
    source=code;adapter=shim;filename=file?file.name:(wall?'SQ Wallpaper Shuffle':'Pack Lottery');run();
  }catch(err){if(ticket===generation)fail(String(err));}
}
byId('file').onchange=e=>{if(e.target.files[0])load(e.target.files[0]);};
byId('demo').onclick=()=>{byId('file').value='';load();};
byId('restart').onclick=byId('size').onchange=byId('view').onchange=run;
async function decodeImage(url){
  const im=new Image();im.src=url;await im.decode();return im;
}
let imageImport=0;
async function importImages(files){
  const id=++imageImport;
  const pngs=[...files].filter(f=>/\.png$/i.test(f.name));
  if(!pngs.length){show('Choose one or more PNG wallpapers.');return;}
  try{
    const entries=[];
    for(const f of pngs){
      const url=URL.createObjectURL(f);
      try{entries.push([f.name,await decodeImage(url)]);}finally{URL.revokeObjectURL(url);}
    }
    if(id!==imageImport)return;
    images=new Map(entries);last='';run();
  }catch{show('Could not open one of those PNGs.');}
}
byId('images').onchange=e=>importImages(e.target.files);
byId('folder').onchange=e=>importImages(e.target.files);
byId('wall').onclick=()=>{imageImport++;images=new Map();last='';load(null,true);};
byId('power').onclick=()=>{epoch=Math.max(epoch+3,Math.floor(Date.now()/1000));run();};
load(null,wallMode);
