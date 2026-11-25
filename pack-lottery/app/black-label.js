'use strict';
const SQBlack=(()=>{
 const key='sq.pack-lottery.pilot.v1';
 const names=['Beginner','Intermediate','Advanced','OnlyDrones','Bench Pilot','Adults Only','Fixed Wing'];
 const codes=['BG','IN','AD','OD','BP','18','FW'];
 const awards=[
 ['shed','The Shed Escapee','Complete your first Bench Pilot challenge.',s=>s.levels[4]>=1],
 ['boy','BoyWonder Approved','Complete 10 Advanced challenges.',s=>s.levels[2]>=10],
 ['dark','Absolutely Unhinged','Complete 10 Adults Only challenges.',s=>s.levels[5]>=10],
 ['karen','Angry Karen Survivor','Complete 25 challenges.',s=>s.completed>=25],
 ['grass','Touch Grass Professional','Complete 50 challenges.',s=>s.completed>=50],
 ['pack','One... More... Pack...!','Complete 100 challenges.',s=>s.completed>=100],
 ['collector','The Collector','Discover all 60 original cards.',s=>decks.slice(0,6).every((d,l)=>d.slice(0,l<3?8:12).every((_,c)=>SQCollector.get(l,c)))],
 ['sheet','We Don’t Fly Spreadsheets','Complete 500 challenges.',s=>s.completed>=500],
 ['humble','Forever Humble','Complete 1,000 challenges.',s=>s.completed>=1000],['master','Master Collector','Discover all 100 cards.',s=>decks.slice(0,6).every((d,l)=>d.every((_,c)=>SQCollector.get(l,c)))],['wing','Wing Commander','Discover all 25 Fixed Wing cards.',s=>decks[6].every((_,c)=>SQCollector.get(6,c))],['gold','Golden Ticket','Discover a golden finish.',s=>s.totals[4]>0]];
 let pilot='';try{pilot=clean(localStorage.getItem(key)||'');}catch{}
 function clean(s){return typeof s==='string'?s.replace(/[\u0000-\u001f\u007f]/g,'').trim().slice(0,32):'';}
 function setName(s){pilot=clean(s);try{localStorage.setItem(key,pilot);}catch{}return pilot;}
 function stats(){const s=SQCollector.stats();s.levels=decks.map((d,l)=>d.reduce((sum,_,c)=>sum+(SQCollector.get(l,c)?.completed||0),0));s.awards=awards.map(([id,name,desc,test])=>({id,name,desc,unlocked:test(s)}));return s;}
 function rank(n){const xp=n*25;return xp>=3000?'FPV LEGEND':xp>=1500?'ELITE PILOT':xp>=750?'BANDO SPECIALIST':xp>=250?'FREESTYLER':'ROOKIE';}
 function serial(l,c){return 'SQ–'+codes[l]+'–'+String(c+1).padStart(2,'0');}
 const gold='#e2c481',dark='#141616';
 function wrap(ctx,text,width){const lines=[];let row='';for(const word of String(text).split(/\s+/)){const next=row?row+' '+word:word;if(row&&ctx.measureText(next).width>width){lines.push(row);row=word;}else row=next;}if(row)lines.push(row);return lines;}
 function renderImage({type,level=0,card=0,rarity='standard',hideAdult=false}){
  const passport=type==='passport',canvas=document.createElement('canvas');canvas.width=1080;canvas.height=passport?700:1350;const ctx=canvas.getContext('2d');if(!ctx)throw Error('Image export unavailable');
  const w=canvas.width,h=canvas.height,colors={standard:['#292b2b','#111313'],rare:['#394650','#14191d'],legendary:['#5b451e','#17130c'],mythical:['#493d63','#132a36'],golden:['#9f741b','#21170a']};const col=colors[rarity]||colors.standard;const g=ctx.createLinearGradient(0,0,w,h);g.addColorStop(0,col[0]);g.addColorStop(1,col[1]);ctx.fillStyle=g;ctx.fillRect(0,0,w,h);ctx.strokeStyle=gold;ctx.lineWidth=4;ctx.strokeRect(35,35,w-70,h-70);ctx.lineWidth=1;ctx.strokeRect(49,49,w-98,h-98);ctx.textAlign='center';
  const text=(s,y,size,color=gold,bold=false)=>{ctx.fillStyle=color;ctx.font=(bold?'700 ':'')+size+'px system-ui, sans-serif';ctx.fillText(s,w/2,y);};
  text('SQUADDING QUADS',110,34,gold,true);text('BLACK LABEL  /  FIELD EDITION',158,23,gold);
  const lines=(s,y,size,maxWidth,color='#f5f0e6',bold=false)=>{ctx.font=(bold?'700 ':'')+size+'px system-ui, sans-serif';const ls=wrap(ctx,s,maxWidth);ls.forEach((x,i)=>text(x,y+i*size*1.25,size,color,bold));return y+ls.length*size*1.25;};
  if(passport){const s=stats();text('PILOT PASSPORT',245,56,gold,true);let y=lines(pilot||'FIELD PILOT',325,49,860,'#f5f0e6',true);text(rank(s.completed),y+15,30);text(s.completed+' LANDED  /  '+s.discovered+'/125 CARDS',y+95,35,'#f5f0e6',true);text(s.awards.filter(a=>a.unlocked).length+'/'+awards.length+' ACHIEVEMENTS',y+150,28);}
  else{const entry=decks[level][card];text(names[level].toUpperCase(),265,40,gold,true);text(rarity.toUpperCase()+'  /  '+serial(level,card),330,30);let y=lines(hideAdult?'Adults Only card':entry[0],480,72,850,'#f5f0e6',true);lines(hideAdult?'Strong language hidden.':entry[1],y+85,44,840);text('DECK '+String(level+1).padStart(2,'0')+'  •  CARD '+String(card+1).padStart(2,'0'),h-185,29);}
  text('FPV. TESTED IN THE REAL WORLD.',h-85,27,gold,true);return canvas;
 }
 function download(blob,name){const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download=name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),30000);}
 async function exportImage(opts){const canvas=renderImage(opts);const blob=await new Promise((res,rej)=>canvas.toBlob(b=>b?res(b):rej(Error('Image generation failed')),'image/png'));download(blob,opts.type==='passport'?'SQ-Pilot-Passport.png':serial(opts.level,opts.card)+'-'+opts.rarity+'.png');}
 function backup(){return {format:'SQ-Trick-Lottery-Collection',schema:1,createdAt:new Date().toISOString(),pilot,collection:SQCollector.snapshot()};}
 function restore(b){SQCollector.restore(b);setName(b.pilot||'');return stats();}
 function exportBackup(){download(new Blob([JSON.stringify(backup(),null,2)],{type:'application/json'}),'SQ-Trick-Lottery-collection.json');}
 return {stats,rank,serial,setName,getName:()=>pilot,exportImage,backup,restore,exportBackup,names};
})();