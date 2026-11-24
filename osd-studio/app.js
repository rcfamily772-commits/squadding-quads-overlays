'use strict';
const $=id=>document.getElementById(id);
let firmware=null,sourceName='',demo=false,ticket=0,output=null;
const status=(s,kind='')=>{$('status').textContent=s;$('status').dataset.kind=kind;};
const dl=(content,type,name)=>{const a=document.createElement('a'),url=URL.createObjectURL(new Blob([content],{type}));a.href=url;a.download=name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),30000);};
function clearOutput(){output=null;$('download').disabled=true;$('report').disabled=true;$('diff').replaceChildren();}
function show(input,name,isDemo){clearOutput();firmware=SQHex.parse(input);sourceName=name;demo=isDemo;const info=SQHex.inspect(firmware);$('filename').textContent=name;$('bytes').textContent=firmware.count.toLocaleString()+' bytes';$('range').textContent=SQHex.address(firmware.first)+' – '+SQHex.address(firmware.last);$('matches').textContent=String(info.hits.length);$('markers').textContent=[...info.markers,...info.stats].join(' · ')||'None';$('location').textContent=info.candidate===null?'—':SQHex.address(info.candidate);$('patch').disabled=!info.allowed;$('ack').checked=false;status(info.allowed?(demo?'Synthetic demo loaded. HEX download is disabled.':'Candidate found. Binary identity is not proven; bench test only.'):info.reason,info.allowed?'ok':'error');}
$('file').onchange=async()=>{const file=$('file').files[0],id=++ticket;firmware=null;clearOutput();$('patch').disabled=true;if(!file)return;try{if(file.size>12*1024*1024)throw Error('File exceeds 12 MiB.');const text=await file.text();if(id!==ticket)return;show(text,file.name,false);}catch(e){if(id===ticket)status(e.message,'error');}};
$('demo').onclick=()=>{++ticket;$('file').value='';try{show(SQHex.fixture(),'SYNTHETIC DEMO — NOT FIRMWARE',true);}catch(e){status(e.message,'error');}};
$('replacement').oninput=()=>{const t=$('replacement').value.toUpperCase();$('replacement').value=t;$('counter').textContent=t.length+'/13';$('preview-text').textContent=t.padEnd(13,' ');clearOutput();};
$('ack').onchange=()=>{if(output)$('download').disabled=demo||!$('ack').checked;};
$('patch').onclick=()=>{clearOutput();try{if(!firmware)throw Error('Load an image first.');output=SQHex.patch(firmware,$('replacement').value);for(const c of output.changed){const row=document.createElement('tr');for(const v of [c.address,c.before,c.after]){const td=document.createElement('td');td.textContent=v;row.append(td);}$('diff').append(row);} $('download').disabled=demo||!$('ack').checked;$('report').disabled=false;status('Verified '+output.changed.length+' changed data bytes at '+output.start+'. All other bytes and non-data records unchanged.'+(demo?' Demo cannot be flashed.':''),'ok');}catch(e){status(e.message,'error');}};
$('download').onclick=()=>{if(!output||demo||!$('ack').checked)return;dl(output.output,'text/plain',sourceName.replace(/\.hex$/i,'')+'-SQ-OSD-EXPERIMENTAL.hex');};
$('report').onclick=()=>{if(output)dl(JSON.stringify({tool:'SQ OSD Studio v1.0',source:sourceName,synthetic:demo,scope:'post-flight statistics heading only',before:SQHex.original,after:output.text,start:output.start,changes:output.changed,warning:'Intel HEX integrity verified, firmware execution and hardware compatibility not verified.'},null,2),'application/json','SQ-OSD-patch-report.json');};
// Exact 288x72, three-colour logo canvas. All operations stay in the browser.
const canvas=$('logo'),ctx=canvas.getContext('2d',{willReadFrequently:true});ctx.imageSmoothingEnabled=false;
const palette={transparent:'#00ff00',white:'#ffffff',black:'#000000'};
let drawing=false,prev=null,history=[];
function snap(){history.push(ctx.getImageData(0,0,288,72));if(history.length>20)history.shift();}
function clear(){ctx.fillStyle=palette.transparent;ctx.fillRect(0,0,288,72);}
clear();
function pixel(x,y){const size=Number($('brush').value);ctx.fillStyle=palette[$('ink').value];ctx.fillRect(Math.max(0,x-Math.floor(size/2)),Math.max(0,y-Math.floor(size/2)),size,size);}
function coords(e){const r=canvas.getBoundingClientRect();return [Math.min(287,Math.max(0,Math.floor((e.clientX-r.left)*288/r.width))),Math.min(71,Math.max(0,Math.floor((e.clientY-r.top)*72/r.height)))];}
function line(a,b){const dx=b[0]-a[0],dy=b[1]-a[1],steps=Math.max(Math.abs(dx),Math.abs(dy),1);for(let i=0;i<=steps;i++)pixel(Math.round(a[0]+dx*i/steps),Math.round(a[1]+dy*i/steps));}
canvas.onpointerdown=e=>{snap();drawing=true;prev=coords(e);pixel(...prev);canvas.setPointerCapture(e.pointerId);};
canvas.onpointermove=e=>{if(drawing){const p=coords(e);line(prev,p);prev=p;}};
canvas.onpointerup=canvas.onpointercancel=()=>{drawing=false;prev=null;};
$('clear-logo').onclick=()=>{snap();clear();};$('undo').onclick=()=>{if(history.length)ctx.putImageData(history.pop(),0,0);};
function quantize(){const img=ctx.getImageData(0,0,288,72);for(let i=0;i<img.data.length;i+=4){let [r,g,b,a]=img.data.subarray(i,i+4),c=a<128||g>r+60&&g>b+60?[0,255,0]:(r+g+b)/3>=128?[255,255,255]:[0,0,0];img.data.set([...c,255],i);}ctx.putImageData(img,0,0);}
$('add-text').onclick=()=>{const text=$('logo-text').value.toUpperCase().slice(0,40);if(!text.trim())return;snap();ctx.textAlign='center';ctx.textBaseline='middle';ctx.font='bold '+Number($('font-size').value)+'px monospace';ctx.fillStyle=palette[$('ink').value];ctx.fillText(text,144,36,280);quantize();};
$('preset').onclick=()=>{snap();clear();ctx.fillStyle='#000';ctx.fillRect(12,8,264,56);ctx.strokeStyle='#fff';ctx.strokeRect(14.5,10.5,259,51);ctx.fillStyle='#fff';ctx.font='bold 25px monospace';ctx.textAlign='center';ctx.textBaseline='middle';ctx.fillText('SQUADDING QUADS',144,29,248);ctx.font='bold 12px monospace';ctx.fillText('TESTED IN THE REAL WORLD',144,49,246);quantize();};
$('save-logo').onclick=()=>{quantize();canvas.toBlob(b=>{if(!b)return;const a=document.createElement('a'),url=URL.createObjectURL(b);a.href=url;a.download='SQ-custom-OSD-logo-288x72.png';document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),30000);},'image/png');};
$('replacement').dispatchEvent(new Event('input'));