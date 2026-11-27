(()=>{"use strict";
const $=id=>document.getElementById(id);
let mode="ready",start=0,elapsed=0,last=0,stats={},used=0,live={speed:0,volt:25.2,amp:0,lq:100,rssi:-52,alt:0,mah:null};
let history=[],histAt=-Infinity,speedSum=0,speedN=0,best=null,packs=0,newBest=false;
let showSummary=false,entry=0;
let page=1,firstVolt=null,endVolt=null,flightAircraft="",storeOK=true,logs={},gpsMissing=false;
const storageKey="sq-pilot-dash-demo-v14";
try{const raw=localStorage.getItem(storageKey);if(raw){const parsed=JSON.parse(raw);if(parsed&&typeof parsed==="object"&&!Array.isArray(parsed))logs=parsed;}}catch(e){storeOK=false;}
const name=()=>$("aircraft").value.trim().slice(0,32)||"Aircraft";
const rowsFor=n=>Object.prototype.hasOwnProperty.call(logs,n)&&Array.isArray(logs[n])?logs[n]:[];
const altitude=v=>v==null?null:v*($("altUnits").value==="ft"?3.28084:1);
const duration=v=>String(Math.floor(v/60)).padStart(2,"0")+":"+String(Math.floor(v%60)).padStart(2,"0");
function saveDemo(){const n=flightAircraft;const r={date:new Date().toISOString(),duration:elapsed,...stats,avg:speedN?speedSum/speedN:null,endV:endVolt,partial:gpsMissing};Object.defineProperty(logs,n,{value:[r,...rowsFor(n)].slice(0,500),writable:true,enumerable:true,configurable:true});try{localStorage.setItem(storageKey,JSON.stringify(logs));storeOK=true;}catch(e){storeOK=false;}}
const extrema={watts:Math.max,speed:Math.max,volt:Math.min,amp:Math.max,lq:Math.min,rssi:Math.min,alt:Math.max,mah:Math.max};
const canvas=$('lcd'),ctx=canvas.getContext('2d');
const selectedTheme=new URLSearchParams(location.search).get('theme');
if([...$('palette').options].some(option=>option.value===selectedTheme))$('palette').value=selectedTheme;
const root=new URL(document.body.dataset.dashboardRoot||'./',document.baseURI);
const pilot=new Image();
pilot.src=document.body.dataset.pilot||new URL('WIDGETS/SQDash/pilot.png',root).href;
const reduceMotion=matchMedia('(prefers-reduced-motion: reduce)');
let landedAt=0;
let worker,source,adapter,busy=false,queued=null,frame=0,deadline,engineFailed=false;
pilot.onload=()=>{if(worker&&+$('palette').value===9)render();};
const sizeOf=f=>f&0x10000000?64:f&0x08000000?32:f&0x04000000?22:12;
const colour=f=>'#'+(f&0xffffff).toString(16).padStart(6,'0');
function paint(cmd){
 const [op,...v]=cmd;
 if(op==='drawBitmap'){
  if(pilot.complete&&pilot.naturalWidth)ctx.drawImage(pilot,v[1],v[2],Math.ceil(pilot.naturalWidth*v[3]/100),Math.ceil(pilot.naturalHeight*v[3]/100));
  return;
 }
 if(op==='drawText'){
  const [x,y,t,f]=v,size=sizeOf(f);ctx.font=`${size>=22?600:500} ${size}px Arial`;ctx.fillStyle=colour(f);ctx.textAlign=f&0x40000000?'center':f&0x20000000?'right':'left';ctx.textBaseline='top';ctx.fillText(String(t),x,y);return;
 }
 ctx.lineWidth=1;
 if(op==='drawFilledTriangle'){const [x,y,X,Y,xx,yy,c]=v;ctx.fillStyle=colour(c);ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(X,Y);ctx.lineTo(xx,yy);ctx.closePath();ctx.fill();ctx.strokeStyle=ctx.fillStyle;ctx.lineWidth=.6;ctx.stroke();return;}
 if(op==='drawLine'){const [x,y,X,Y,pattern,c]=v;ctx.strokeStyle=colour(c);ctx.beginPath();ctx.moveTo(x+.5,y+.5);ctx.lineTo(X+.5,Y+.5);ctx.stroke();return;}
 if(op==='drawCircle'||op==='drawFilledCircle'){const [x,y,r,c]=v;ctx.fillStyle=ctx.strokeStyle=colour(c);ctx.beginPath();ctx.arc(x,y,r,0,2*Math.PI);if(op==='drawCircle')ctx.stroke();else ctx.fill();return;}
 const [x,y,w,h,c]=v;ctx.fillStyle=ctx.strokeStyle=colour(c);if(op==='drawRectangle')ctx.strokeRect(x+.5,y+.5,w-1,h-1);else ctx.fillRect(x,y,w,h);
}
function fail(message){$('pageTabs').hidden=true;engineFailed=true;busy=false;$('proof').hidden=false;canvas.hidden=true;$('modeLabel').textContent='Performance · design preview';clearTimeout(deadline);worker?.terminate();$('engine').textContent='Preview unavailable — '+message;$('engine').classList.add('error');$('arm').disabled=true;}
function send(snapshot){
 if(!worker||engineFailed)return;
 if(busy){queued=snapshot;return;}
 busy=true;deadline=setTimeout(()=>fail('renderer timed out'),4000);
 worker.postMessage({snapshot,id:++frame,...(frame===1?{source,adapter}:{})});
}
function render(){
 const report=mode==='report',rows=rowsFor(name()),valid=rows.filter(r=>r&&Number.isFinite(r.duration));
 const complete=valid.filter(r=>!r.partial),maxOf=k=>{const a=complete.map(r=>r[k]).filter(Number.isFinite);return a.length?Math.max(...a):null;};
 const [width,height]=$('size').value.split('x').map(Number);
 const theme=+$('palette').value,colors=['43daff','63ea9a','ff6f4b','e5be6b','bb89ff','62dae7','d8b782','cfa471','ffd932','ffd026'],hex=colors[theme-1];
 if(page===4&&mode==='flight')page=1;
 const snap={clock:Math.floor(performance.now()/10),landedAt,still:reduceMotion.matches,width,height,theme,showSummary,entry,mph:$('units').value==='mph',feet:$('altUnits').value==='ft',page,aircraft:name(),state:report?'REPORT':mode==='flight'?'FLIGHT':'READY',elapsed,flights:packs,newBest,bestSpeed:best,bestTime:null,bestAmp:null,firstVolt,endVolt,
  total:valid.length,totalTime:valid.reduce((t,r)=>t+r.duration,0),allSpeed:maxOf('speed'),allPower:maxOf('watts'),allTime:maxOf('duration'),logStatus:storeOK?'LOCAL DEMO HISTORY':'MEMORY ONLY / STORAGE UNAVAILABLE',gap:false,speedMissing:gpsMissing,armUnknown:false,seenSafe:true,safeInput:mode!=='flight',r:parseInt(hex.slice(0,2),16),g:parseInt(hex.slice(2,4),16),b:parseInt(hex.slice(4,6),16),
  live,stats,history,recent:valid.slice(0,8).map(r=>({...r,date:String(r.date).replace('T',' ')}))};
 $('arm').disabled=mode==='flight'||!worker||engineFailed;$('disarm').disabled=mode!=='flight';$('aircraft').disabled=mode==='flight';
 $('modeLabel').textContent=showSummary?'Flight summary':entry?'Logbook · flight details':report?'Last flight · frozen':mode==='flight'?'Demo flight running':'Standby · simulated inputs';
 $('modeLabel').classList.toggle('report',report);$('throttleValue').textContent=$('throttle').value+'%';
 const reviewCount=Math.min(8,valid.length);
 $('review').hidden=mode==='flight'||(!showSummary&&(page!==4||!reviewCount));
 $('review').textContent=showSummary?'Open logbook':entry?'Back to logbook':'Review flights';
 $('older').hidden=$('newer').hidden=!entry||reviewCount<2;
 document.querySelectorAll('[data-page]').forEach(b=>{b.setAttribute('aria-pressed',String(!showSummary&&+b.dataset.page===page));b.disabled=mode==='flight'&&b.dataset.page==='4';});
 $('pageHelp').textContent=mode==='flight'?'Tap Performance, Essentials or Battery during the flight. Logbook opens after disarm.':showSummary?'The four readings are frozen. Open Logbook to review this flight.':entry?'Browse the most recent eight flights for this aircraft.':'Tap the bottom tabs to change pages. Start a demo flight, then disarm to see the summary.';
 $('screenSize').textContent=width+' × '+height+' px';
 canvas.setAttribute('aria-label',`Squadding Quads FPV Dashboard ${['','Performance','Essentials','Battery','Logbook'][page]} with simulated telemetry. ${mode==='flight'?'Demo flight running.':showSummary?'Flight summary with top speed, highest altitude, lowest link quality and lowest RSSI.':entry?'Saved flight details.':report?'Frozen last flight report.':'Standby.'}`);
 send(snap);
}
async function init(){
 try{
  [source,adapter]=await Promise.all(['WIDGETS/SQDash/main.lua','preview-runtime.lua'].map(async u=>{const r=await fetch(new URL(u,root),{cache:'no-cache'});if(!r.ok)throw Error('could not load renderer');return r.text();}));
  worker=new Worker(new URL('preview-worker.js?v=1.8.9.1',root));
  worker.onerror=e=>fail(e.message||'worker error');
  worker.onmessage=({data})=>{
   clearTimeout(deadline);busy=false;if(data.error){fail(data.error);return;}
   try{
    const {width,height,tabHeight}=data;
    if(canvas.width!==width||canvas.height!==height){canvas.width=width;canvas.height=height;}
    const surface=canvas.parentElement;
    surface.style.setProperty('--screen-ratio',String(width/height));
    surface.style.setProperty('--tab-height',(100*tabHeight/height)+'%');
    $('pageTabs').hidden=!tabHeight;
    ctx.clearRect(0,0,canvas.width,canvas.height);data.commands.forEach(paint);canvas.hidden=false;$('proof').hidden=true;
    $('engine').textContent='Actual Lua renderer · browser fonts approximate';canvas.dataset.frame=String(data.id);
    $('arm').disabled=mode==='flight';
   }catch(e){fail(e.message);return;}
   if(queued){const q=queued;queued=null;send(q);}
  };
  render();
 }catch(e){fail(e.message);}
}
function sample(now){if(mode!=="flight")return;let dt=Math.min(.5,Math.max(0,(now-last)/1000));last=now;elapsed=(now-start)/1000;let t=+$("throttle").value/100;
let speed=Math.max(0,t*165+Math.sin(elapsed*1.1)*t*11),amp=t*96+Math.max(0,Math.sin(elapsed*2))*t*9;used+=amp*dt/3.6;
live={speed:$("missing").checked?null:speed,volt:Math.max(19,25.2-t*1.9-used*.004),amp,lq:Math.max(0,100-Math.round(t*5+Math.max(0,Math.sin(elapsed*.5))*3)),rssi:-52-t*24-Math.sin(elapsed*.7)*3,alt:t*45+Math.sin(elapsed*.65)*t*9,mah:used};
live.watts=live.volt*live.amp;if(firstVolt==null)firstVolt=live.volt;endVolt=live.volt;if(live.speed==null)gpsMissing=true;if(live.speed!=null){speedSum+=live.speed;speedN++;}if(now-histAt>=1000){histAt=now;history.push(live.speed);if(history.length>36)history.shift();}
for(const k in extrema)if(live[k]!=null)stats[k]=stats[k]==null?live[k]:extrema[k](stats[k],live[k]);}
$("arm").onclick=()=>{showSummary=false;entry=0;mode="flight";flightAircraft=name();firstVolt=endVolt=null;gpsMissing=false;stats={};history=[];histAt=-Infinity;speedSum=speedN=0;newBest=false;used=0;elapsed=0;start=last=performance.now();sample(start);render();};
$("disarm").onclick=()=>{sample(performance.now());mode="report";landedAt=Math.floor(performance.now()/10);showSummary=true;entry=0;packs++;newBest=stats.speed!=null&&(best==null||stats.speed>best);if(newBest)best=stats.speed;saveDemo();render();};
$("reset").onclick=()=>{showSummary=false;entry=0;mode="ready";firstVolt=endVolt=null;stats={};history=[];histAt=-Infinity;gpsMissing=false;speedSum=speedN=0;best=null;packs=0;newBest=false;used=elapsed=0;live={speed:$("missing").checked?null:0,volt:25.2,amp:0,lq:100,rssi:-52,alt:0,mah:null};render();};
for(const id of ["palette","units","altUnits","missing"])$(id).onchange=()=>{if(mode==="ready")live.speed=$("missing").checked?null:0;render();};

for(const b of document.querySelectorAll('[data-page]'))b.onclick=()=>{if(mode==='flight'&&b.dataset.page==='4')return;showSummary=false;entry=0;page=+b.dataset.page;render();};
$('aircraft').onchange=()=>$('reset').onclick();
$('review').onclick=()=>{if(showSummary){showSummary=false;page=4;}else{entry=entry?0:1;}render();};
function stepEntry(direction){
 const count=Math.min(8,rowsFor(name()).filter(r=>r&&Number.isFinite(r.duration)).length);
 if(count){entry=(entry-1+direction+count)%count+1;render();}
}
$('older').onclick=()=>stepEntry(1);
$('newer').onclick=()=>stepEntry(-1);
$('size').onchange=render;$('throttle').oninput=()=>{$('throttleValue').textContent=$('throttle').value+'%';};
$('exportLog').onclick=()=>{const fields=['date','duration','speed','avg','alt','volt','amp','watts','mah','lq','rssi','endV','partial'];const csv=fields.join(',')+'\n'+rowsFor(name()).map(r=>fields.map(k=>r[k]??'').join(',')).join('\n');const url=URL.createObjectURL(new Blob([csv],{type:'text/csv'}));const a=document.createElement('a');a.href=url;a.download='Squadding-Quads-FPV-Dashboard-demo.csv';a.click();setTimeout(()=>URL.revokeObjectURL(url),10000);};
setInterval(()=>{if(mode==='flight'){sample(performance.now());render();}else if(showSummary&&+$('palette').value===9&&performance.now()/10-landedAt<110){render();}},125);
init();
})();
