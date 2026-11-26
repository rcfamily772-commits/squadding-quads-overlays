'use strict';
const v2el=id=>document.getElementById(id),v2key='sq.trick.v2';
let v2data={battle:false,turn:0,scores:[0,0],theme:'Black Label'};
try{const x=JSON.parse(localStorage.getItem(v2key));if(x&&Array.isArray(x.scores)&&x.scores.length===2&&x.scores.every(n=>Number.isSafeInteger(n)&&n>=0)&&[0,1].includes(x.turn))v2data={...v2data,...x};}catch{}
function v2save(){try{localStorage.setItem(v2key,JSON.stringify(v2data));}catch{}}
function sqRefresh(){if(typeof sqFlipRefresh==='function')sqFlipRefresh();const s=collector.stats();v2el('career').textContent=black.rank(s.completed)+' • '+s.completed*25+' XP'+(v2data.battle?' • P'+(v2data.turn+1)+' turn / '+v2data.scores.join('–'):'');for(const id of ['academy','inspect','vertical','horizontal','reveal-export'])v2el(id).hidden=state.card===null||(id==='academy'&&(state.level>=3&&state.level<=5));}
function sqBattleWin(){if(v2data.battle){v2data.scores[v2data.turn]++;v2data.turn=1-v2data.turn;v2save();}}
v2el('flight-mode').onchange=()=>{if(busy)return;try{localStorage.setItem('sq.trick.mode',v2el('flight-mode').value);}catch{}state.bags=decks.map(()=>[]);state.last=decks.map(()=>null);state.card=null;state.collected=false;state.complete='';save();};
function msg(t){v2el('v2-status').textContent=t;}
function openV2(...nodes){v2el('v2-content').replaceChildren(...nodes);v2el('v2-dialog').showModal();}
v2el('v2-close').onclick=()=>v2el('v2-dialog').close();
function node(t,s){const n=document.createElement(t);n.textContent=s;return n;}
function theme(t){const n=collector.stats().completed;if((t==='Carbon'&&n<10)||(t==='Signature'&&n<30)){msg(t+' unlocks at '+(t==='Carbon'?10:30)+' completions.');t='Black Label';}if(!['Black Label','Bando','Neon','Retro','Carbon','Signature'].includes(t))t='Black Label';v2data.theme=t;v2el('theme').value=t;document.body.dataset.theme=t;v2save();}
v2el('theme').onchange=()=>theme(v2el('theme').value);theme(v2data.theme);
v2el('battle').onclick=()=>{if(busy)return;const toggle=node('button',v2data.battle?'End battle':'Start new battle'),skip=node('button','Pass turn');toggle.onclick=()=>{if(v2data.battle)v2data.battle=false;else{v2data.battle=true;v2data.turn=0;v2data.scores=[0,0];state.card=null;state.collected=false;save();}v2save();sqRefresh();v2el('v2-dialog').close();};skip.onclick=()=>{if(v2data.battle){v2data.turn=1-v2data.turn;state.card=null;state.collected=false;state.complete='';v2save();save();}v2el('v2-dialog').close();};openV2(node('h2','Pilot vs Pilot'),node('p','Local pass-and-play. Landed = one point. Pass any unsafe challenge.'),node('p','Pilot 1: '+v2data.scores[0]+' | Pilot 2: '+v2data.scores[1]),toggle,skip);};
function common(weekly){if(busy)return;const day=Math.floor(Date.now()/86400000),seed=weekly?Math.floor((day+3)/7):day,pool=[];for(let l=0;l<2;l++)for(let c=0;c<decks[l].length;c++)if(sqEligible(l,c,'Real World'))pool.push([l,c]);if(v2el('flight-mode').value==='Fixed Wing'){pool.length=0;for(let c=0;c<decks[6].length;c++)if(sqEligible(6,c,'Fixed Wing'))pool.push([6,c]);}const [l,c]=pool[((seed*7919+17)%pool.length+pool.length)%pool.length];if(!sqEligible(l,c,v2el('flight-mode').value)){v2el('flight-mode').value='Real World';v2el('flight-mode').onchange();}state.level=l;state.card=c;state.tries=1;state.complete='';state.rarity=collector.roll();state.collected=true;collector.draw(l,c,state.rarity);state.last[l]=c;save();msg((weekly?'Weekly':'Daily')+' community challenge • #SQTrickLottery • UTC calendar');}
v2el('daily').onclick=()=>common(false);v2el('weekly').onclick=()=>common(true);
const paths={s:'M20 150 C65 150 65 40 110 40 S155 150 200 150 S245 40 290 40',hover:'M150 155 L150 55 L150 95',land:'M20 35 Q125 35 200 150 L290 150',square:'M40 140 L40 40 L270 40 L270 140 Z',orbit:'M40 95 A115 65 0 1 0 270 95 A115 65 0 1 0 40 95',line:'M25 105 L285 105',roll:'M20 95 C50 10 80 10 110 95 S170 180 200 95 S260 10 290 95',loop:'M20 155 L80 155 C230 155 230 25 155 25 C80 25 80 155 230 155 L290 155',eight:'M155 95 C0 -40 0 230 155 95 C310 -40 310 230 155 95'};
v2el('academy').onclick=()=>{if(busy||state.card===null||(state.level>=3&&state.level<=5))return;const [title,brief,mode,pre,path]=decks[state.level][state.card];const svg=document.createElementNS('http://www.w3.org/2000/svg','svg');svg.setAttribute('viewBox','0 0 310 190');svg.setAttribute('aria-label','Conceptual path, not stick instructions');const line=document.createElementNS(svg.namespaceURI,'path');line.setAttribute('d',paths[path]||paths.line);line.setAttribute('fill','none');line.setAttribute('stroke','#dfc17b');line.setAttribute('stroke-width','3');svg.append(line);const link=node('a','Find Squadding Quads tutorials');link.href='https://www.youtube.com/results?search_query='+encodeURIComponent('Squadding Quads FPV '+title);link.target='_blank';link.rel='noopener';openV2(node('h2',title),node('p',levels[state.level].textContent+' • '+mode+' • Prerequisite: '+pre),node('p',brief),svg,node('p','Illustrative path only. Practise in a simulator first; fly only with adequate space and recovery height.'),link);};
v2el('inspect').onclick=()=>{if(busy||state.card===null)return;const card=node('div','');card.className='v2-inspection';card.dataset.rarity=state.rarity;card.append(node('small',titleCase(state.rarity)+' • '+black.serial(state.level,state.card)),node('h2',decks[state.level][state.card][0]),node('p',decks[state.level][state.card][1]));const range=document.createElement('input');range.type='range';range.min=-35;range.max=35;range.value=0;range.setAttribute('aria-label','Rotate card');range.oninput=()=>card.style.setProperty('--spin',range.value+'deg');openV2(card,range);};
function paint(canvas,result,progress){const c=canvas.getContext('2d'),w=canvas.width,h=canvas.height,k=Math.min(w,h)/1080,g=c.createLinearGradient(0,0,w,h);g.addColorStop(0,'#101b20');g.addColorStop(.5,'#342a1a');g.addColorStop(1,'#101415');c.fillStyle=g;c.fillRect(0,0,w,h);c.strokeStyle='#e6c77f';c.lineWidth=4*k;c.strokeRect(40*k,40*k,w-80*k,h-80*k);c.textAlign='center';function txt(t,y,size){c.fillStyle='#f5e6bd';c.font='bold '+size*k+'px sans-serif';c.fillText(t,w/2,y,w-100*k);}txt('SQUADDING QUADS • TRICK LOTTERY',h*.13,35);txt(result?'SESSION RESULTS':progress<.35?'DRAW IT. FLY IT. OWN IT.':titleCase(state.rarity).toUpperCase(),h*.25,43);if(result){txt(state.total+' LANDED',h*.48,100);txt(collector.stats().completed*25+' CAREER XP',h*.62,48);}else if(progress>=.35){txt(decks[state.level][state.card][0],h*.47,80);const words=decks[state.level][state.card][1].split(' ');c.font=36*k+'px sans-serif';let row='',rows=[];for(const word of words){if(row&&c.measureText(row+' '+word).width>w*.78){rows.push(row);row=word;}else row+=(row?' ':'')+word;}if(row)rows.push(row);rows.forEach((r,i)=>txt(r,h*.59+i*45*k,36));txt(black.serial(state.level,state.card),h*.84,30);}txt('#SQTRICKLOTTERY',h*.93,30);}
function downloadV2(blob,name){const u=URL.createObjectURL(blob),a=document.createElement('a');a.href=u;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(u),30000);}
function canvasV2(w,h){const c=document.createElement('canvas');c.width=w;c.height=h;return c;}
function png(w,h,result=false){if(busy||(!result&&state.card===null))return;const c=canvasV2(w,h);paint(c,result,1);c.toBlob(b=>{if(b)downloadV2(b,'SQ-Trick-Lottery-'+(result?'session':w+'x'+h)+'.png');},'image/png');}
v2el('vertical').onclick=()=>png(1080,1920);v2el('horizontal').onclick=()=>png(1920,1080);v2el('result-export').onclick=()=>png(1080,1920,true);
v2el('reveal-export').onclick=()=>{if(busy||state.card===null)return;const c=canvasV2(720,1280);paint(c,false,0);if(!c.captureStream||typeof MediaRecorder==='undefined'){msg('Video export unsupported. Use PNG.');return;}let rec;try{rec=new MediaRecorder(c.captureStream(24));}catch{msg('Video encoding unsupported. Use PNG.');return;}setBusy(true);const chunks=[];rec.ondataavailable=e=>{if(e.data.size)chunks.push(e.data);};rec.onstop=()=>{const mime=rec.mimeType||'video/webm';downloadV2(new Blob(chunks,{type:mime}),'SQ-reveal.'+(mime.includes('mp4')?'mp4':'webm'));setBusy(false);msg('Reveal exported.');};rec.onerror=()=>{setBusy(false);msg('Video export failed.');};rec.start();const start=performance.now();function frame(now){if(rec.state==='inactive')return;const t=(now-start)/2200;paint(c,false,t);if(t<1)requestAnimationFrame(frame);else rec.stop();}requestAnimationFrame(frame);};

