(()=>{"use strict";
const $=id=>document.getElementById(id), dash=$("dash");
let mode="ready",start=0,elapsed=0,last=0,stats={},used=0,live={speed:0,volt:25.2,amp:0,lq:100,rssi:-52,alt:0,mah:null};
const extrema={speed:Math.max,volt:Math.min,amp:Math.max,lq:Math.min,rssi:Math.min,alt:Math.max,mah:Math.max};
const fmt=(v,d=0,s="")=>v==null?"—":v.toFixed(d)+s;
function render(){const report=mode==="report",d=report?stats:live, mph=$("units").value==="mph";
dash.classList.toggle("report",report);dash.style.setProperty("--glow",report?"#ebc16d":$("palette").value);
$("state").textContent=report?"LAST FLIGHT":mode==="flight"?"ARM INPUT ON":"STANDBY";
for(const [id,a,b] of [["speedLabel","GPS SPEED","PEAK SPEED"],["voltLabel","PACK VOLTAGE","MIN PACK"],["ampLabel","CURRENT","PEAK CURRENT"],["lqLabel","LINK QUALITY","MIN LINK"],["rssiLabel","RSSI dBm","WEAKEST RSSI"],["altLabel","ALTITUDE","MAX ALT"]])$(id).textContent=report?b:a;
$("speed").textContent=fmt(d.speed==null?null:d.speed*(mph?.621371:1));$("speedUnit").textContent=mph?"mph":"km/h";
$("arc").setAttribute("stroke-dasharray",Math.min(100,Math.max(0,(d.speed??0)/180*100))+" 100");
$("volt").textContent=fmt(d.volt,1," V");$("amp").textContent=fmt(d.amp,1," A");$("lq").textContent=fmt(d.lq,0,"%");$("rssi").textContent=fmt(d.rssi);$("alt").textContent=fmt(d.alt,0," m");$("mah").textContent=fmt(d.mah);
$("cell").textContent=fmt(d.volt==null?null:d.volt/6,2," V/c");$("pc").textContent=fmt(d.volt==null?null:d.volt/6,2," V");
$("time").textContent=String(Math.floor(elapsed/60)).padStart(2,"0")+":"+String(Math.floor(elapsed%60)).padStart(2,"0");
$("foot").textContent=report?"REPORT FROZEN / RE-ARM TO RESET":$("missing").checked?"GPS DATA UNAVAILABLE":"BLACK LABEL / V1.1";
$("arm").disabled=mode==="flight";$("disarm").disabled=mode!=="flight";}
function sample(now){if(mode!=="flight")return;let dt=Math.min(.5,Math.max(0,(now-last)/1000));last=now;elapsed=(now-start)/1000;let t=+$("throttle").value/100;
let speed=Math.max(0,t*165+Math.sin(elapsed*1.1)*t*11),amp=t*96+Math.max(0,Math.sin(elapsed*2))*t*9;used+=amp*dt/3.6;
live={speed:$("missing").checked?null:speed,volt:Math.max(19,25.2-t*1.9-used*.004),amp,lq:Math.max(0,100-Math.round(t*5+Math.max(0,Math.sin(elapsed*.5))*3)),rssi:-52-t*24-Math.sin(elapsed*.7)*3,alt:t*45+Math.sin(elapsed*.65)*t*9,mah:used};
for(const k in extrema)if(live[k]!=null)stats[k]=stats[k]==null?live[k]:extrema[k](stats[k],live[k]);}
$("arm").onclick=()=>{mode="flight";stats={};used=0;elapsed=0;start=last=performance.now();sample(start);render();};
$("disarm").onclick=()=>{sample(performance.now());mode="report";render();};
$("reset").onclick=()=>{mode="ready";stats={};used=elapsed=0;live={speed:0,volt:25.2,amp:0,lq:100,rssi:-52,alt:0,mah:null};render();};
for(const id of ["palette","units","missing"])$(id).onchange=()=>{if(mode==="ready")live.speed=$("missing").checked?null:0;render();};
for(let i=0;i<25;i++){const a=(135+i*270/24)*Math.PI/180,r=i%4===0?75:81,el=document.createElementNS("http://www.w3.org/2000/svg","line");for(const [k,v] of Object.entries({x1:110+r*Math.cos(a),y1:90+r*Math.sin(a),x2:110+87*Math.cos(a),y2:90+87*Math.sin(a),stroke:"#91b5c7","stroke-width":i%4===0?2:1}))el.setAttribute(k,v);$("ticks").append(el);}
setInterval(()=>{if(mode==="flight"){sample(performance.now());render();}},150);
render();
// Standard uncompressed ZIP; generated from the same published Lua source.
function zip(name,bytes){const n=new TextEncoder().encode(name);let crc=0xffffffff;for(const b of bytes){crc^=b;for(let j=0;j<8;j++)crc=(crc>>>1)^((crc&1)?0xedb88320:0);}crc=(crc^0xffffffff)>>>0;
const a=new Uint8Array(30+n.length+bytes.length+46+n.length+22),v=new DataView(a.buffer);let p=0;
const u16=x=>{v.setUint16(p,x,true);p+=2;},u32=x=>{v.setUint32(p,x,true);p+=4;},put=x=>{a.set(x,p);p+=x.length;};
u32(0x04034b50);u16(20);u16(0);u16(0);u16(0);u16(0x21);u32(crc);u32(bytes.length);u32(bytes.length);u16(n.length);u16(0);put(n);put(bytes);
const cd=p;u32(0x02014b50);u16(20);u16(20);u16(0);u16(0);u16(0);u16(0x21);u32(crc);u32(bytes.length);u32(bytes.length);u16(n.length);u16(0);u16(0);u16(0);u16(0);u32(0);u32(0);put(n);
const size=p-cd;u32(0x06054b50);u16(0);u16(0);u16(1);u16(1);u32(size);u32(cd);u16(0);return a;}
$("download").onclick=async()=>{const b=$("download"),s=$("downloadstatus");b.disabled=true;s.textContent="Preparing ZIP…";try{const r=await fetch("WIDGETS/SQDash/main.lua",{cache:"no-cache"});if(!r.ok)throw Error("Source unavailable");const data=new Uint8Array(await r.arrayBuffer());if(!new TextDecoder().decode(data).startsWith("-- SQ Pilot Dash v1.1"))throw Error("Unexpected source");const url=URL.createObjectURL(new Blob([zip("WIDGETS/SQDash/main.lua",data)],{type:"application/zip"}));const a=document.createElement("a");a.href=url;a.download="SQ_Pilot_Dash_v1.1.zip";a.click();setTimeout(()=>URL.revokeObjectURL(url),10000);s.textContent="ZIP prepared. Extract to the SD card root.";}catch(e){s.textContent="ZIP unavailable. Use the Lua source link above.";}finally{b.disabled=false;}};
})();