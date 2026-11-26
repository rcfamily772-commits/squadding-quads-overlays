(()=>{"use strict";
const $=id=>document.getElementById(id), dash=$("dash");
let mode="ready",start=0,elapsed=0,last=0,stats={},used=0,live={speed:0,volt:25.2,amp:0,lq:100,rssi:-52,alt:0,mah:null};
let history=[],histAt=-Infinity,speedSum=0,speedN=0,best=null,packs=0,newBest=false;
let page=1,firstVolt=null,endVolt=null,flightAircraft="",storeOK=true,logs={},gpsMissing=false;
const storageKey="sq-pilot-dash-demo-v14";
try{const raw=localStorage.getItem(storageKey);if(raw){const parsed=JSON.parse(raw);if(parsed&&typeof parsed==="object"&&!Array.isArray(parsed))logs=parsed;}}catch(e){storeOK=false;}
const name=()=>$("aircraft").value.trim().slice(0,32)||"Aircraft";
const rowsFor=n=>Object.prototype.hasOwnProperty.call(logs,n)&&Array.isArray(logs[n])?logs[n]:[];
const altitude=v=>v==null?null:v*($("altUnits").value==="ft"?3.28084:1);
const duration=v=>String(Math.floor(v/60)).padStart(2,"0")+":"+String(Math.floor(v%60)).padStart(2,"0");
function saveDemo(){const n=flightAircraft;const r={date:new Date().toISOString(),duration:elapsed,...stats,avg:speedN?speedSum/speedN:null,endV:endVolt,partial:gpsMissing};Object.defineProperty(logs,n,{value:[r,...rowsFor(n)].slice(0,500),writable:true,enumerable:true,configurable:true});try{localStorage.setItem(storageKey,JSON.stringify(logs));storeOK=true;}catch(e){storeOK=false;}}
function cell(label,value){const el=document.createElement("div");el.className="metric";const small=document.createElement("small");small.textContent=label;const b=document.createElement("b");b.textContent=value;el.append(small,b);return el;}
function alternate(d,report,mph){
 $("performance").hidden=page!==1;$("alternate").hidden=page===1;
 $("aircraftName").textContent=name();$("pageName").textContent=["","PERFORMANCE","ESSENTIALS","BATTERY PERFORMANCE","AIRCRAFT LOGBOOK"][page];
 if(page===1)return;
 const factor=mph?.621371:1,unit=mph?" mph":" km/h",au=" "+$("altUnits").value;
 const speed=v=>fmt(v==null?null:v*factor,0,unit);
 let vals=[],rows=[];
 if(page===2)vals=[[report?"PEAK SPEED":"GPS SPEED",speed(d.speed)],[report?"MAX ALTITUDE":"ALTITUDE",fmt(altitude(d.alt),0,au)],[report?"MIN PACK":"PACK VOLTAGE",fmt(d.volt,2," V")],[report?"MIN LINK":"LINK QUALITY",fmt(d.lq,0,"%")],["ARM TIME",duration(elapsed)],[report?"PEAK POWER":"POWER",fmt(d.watts,0," W")]];
 if(page===3)vals=[[report?"MIN PACK":"LIVE PACK",fmt(d.volt,2," V")],[report?"LAST ARMED VOLT":"MIN PACK",fmt(report?endVolt:stats.volt,2," V")],["DROP FROM FIRST",fmt(firstVolt==null||stats.volt==null?null:Math.max(0,firstVolt-stats.volt),2," V")],[report?"PEAK CURRENT":"CURRENT",fmt(d.amp,1," A")],["OBSERVED mAh",fmt(d.mah)],[report?"PEAK POWER":"POWER",fmt(d.watts,0," W")]];
 if(page===4){rows=rowsFor(name());const valid=rows.filter(r=>r&&Number.isFinite(r.duration));const speeds=valid.filter(r=>!r.partial&&Number.isFinite(r.speed)).map(r=>r.speed);const powers=valid.filter(r=>Number.isFinite(r.watts)).map(r=>r.watts);vals=[["SAVED FLIGHTS",String(valid.length)],["AIRCRAFT BEST SPEED",speed(speeds.length?Math.max(...speeds):null)],["TOTAL ARM TIME",duration(valid.reduce((a,r)=>a+r.duration,0))],["PEAK POWER",fmt(powers.length?Math.max(...powers):null,0," W")]];}
 $("altMetrics").replaceChildren(...vals.map(v=>cell(...v)));$("logrows").replaceChildren();
 for(const r of rows.slice(0,8)){if(!r||!Number.isFinite(r.duration))continue;const el=document.createElement("div");el.className="logentry";const a=document.createElement("span"),b=document.createElement("span");a.textContent=String(r.date).slice(0,16).replace("T"," ")+(r.partial?" *":"");b.textContent=duration(r.duration)+" | "+speed(r.speed);el.append(a,b);$("logrows").append(el);}
 $("logstatus").textContent=page===4?(storeOK?"LOCAL DEMO HISTORY / LAST 8 SHOWN / 500 PER AIRCRAFT":"LOCAL STORAGE UNAVAILABLE / MEMORY ONLY"):"";
}
const extrema={watts:Math.max,speed:Math.max,volt:Math.min,amp:Math.max,lq:Math.min,rssi:Math.min,alt:Math.max,mah:Math.max};
const fmt=(v,d=0,s="")=>v==null?"—":v.toFixed(d)+s;
function render(){const report=mode==="report",d=report?stats:live, mph=$("units").value==="mph";
dash.classList.toggle("report",report);
const velocity=$("palette").value==="#23ddfa";dash.classList.toggle("velocity",velocity);
$("dashbrand").textContent=velocity?"SQ / VELOCITY":"SQ / PILOT DASH";
$("heroTimerLabel").textContent=report?"LAST FLIGHT / ARM TIME":"FLIGHT TIME";$("heroTimer").textContent=duration(elapsed);
$("vPowerLabel").textContent=report?"PEAK POWER":"POWER";$("vPower").textContent=fmt(d.watts,0," W");
$("vAltLabel").textContent=report?"MAX ALT":"ALTITUDE";$("vAlt").textContent=fmt(altitude(d.alt),0," "+$("altUnits").value);
$("peakSpeed").textContent=fmt(stats.speed==null?null:stats.speed*(mph?.621371:1),0,mph?" mph":" km/h");
$("peakAlt").textContent=fmt(altitude(stats.alt),0," "+$("altUnits").value);
$("footerRight").textContent=velocity&&page===1?fmt(d.mah,0," mAh"):"READ ONLY";
$("nativeScreen").hidden=!velocity||page!==1;
const nu=mph?" mph":" km/h",au=" "+$("altUnits").value,fac=mph?.621371:1;
const set=(id,val)=>$(id).textContent=val;
set("nTimerLabel",report?"LAST ARM TIME":"ARM TIME");set("nTimer",duration(elapsed));set("nState",report?"LAST FLIGHT":mode==="flight"?"ARM INPUT ON":"STANDBY");set("nPack","PACK "+String(packs+(mode==="flight"?1:0)).padStart(2,"0"));
for(const [id,label,peak] of [["nVoltLabel","VOLT","MIN V"],["nAmpLabel","AMPS","MAX A"],["nPowerLabel","POWER","MAX W"],["nLqLabel","LINK","MIN LQ"],["nRssiLabel","RSSI","MIN RF"],["nAltLabel","ALT","MAX ALT"],["nSpeedLabel","GPS SPEED","PEAK SPEED"]])set(id,report?peak:label);
for(let i=0;i<linkBars.length;i++)linkBars[i].setAttribute("fill",d.lq!=null&&i<Math.round(d.lq*4/100)?"#58e0a4":"#284554");
set("nVolt",fmt(d.volt,2," V"));set("nAmp",fmt(d.amp,1," A"));set("nPower",fmt(d.watts,0," W"));set("nLq",fmt(d.lq,0,"%"));set("nRssi",fmt(d.rssi,0," dBm"));set("nAlt",fmt(altitude(d.alt),0,au));set("nSpeed",fmt(d.speed==null?null:d.speed*fac));set("nUnit",nu.trim());
set("nPeakSpeed",fmt(stats.speed==null?null:stats.speed*fac,0,nu));set("nPeakAlt",fmt(altitude(stats.alt),0,au));set("nUsed",fmt(d.mah,0," mAh"));
set("nFoot",report?"REPORT FROZEN / RE-ARM":$("missing").checked?"GPS DATA UNAVAILABLE":"BLACK LABEL / V1.7");
const nmax=Math.max(1,...history.filter(v=>v!=null));let np="",nprev=false;history.forEach((v,i)=>{if(v==null){nprev=false;return;}np+=(nprev?"L":"M")+(13+i*454/35).toFixed(1)+" "+(218-v/nmax*13).toFixed(1)+" ";nprev=true;});$("nTrace").setAttribute("d",np);set("nTraceMax",history.some(v=>v!=null)?fmt(nmax*fac,0,nu):"—");
for(let i=0;i<nativeTicks.length;i++)nativeTicks[i].setAttribute("stroke",d.speed!=null&&i/31<=Math.min(1,d.speed/180)?"var(--glow)":"#124456");

dash.style.setProperty("--glow",report?"#ebc16d":$("palette").value);
$("state").textContent=report?"LAST FLIGHT":mode==="flight"?"ARM INPUT ON":"STANDBY";
for(const [id,a,b] of [["speedLabel","GPS SPEED","PEAK SPEED"],["voltLabel","PACK VOLTAGE","MIN PACK"],["ampLabel","CURRENT","PEAK CURRENT"],["lqLabel","LINK QUALITY","MIN LINK"],["rssiLabel","RSSI dBm","WEAKEST RSSI"],["altLabel","ALTITUDE","MAX ALT"]])$(id).textContent=report?b:a;
$("speed").textContent=fmt(d.speed==null?null:d.speed*(mph?.621371:1));$("speedUnit").textContent=mph?"mph":"km/h";
$("arc").setAttribute("stroke-dasharray",Math.min(100,Math.max(0,(d.speed??0)/180*100))+" 100");
$("volt").textContent=fmt(d.volt,1," V");$("amp").textContent=fmt(d.amp,1," A");$("lq").textContent=fmt(d.lq,0,"%");$("rssi").textContent=fmt(d.rssi);$("alt").textContent=fmt(altitude(d.alt),0," "+$("altUnits").value);$("mah").textContent=fmt(d.mah);
$("cell").textContent=fmt(d.volt==null?null:d.volt/6,2," V/c");$("powerLabel").textContent=report?"PEAK POWER":"POWER";$("power").textContent=fmt(d.watts,0," W");
const scale=mph?.621371:1,unit=mph?" mph":" km/h";
$("best").textContent=fmt(best==null?null:best*scale,0,unit);$("avg").textContent=fmt(speedN?speedSum/speedN*scale:null,0,unit);
$("pack").textContent="PACK "+String(packs+(mode==="flight"?1:0)).padStart(2,"0");
$("recordLabel").textContent=report&&newBest?"NEW SESSION BEST":"SESSION RECORDS";
const maxSpeed=Math.max(1,...history.filter(v=>v!=null));let p="",prev=false;
history.forEach((v,i)=>{if(v==null){prev=false;return;}p+=(prev?"L":"M")+(i*320/35).toFixed(1)+" "+(61-v/maxSpeed*53).toFixed(1)+" ";prev=true;});$("trace").setAttribute("d",p);
$("time").textContent=String(Math.floor(elapsed/60)).padStart(2,"0")+":"+String(Math.floor(elapsed%60)).padStart(2,"0");
$("foot").textContent=report?"REPORT FROZEN / RE-ARM TO RESET":$("missing").checked?"GPS DATA UNAVAILABLE":"BLACK LABEL / V1.7";
$("arm").disabled=mode==="flight";$("disarm").disabled=mode!=="flight";$("aircraft").disabled=mode==="flight";alternate(d,report,mph);}
function sample(now){if(mode!=="flight")return;let dt=Math.min(.5,Math.max(0,(now-last)/1000));last=now;elapsed=(now-start)/1000;let t=+$("throttle").value/100;
let speed=Math.max(0,t*165+Math.sin(elapsed*1.1)*t*11),amp=t*96+Math.max(0,Math.sin(elapsed*2))*t*9;used+=amp*dt/3.6;
live={speed:$("missing").checked?null:speed,volt:Math.max(19,25.2-t*1.9-used*.004),amp,lq:Math.max(0,100-Math.round(t*5+Math.max(0,Math.sin(elapsed*.5))*3)),rssi:-52-t*24-Math.sin(elapsed*.7)*3,alt:t*45+Math.sin(elapsed*.65)*t*9,mah:used};
live.watts=live.volt*live.amp;if(firstVolt==null)firstVolt=live.volt;endVolt=live.volt;if(live.speed==null)gpsMissing=true;if(live.speed!=null){speedSum+=live.speed;speedN++;}if(now-histAt>=1000){histAt=now;history.push(live.speed);if(history.length>36)history.shift();}
for(const k in extrema)if(live[k]!=null)stats[k]=stats[k]==null?live[k]:extrema[k](stats[k],live[k]);}
$("arm").onclick=()=>{mode="flight";flightAircraft=name();firstVolt=endVolt=null;gpsMissing=false;stats={};history=[];histAt=-Infinity;speedSum=speedN=0;newBest=false;used=0;elapsed=0;start=last=performance.now();sample(start);render();};
$("disarm").onclick=()=>{sample(performance.now());mode="report";packs++;newBest=stats.speed!=null&&(best==null||stats.speed>best);if(newBest)best=stats.speed;saveDemo();render();};
$("reset").onclick=()=>{mode="ready";firstVolt=endVolt=null;stats={};history=[];histAt=-Infinity;speedSum=speedN=0;best=null;packs=0;newBest=false;used=elapsed=0;live={speed:0,volt:25.2,amp:0,lq:100,rssi:-52,alt:0,mah:null};render();};
for(const id of ["palette","units","altUnits","missing","aircraft"])$(id).onchange=()=>{if(mode==="ready")live.speed=$("missing").checked?null:0;render();};
for(let i=0;i<33;i++){const a=(135+i*270/32)*Math.PI/180,r=i%4===0?75:81,el=document.createElementNS("http://www.w3.org/2000/svg","line");for(const [k,v] of Object.entries({x1:110+r*Math.cos(a),y1:90+r*Math.sin(a),x2:110+87*Math.cos(a),y2:90+87*Math.sin(a),stroke:"#91b5c7","stroke-width":i%4===0?2:1}))el.setAttribute(k,v);$("ticks").append(el);}
const linkBars=Array.from($("nLinkBars").children);const nativeTicks=[];for(let i=0;i<32;i++){const a=(135+i*270/31)*Math.PI/180,r=i%4===0?51:54,el=document.createElementNS("http://www.w3.org/2000/svg","line");for(const [k,v] of Object.entries({x1:240+r*Math.cos(a),y1:116+r*Math.sin(a),x2:240+61*Math.cos(a),y2:116+61*Math.sin(a),stroke:"#124456","stroke-width":3.2,"stroke-linecap":"round"}))el.setAttribute(k,v);$("nTicks").append(el);nativeTicks.push(el);}
for(const b of document.querySelectorAll("[data-page]"))b.onclick=()=>{page=+b.dataset.page;for(const x of document.querySelectorAll("[data-page]"))x.setAttribute("aria-pressed",String(x===b));render();};
$("exportLog").onclick=()=>{const fields=["date","duration","speed","avg","alt","volt","amp","watts","mah","lq","rssi","endV","partial"];const csv=fields.join(",")+"\n"+rowsFor(name()).map(r=>fields.map(k=>r[k]??"").join(",")).join("\n");const url=URL.createObjectURL(new Blob([csv],{type:"text/csv"}));const a=document.createElement("a");a.href=url;a.download="SQ_Pilot_Dash_demo.csv";a.click();setTimeout(()=>URL.revokeObjectURL(url),10000);};
setInterval(()=>{if(mode==="flight"){sample(performance.now());render();}},150);
render();
// Standard uncompressed ZIP; generated from the same published Lua source.
function zip(name,bytes){const n=new TextEncoder().encode(name);let crc=0xffffffff;for(const b of bytes){crc^=b;for(let j=0;j<8;j++)crc=(crc>>>1)^((crc&1)?0xedb88320:0);}crc=(crc^0xffffffff)>>>0;
const a=new Uint8Array(30+n.length+bytes.length+46+n.length+22),v=new DataView(a.buffer);let p=0;
const u16=x=>{v.setUint16(p,x,true);p+=2;},u32=x=>{v.setUint32(p,x,true);p+=4;},put=x=>{a.set(x,p);p+=x.length;};
u32(0x04034b50);u16(20);u16(0);u16(0);u16(0);u16(0x21);u32(crc);u32(bytes.length);u32(bytes.length);u16(n.length);u16(0);put(n);put(bytes);
const cd=p;u32(0x02014b50);u16(20);u16(20);u16(0);u16(0);u16(0);u16(0x21);u32(crc);u32(bytes.length);u32(bytes.length);u16(n.length);u16(0);u16(0);u16(0);u16(0);u32(0);u32(0);put(n);
const size=p-cd;u32(0x06054b50);u16(0);u16(0);u16(1);u16(1);u32(size);u32(cd);u16(0);return a;}
$("download").onclick=async()=>{const b=$("download"),s=$("downloadstatus");b.disabled=true;s.textContent="Preparing ZIP…";try{const r=await fetch("WIDGETS/SQDash/main.lua",{cache:"no-cache"});if(!r.ok)throw Error("Source unavailable");const data=new Uint8Array(await r.arrayBuffer());if(!new TextDecoder().decode(data).startsWith("-- SQ Pilot Dash v1.7"))throw Error("Unexpected source");const url=URL.createObjectURL(new Blob([zip("WIDGETS/SQDash/main.lua",data)],{type:"application/zip"}));const a=document.createElement("a");a.href=url;a.download="SQ_Pilot_Dash_v1.7.zip";a.click();setTimeout(()=>URL.revokeObjectURL(url),10000);s.textContent="ZIP prepared. Extract to the SD card root.";}catch(e){s.textContent="ZIP unavailable. Use the Lua source link above.";}finally{b.disabled=false;}};
})();