// Black Label / FPV schematic reverse. No collection or scoring changes.
const sqFlightShapes={
 eight:['PLAN VIEW','M155 95 C80 8 28 30 28 95 S80 182 155 95 S282 8 282 95 S230 182 155 95','Match the two lobes.'],
 square:['PLAN VIEW','M52 145 Q36 145 36 129 V52 Q36 36 52 36 H258 Q274 36 274 52 V129 Q274 145 258 145 H52','Keep corners repeatable.'],
 orbit:['PLAN VIEW','M54 95 A101 58 0 1 1 256 95 A101 58 0 1 1 54 95','Maintain a consistent radius.'],
 both:['PLAN VIEW','M78 95 A51 40 0 1 1 180 95 A51 40 0 1 1 78 95 M236 95 A51 40 0 1 0 134 95 A51 40 0 1 0 236 95','Opposite directions; compare framing.'],
 outback:['PLAN VIEW','M28 66 H252 Q282 66 282 95 Q282 124 252 124 H28','Keep both legs level.'],
 straight:['PLAN VIEW','M30 95 H280','Hold a steady heading.'],
 step:['SIDE VIEW','M25 95 H105 H185 H285','Change pace, not height.'],
 depart:['SIDE VIEW','M35 150 V85 Q35 65 65 65 H285','Lift, pause, then ease forward.'],
 hover:['PLAN VIEW','M60 95 H150 M150 95 H270','Pause at the centre before moving away.'],
 land:['SIDE VIEW','M24 40 C105 40 130 140 205 145 H280','Settle gently onto a clear landing area.'],
 doubleland:['SIDE VIEW','M24 42 Q65 42 94 145 H125 M164 42 Q205 42 234 145 H280','Two separate controlled approaches.'],
 ladder:['SIDE VIEW','M24 145 H55 Q95 145 120 50 H185 Q210 50 250 145 H285','Climb, hold, then descend.'],
 s:['PLAN VIEW','M25 125 C60 125 60 50 105 50 S155 125 200 125 S250 50 285 50','Use smooth, broad alternating turns.'],
 mirror:['PLAN VIEW','M20 56 C45 56 45 20 75 20 S115 56 145 56 S180 20 205 20 M20 130 C45 130 45 166 75 166 S115 130 145 130 S180 166 205 166','Compare the original and mirrored line.'],
 arcs:['PLAN VIEW','M25 112 Q90 10 155 112 Q220 10 285 112','Match the size of both arcs.'],
 half:['PLAN VIEW','M50 125 A105 82 0 0 1 260 125','Keep the reference in frame.'],
 exit:['PLAN VIEW','M40 100 C40 18 220 18 220 95 C220 175 40 175 40 100 H285','Choose the exit heading before entry.'],
 yaw:['TOP VIEW / ATTITUDE','M90 95 A65 65 0 0 1 220 95','Rotate heading while holding position.'],
 loop:['SIDE VIEW','M23 150 H100 C235 150 235 25 155 25 C65 25 65 150 212 150 H287','Smooth recovery to the original heading.'],
 doubleloop:['SIDE VIEW','M20 145 H55 C125 145 125 35 82 35 C32 35 32 145 145 145 C240 145 240 35 195 35 C145 35 145 145 285 145','Match the apex and recovery of both loops.'],
 split:['SIDE VIEW / ATTITUDE','M30 38 H175 C270 38 270 145 175 145 H30','Half-roll, descending half-loop, reverse heading.'],
 cuban:['SIDE VIEW / ATTITUDE','M25 145 H100 C240 145 240 25 155 25 C80 25 75 93 112 112 L235 160 H285','Simulator only; conceptual half-loop and descending exit.'],
 recover:['SIDE VIEW','M25 35 Q110 35 150 120 Q175 150 215 150 H285','Recover smoothly before levelling out.'],
 side:['PLAN VIEW','M65 40 V150','Translate sideways while holding camera heading.'],
 reverse:['PLAN VIEW','M28 65 H255 M255 125 H28','Compare entry and reversed sequence on DVR.'],
 roll:['ATTITUDE SEQUENCE','', 'Rotate about the forward axis, then recover.'],
 rollpair:['ATTITUDE SEQUENCE','', 'Left and right axial rolls; match timing.'],
 pointroll:['ATTITUDE SEQUENCE','', 'Pause at quarter-turn attitudes; equal timing.'],
 frontflip:['ATTITUDE SEQUENCE','', 'Forward pitch rotation; recover level.'],
 backflip:['ATTITUDE SEQUENCE','', 'Backward pitch rotation; recover level.'],
 combo:['MANOEUVRE SEQUENCE','', 'Conceptual sequence only; review each transition.'],
 review:['PRACTICE SEQUENCE','', 'Conceptual sequence only; not stick instructions.']
};
const sqFlightMap=[
 ['eight','doubleland','square','both','outback','square','depart','step','s','hover','doubleland','square','yaw','side','hover','ladder','arcs','straight','land','square','straight','s'],
 ['rollpair','exit','half','eight','hover','split','mirror','loop','roll','frontflip','backflip','cuban','both','combo','s','eight','loop','reverse','recover','exit','rollpair'],
 ['combo','review','review','combo','doubleloop','pointroll','combo','mirror','review','review','review','reverse','review','combo','review','yaw','review','review','exit','s','review']
];
const sqSequences={
 '1:13':['Wide turn','Axial roll','Level exit'],
 '2:0':['Split-S','Power loop','Level exit'],
 '2:1':['Entry','Juicy flick','Match exit'],
 '2:2':['Three tricks','Mirror rolls','Compare DVR'],
 '2:3':['Orbit','Axial roll','Tangent exit'],
 '2:6':['Orbit','Roll','Loop'],
 '2:8':['Entry','Matty flip','Recover'],
 '2:9':['Entry','Trippy spin','Recover'],
 '2:10':['Inverted','Yaw','Recover'],
 '2:12':['Juicy flick','Juicy flick','Recover'],
 '2:13':['Axial roll','Loop','Level exit'],
 '2:14':['Entry','Rubik rotation','Recover'],
 '2:16':['Entry','Three-axis flow','Recover'],
 '2:17':['Juicy flick','Mirror roll','Compare'],
 '2:20':['Trick 1','Trick 2','Trick 3']
};
const sqReverseCard=v2el('challenge-card'),sqReverse=document.createElement('div');
sqReverse.className='sq-flight-reverse';sqReverse.hidden=true;sqReverseCard.append(sqReverse);
const sqInspect=v2el('inspect'),sqOldInspect=sqInspect.onclick;
function sqCanFlip(){return state.card!==null&&((state.level>=0&&state.level<3)||state.level===5);}
function sqSide(back){
 sqReverseCard.classList.toggle('sq-diagram-open',back);sqReverse.hidden=!back;
 for(const item of sqReverseCard.children){if(item===sqReverse||item.classList.contains('bottom'))continue;if(back)item.setAttribute('aria-hidden','true');else item.removeAttribute('aria-hidden');}
 sqInspect.textContent=sqCanFlip()?(back?'Flip to front ↶':state.level===5?'Flip card / 18+ ↻':'Flip card / diagram ↻'):'Inspect card';
 sqInspect.setAttribute('aria-expanded',String(back));
}
function sqFlipRefresh(){sqSide(false);}
function sqSVG(tag,attrs={},content){const x=document.createElementNS('http://www.w3.org/2000/svg',tag);for(const [k,v] of Object.entries(attrs))x.setAttribute(k,v);if(content)x.textContent=content;return x;}
function sqRenderReverse(){
 sqReverse.classList.remove('sq-adult-reverse','sq-golden-finger');
 if(state.level===5){sqRenderAdultReverse();return;}
 const [title,brief,mode,pre]=decks[state.level][state.card], key=sqFlightMap[state.level][state.card], [view,d,note]=sqFlightShapes[key];
 const head=node('div','SQ / FLIGHT SCHOOL  ·  '+titleCase(state.rarity).toUpperCase());head.className='sq-flight-meta';
 const name=node('h3',title);const label=node('div',view+' / NOT TO SCALE');label.className='sq-flight-label';
 const svg=sqSVG('svg',{viewBox:'0 0 310 190',role:'img','aria-label':title+': '+note});
 const defs=sqSVG('defs'),marker=sqSVG('marker',{id:'sq-flight-arrow',markerWidth:6,markerHeight:6,refX:5,refY:3,orient:'auto',markerUnits:'strokeWidth'});marker.append(sqSVG('path',{d:'M0 0 L6 3 L0 6 L1.5 3 Z',fill:'#95e5ef'}));defs.append(marker);svg.append(defs);
 svg.append(sqSVG('rect',{x:1,y:1,width:308,height:188,rx:12,fill:'#101e25',stroke:'#38535e'}));
 for(let x=25;x<310;x+=26)svg.append(sqSVG('path',{d:'M'+x+' 12 V178',stroke:'#263b44','stroke-width':.7}));
 for(let y=17;y<190;y+=26)svg.append(sqSVG('path',{d:'M12 '+y+' H298',stroke:'#263b44','stroke-width':.7}));
 if(d){
  for(const segment of d.split(/(?=M)/).filter(Boolean)){
   const glow=sqSVG('path',{d:segment,fill:'none',stroke:'#65b8c9','stroke-opacity':.2,'stroke-width':9,'stroke-linecap':'round','stroke-linejoin':'round'});
   const line=sqSVG('path',{d:segment,fill:'none',stroke:'#95e5ef','stroke-width':2.8,'stroke-linecap':'round','stroke-linejoin':'round','marker-end':'url(#sq-flight-arrow)'});
   svg.append(glow,line);
   const match=segment.match(/^M\s*(\d+)\s+(\d+)/);if(match)svg.append(sqSVG('circle',{cx:match[1],cy:match[2],r:4,fill:'#dfc17b',stroke:'#101e25','stroke-width':1}));
  }
  if(key==='orbit'||key==='half'||key==='both')svg.append(sqSVG('circle',{cx:155,cy:95,r:5,fill:'#dfc17b'}));
  if(['step','hover','straight'].includes(key)){for(const x of [105,185])svg.append(sqSVG('circle',{cx:x,cy:95,r:4,fill:'#dfc17b'}));}
  if(['land','doubleland','depart','recover','ladder'].includes(key))svg.append(sqSVG('path',{d:'M18 160 H292',stroke:'#dfc17b','stroke-dasharray':'5 5','stroke-opacity':.65}));
  svg.append(sqSVG('text',{x:155,y:181,'text-anchor':'middle','font-size':9,fill:'#bfd1d4'},'GOLD = ENTRY   /   CYAN = TRAVEL'));
 }else{
  let labels=sqSequences[state.level+':'+state.card]||['Entry','Manoeuvre','Recover'];
  let angles=[0,0,0];
  if(key==='roll') {labels=['Level','Inverted','Level'];angles=[0,180,360];}
  if(key==='rollpair'){labels=['Left roll','Level','Right roll'];angles=[-90,0,90];}
  if(key==='pointroll'){labels=['90°','180°','270°','360°'];angles=[90,180,270,360];}
  if(key==='frontflip'||key==='backflip'){labels=['Level',key==='frontflip'?'Pitch forward':'Pitch back','Level'];angles=[0,key==='frontflip'?180:-180,0];}
  labels.forEach((t,i)=>{
   const x=labels.length===4?44+i*74:52+i*103;
   if(i)svg.append(sqSVG('path',{d:'M'+(x-(labels.length===4?48:70))+' 82 H'+(x-31),stroke:'#95e5ef','stroke-width':2,'marker-end':'url(#sq-flight-arrow)'}));
   const g=sqSVG('g',{transform:'translate('+x+' 82) rotate('+(angles[i]||0)+')'});
   if(['roll','rollpair','pointroll','frontflip','backflip'].includes(key)){
    g.append(sqSVG('path',{d:'M-21 3 H21 M-12 -7 L12 7 M-12 7 L12 -7',stroke:'#95e5ef','stroke-width':3,'stroke-linecap':'round'}),sqSVG('rect',{x:-8,y:-5,width:16,height:10,rx:3,fill:'#e3e7e8',stroke:'#95e5ef'}),sqSVG('path',{d:'M0 -10 L-4 -4 H4 Z',fill:'#dfc17b'}));
   }else{g.append(sqSVG('circle',{r:18,fill:'#1c333d',stroke:'#95e5ef','stroke-width':2}),sqSVG('text',{x:0,y:5,'text-anchor':'middle',fill:'#dfc17b','font-size':15,'font-weight':700},String(i+1)));}
   svg.append(g,sqSVG('text',{x,y:125,'text-anchor':'middle','font-size':labels.length===4?10:9.5,fill:'#e2edf0'},t));
  });
  svg.append(sqSVG('text',{x:155,y:164,'text-anchor':'middle','font-size':9,fill:'#bfd1d4'},'CONCEPTUAL SEQUENCE / NOT STICK INPUTS'));
 }
 const foot=node('div',note);foot.className='sq-flight-note';
 const safety=node('div',(mode==='Simulator'?'SIMULATOR ONLY':'PRACTISE IN SIM FIRST')+' · '+black.serial(state.level,state.card));safety.className='sq-flight-meta';
 sqReverse.replaceChildren(head,name,label,svg,foot,safety);
}

