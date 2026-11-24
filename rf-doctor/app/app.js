'use strict';
const columns=['elapsed_s','lq_pct','rssi1_dbm','rssi2_dbm','snr_db','tx_mw','rf_mode','downlink_lq_pct','rx_sample_current'];
const labels=['LQ %','RSSI 1 dBm','RSSI 2 dBm','SNR dB','TX mW','RF mode (raw)','Downlink LQ %'];
const $=id=>document.getElementById(id), logs=[null,null], pending=[0,0];
function parse(text){
 const lines=text.replace(/^\uFEFF/,'').trim().split(/\r?\n/);
 if(lines.shift().trim()!==columns.join(','))throw Error('Not an RF Doctor CSV (header mismatch).');
 if(lines.length>3700)throw Error('Too many rows.');
 let prev=-1;
 const rows=lines.filter(x=>x.trim()).map((line,i)=>{const parts=line.split(',');if(parts.length!==9)throw Error('Invalid row '+(i+2));
 const v=parts.map(s=>s.trim()===''?null:Number(s));if(v.some(x=>x!==null&&!Number.isFinite(x))||v[0]===null||v[0]<0||v[0]<=prev||![0,1].includes(v[8]))throw Error('Invalid values at row '+(i+2));prev=v[0];return v;});
 if(!rows.length)throw Error('No samples in this file.');return rows;
}
function stat(rows,i){const v=rows.map(r=>r[i]).filter(x=>x!==null);return v.length?[Math.min(...v),v.reduce((a,b)=>a+b,0)/v.length,Math.max(...v)]:null;}
const cell=(tag,t)=>{const e=document.createElement(tag);e.textContent=t;return e;};
function render(){
 const chosen=Number($('metric').value||1),active=logs.filter(Boolean),canvas=$('chart'),rect=canvas.getBoundingClientRect(),dpr=Math.min(devicePixelRatio||1,2);canvas.width=Math.max(300,Math.round(rect.width*dpr));canvas.height=Math.round(250*dpr);const ctx=canvas.getContext('2d');ctx.scale(dpr,dpr);const W=canvas.width/dpr,H=250,x=55,y=20,w=W-70,h=H-52;
 ctx.fillStyle='#151c1d';ctx.fillRect(0,0,W,H);if(!active.length)return;
 const end=Math.max(1,...active.map(l=>l.rows.at(-1)[0])),all=active.flatMap(l=>l.rows.map(r=>r[chosen]).filter(v=>v!==null));
 let lo=all.length?Math.min(...all):0,hi=all.length?Math.max(...all):1;if(chosen===1||chosen===7){lo=0;hi=100;}if(hi===lo){lo-=1;hi+=1;}
 ctx.font='12px system-ui';ctx.strokeStyle='#42514d';ctx.fillStyle='#b9c8c1';for(let k=0;k<=4;k++){const yy=y+h*k/4;ctx.beginPath();ctx.moveTo(x,yy);ctx.lineTo(x+w,yy);ctx.stroke();ctx.fillText((hi-(hi-lo)*k/4).toFixed(1),3,yy+4);}
 ctx.fillText('0s',x,H-8);ctx.fillText(end.toFixed(0)+'s',Math.max(x,x+w-50),H-8);
 logs.forEach((l,j)=>{if(!l)return;ctx.strokeStyle=j?'#6bd9ed':'#dfbf80';ctx.lineWidth=2;ctx.beginPath();let last=null;for(const r of l.rows){const v=r[chosen];if(v===null){last=null;continue;}const px=x+w*r[0]/end,py=y+h*(hi-v)/(hi-lo);if(last!==null&&r[0]-last<=1.5)ctx.lineTo(px,py);else {ctx.moveTo(px,py);ctx.lineTo(px+.5,py);}last=r[0];}ctx.stroke();});
 const table=$('summary');table.replaceChildren();const header=document.createElement('tr');['Session','Sensor','Min','Mean','Max'].forEach(t=>header.append(cell('th',t)));table.append(header);
 logs.forEach((l,j)=>{if(!l)return;const meta=document.createElement('tr');const item=cell('td',(j?'B':'A')+' · '+l.name+' · '+l.rows.length+' samples · '+l.rows.filter(r=>r[8]===0).length+' RX gaps');item.colSpan=5;meta.append(item);table.append(meta);labels.forEach((name,i)=>{const r=document.createElement('tr'),s=stat(l.rows,i+1);[j?'B':'A',name,...(s?s.map(x=>x.toFixed(1)):['—','—','—'])].forEach(v=>r.append(cell('td',v)));table.append(r);});});
}
labels.forEach((l,i)=>{const o=document.createElement('option');o.value=i+1;o.textContent=l;$('metric').append(o);});
['a','b'].forEach((id,i)=>$(id).onchange=async()=>{const file=$(id).files[0],ticket=++pending[i];if(!file){logs[i]=null;render();return;}try{if(file.size>2000000)throw Error('File exceeds 2 MB.');const rows=parse(await file.text());if(ticket!==pending[i])return;logs[i]={name:file.name,rows};$('status').textContent='Loaded '+file.name;render();}catch(e){if(ticket!==pending[i])return;logs[i]=null;$('status').textContent=e.message;render();}});
$('demo').onclick=()=>{pending[0]++;pending[1]++;for(let j=0;j<2;j++)logs[j]={name:'SYNTHETIC DEMO '+(j?'B':'A'),rows:Array.from({length:60},(_,i)=>[i,i===30?null:Math.round(98-20*Math.exp(-((i-32-j*7)**2)/30)),i===30?null:-65-i*.45-j*3,null,8-i*.18,250,3,99,i===30?0:1])};$('status').textContent='Synthetic illustration — not actual radio test data.';render();};
$('metric').onchange=render;window.addEventListener('resize',render);