/* Black Label: Uncensored. Adult art is constructed only for deck 5. */
const sqAdultCards=[
 ['finger','JUST FUCKING FLY IT.'],
 ['skull','LESS SHIT TALK. MORE STICK TIME.'],
 ['battery',"I DIDN'T CHARGE MYSELF."],
 ['trophy','WORLD CHAMPION OF FUCK ALL.'],
 ['sofa','PROFESSIONAL BENCH WARMER.'],
 ['warning','CRITICAL ERROR: PILOT NOT FLYING.'],
 ['skeleton','STILL WAITING FOR YOU TO FLY.'],
 ['crown','KING OF THE FUCKING EXCUSES.'],
 ['sheet',"WE DON'T FLY FUCKING SPREADSHEETS."],
 ['radio','ALL THE GEAR. NO FUCKING IDEA.'],
 ['drone','STOP ADMIRING IT. FUCKING FLY IT.'],
 ['finger','FUCK PERFECTION. GO FLY.']
];
function sqAdultArt(kind,golden){
 const svg=sqSVG('svg',{viewBox:'0 0 300 190',role:'img','aria-label':golden?'Metallic golden middle finger':kind+' illustrated emblem'});
 const defs=sqSVG('defs'),gradient=sqSVG('linearGradient',{id:'sq-adult-metal',x1:0,y1:0,x2:1,y2:1});
 for(const [offset,color] of [['0%','#77501c'],['22%','#dba64d'],['44%','#fff0af'],['58%','#a8742b'],['80%','#e4b75e'],['100%','#80531e']])gradient.append(sqSVG('stop',{offset,'stop-color':color}));
 defs.append(gradient);svg.append(defs);
 const ink='url(#sq-adult-metal)',outline='#f4d48d',dark='#191715';
 svg.append(sqSVG('circle',{cx:150,cy:95,r:82,fill:'none',stroke:'#806438','stroke-width':.8}),sqSVG('circle',{cx:150,cy:95,r:73,fill:'none',stroke:'#806438','stroke-dasharray':'2 5'}));
 const g=sqSVG('g',{'stroke-linecap':'round','stroke-linejoin':'round',stroke:outline,'stroke-width':2.1});
 const p=(d,fill=ink,extra={})=>g.append(sqSVG('path',{d,fill,...extra}));
 const rect=(x,y,width,height,rx=5,fill=ink)=>g.append(sqSVG('rect',{x,y,width,height,rx,fill}));
 const circ=(cx,cy,r,fill=ink)=>g.append(sqSVG('circle',{cx,cy,r,fill}));
 function finger(scale=1,dy=0){
  const h=sqSVG('g',{transform:'translate(150 '+(95+dy)+') scale('+scale+') translate(-150 -95)'});
  h.append(sqSVG('path',{d:'M122 164 L122 145 Q108 139 101 123 L91 100 Q86 86 99 83 Q108 81 116 94 L120 100 V83 Q120 73 130 73 Q140 73 141 85 V30 Q141 18 151 18 Q162 18 162 30 V78 Q163 68 173 69 Q184 70 184 81 V91 Q185 82 195 84 Q206 86 206 99 V119 Q206 139 184 148 V164 Z',fill:ink,stroke:outline,'stroke-width':2.3,'stroke-linejoin':'round'}),sqSVG('path',{d:'M141 84 V108 M162 78 V102 M184 91 V110 M120 100 Q128 120 148 119 M126 146 H182 M145 32 Q151 27 157 32',fill:'none',stroke:'#815924','stroke-width':2.3,'stroke-linecap':'round'}),sqSVG('rect',{x:121,y:157,width:64,height:13,rx:3,fill:dark,stroke:outline}));g.append(h);
 }
 function skull(){
  p('M105 110 C83 77 99 38 150 37 C201 38 217 77 195 110 L181 123 V143 H119 V123 Z');
  rect(99,67,102,39,10,dark);rect(105,73,40,25,6,'#684b25');rect(155,73,40,25,6,'#684b25');p('M150 106 L142 121 H158 Z',dark);p('M133 129 V142 M146 129 V142 M159 129 V142 M172 129 V142','none',{stroke:'#62431f'});
 }
 function radio(y=0){
  rect(89,77+y,122,65,13);p('M113 '+(77+y)+' L104 '+(54+y)+' M187 '+(77+y)+' L196 '+(54+y),'none',{'stroke-width':4});circ(120,108+y,19,dark);circ(180,108+y,19,dark);p('M120 '+(108+y)+' l9 -9 M180 '+(108+y)+' l-8 6','none',{'stroke-width':4});rect(140,123+y,20,11,2,dark);
 }
 if(kind==='finger')finger();
 else if(kind==='crown'){finger(.78,12);p('M111 22 L126 36 L150 14 L174 36 L189 22 L180 48 H120 Z');}
 else if(kind==='skull')skull();
 else if(kind==='battery'){rect(105,38,90,121,12);rect(133,26,34,14,3);p('M120 82 L139 93 M180 82 L161 93 M128 125 Q150 108 172 125','none',{stroke:dark,'stroke-width':5});p('M154 44 L137 70 H153 L145 83 L170 58 H153 Z',dark);}
 else if(kind==='trophy'){p('M111 42 H189 V68 Q189 110 150 116 Q111 110 111 68 Z');p('M111 51 H86 V69 Q86 93 119 97 M189 51 H214 V69 Q214 93 181 97','none',{'stroke-width':5});rect(143,115,14,27);rect(117,141,66,14,4);finger(.36,-26);}
 else if(kind==='sofa'){rect(91,68,118,59,12);rect(77,91,29,44,9);rect(194,91,29,44,9);rect(101,110,98,26,5);p('M92 136 V149 M208 136 V149','none',{'stroke-width':5});rect(127,81,46,24,6,dark);p('M136 93 H145 M140 89 V97 M160 93 H164','none');}
 else if(kind==='warning'){p('M150 25 L221 151 H79 Z',ink);p('M150 59 V110','none',{stroke:dark,'stroke-width':11});circ(150,130,6,dark);}
 else if(kind==='skeleton'){const a=sqSVG('g',{transform:'translate(60 -2) scale(.6)'});const old=g.childNodes.length;skull();while(g.childNodes.length>old)a.append(g.childNodes[old]);g.append(a);radio(14);p('M102 93 L79 119 L94 144 M198 93 L221 119 L206 144','none',{'stroke-width':5});}
 else if(kind==='sheet'){rect(105,35,90,120,4);for(let y=58;y<150;y+=18)p('M111 '+y+' H189','none',{stroke:dark});for(let x=130;x<190;x+=20)p('M'+x+' 42 V150','none',{stroke:dark});p('M93 151 L207 38','none',{stroke:'#bd5846','stroke-width':9});}
 else if(kind==='radio'){radio();for(const d of ['M92 30 L118 68 L78 57 Z M92 30 L96 61 M92 30 L106 64','M208 29 L180 70 L222 56 Z M208 29 L204 61 M208 29 L193 63'])p(d,'none',{stroke:'#e1cba3','stroke-width':1});}
 else if(kind==='drone'){p('M107 55 L193 135 M193 55 L107 135','none',{'stroke-width':10});for(const [x,y] of [[105,55],[195,55],[105,135],[195,135]]){circ(x,y,25,dark);p('M'+(x-20)+' '+y+' H'+(x+20)+' M'+x+' '+(y-20)+' V'+(y+20),'none',{'stroke-width':3});}rect(132,77,36,36,7);rect(140,70,20,17,4,dark);}
 svg.append(g);return svg;
}
function sqRenderAdultReverse(){
 const golden=state.adultGolden===true;
 const [kind,caption]=golden?['finger','CONGRATULATIONS. NOW FUCK OFF AND FLY.']:sqAdultCards[state.card];
 const top=node('div','SQ / BLACK LABEL: UNCENSORED');top.className='sq-adult-kicker';
 const badge=node('div',golden?'THE GOLDEN FINGER / 0.5%':'18+ / COLLECTOR SERIES');badge.className='sq-adult-badge';
 const art=sqAdultArt(kind,golden);
 const copy=node('h3',caption);copy.className='sq-adult-copy';
 const foot=node('div',black.serial(state.level,state.card)+' / NO EXCUSES.');foot.className='sq-adult-kicker';
 sqReverse.classList.add('sq-adult-reverse');sqReverse.classList.toggle('sq-golden-finger',golden);
 sqReverse.replaceChildren(top,badge,art,copy,foot);
}

sqInspect.onclick=async()=>{
 if(busy||state.card===null)return;
 if(!sqCanFlip()){sqOldInspect();return;}
 const next=!sqReverseCard.classList.contains('sq-diagram-open');
 if(next)sqRenderReverse();
 if(matchMedia('(prefers-reduced-motion: reduce)').matches||typeof sqReverseCard.animate!=='function'){sqSide(next);return;}
 setBusy(true);
 try{
  await sqReverseCard.animate([{transform:'perspective(900px) rotateY(0deg)'},{transform:'perspective(900px) rotateY(90deg)'}],{duration:155,easing:'ease-in',fill:'none'}).finished;
  sqSide(next);
  await sqReverseCard.animate([{transform:'perspective(900px) rotateY(-90deg)'},{transform:'perspective(900px) rotateY(0deg)'}],{duration:190,easing:'ease-out',fill:'none'}).finished;
 }catch{sqSide(next);}finally{setBusy(false);sqInspect.focus({preventScroll:true});}
};
sqInspect.setAttribute('aria-controls','challenge-card');

sqRefresh();
