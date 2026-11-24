'use strict';
// Intel HEX record validation and address-preserving cosmetic patching.
const SQHex=(()=>{
 const MAX_BYTES=4*1024*1024,MAX_LINES=300000,MAX_TEXT=12*1024*1024;
 const original="--- STATS ---";
 const hex=(n,w=2)=>n.toString(16).toUpperCase().padStart(w,'0');
 const address=n=>'0x'+hex(n,8);
 function record(type,offset,data){const b=[data.length,offset>>8,offset&255,type,...data];return ':'+b.map(x=>hex(x)).join('')+hex((-b.reduce((a,v)=>a+v,0))&255);}
 function parse(input){
  if(typeof input!=='string'||input.length>MAX_TEXT)throw Error('File too large (12 MiB text limit).');
  const lines=input.replace(/^\uFEFF/,'').split(/\r?\n/);if(lines.length>MAX_LINES)throw Error('Too many HEX records.');
  const records=[],map=new Map();let base=0,eof=false,count=0,first=Infinity,last=-1;
  for(let i=0;i<lines.length;i++){
   const line=lines[i].trim();if(!line)continue;if(eof)throw Error('Data after EOF at line '+(i+1));
   if(!/^:(?:[0-9a-fA-F]{2})+$/.test(line)||line.length<11)throw Error('Invalid Intel HEX at line '+(i+1));
   const a=[];for(let j=1;j<line.length;j+=2)a.push(parseInt(line.slice(j,j+2),16));
   const [len,hi,lo,type]=a,offset=hi*256+lo,data=a.slice(4,-1);
   if(a.length!==len+5||(a.reduce((s,x)=>s+x,0)&255)!==0)throw Error('Length/checksum mismatch at line '+(i+1));
   const r={type,offset,data,base,line:i+1,raw:line};records.push(r);
   if(type===0){if(offset+len>65536)throw Error('Record crosses address boundary.');for(let j=0;j<len;j++){const loc=base+offset+j;if(loc>0xFFFFFFFF||map.has(loc))throw Error('Overlapping or invalid address '+address(loc));map.set(loc,data[j]);first=Math.min(first,loc);last=Math.max(last,loc);if(++count>MAX_BYTES)throw Error('Decoded data exceeds 4 MiB.');}}
   else if(type===1){if(len!==0||offset!==0)throw Error('Invalid EOF');eof=true;}
   else if(type===2||type===4){if(len!==2||offset!==0)throw Error('Invalid extended address record');base=(data[0]*256+data[1])*(type===2?16:65536);}
   else if(type===3||type===5){if(len!==4||offset!==0)throw Error('Invalid start address record');}
   else throw Error('Unsupported record type '+type);
  }
  if(!eof||!count)throw Error('Missing EOF or data.');return {records,map,count,first,last};
 }
 function find(f,text,terminated=false){const bytes=Array.from(text,c=>c.charCodeAt(0));const result=[];for(const [a,v] of f.map){if(v!==bytes[0])continue;let ok=true;for(let j=1;j<bytes.length;j++)if(f.map.get(a+j)!==bytes[j]){ok=false;break;}if(ok&&(!terminated||f.map.get(a+bytes.length)===0))result.push(a);}return result.sort((a,b)=>a-b);}
 function inspect(f){
  const hits=find(f,original,true),markers=['BTFL','Betaflight','BETAFLIGHT'].filter(x=>find(f,x,true).length);
  const stats=['MIN BATTERY','MAX CURRENT','TOTAL FLIGHTS','USED MAH','MAX SPEED','MIN RSSI','MIN LINK'].filter(x=>find(f,x,true).length);
  const stm=f.first>=0x08000000&&f.last<0x0A000000;
  const candidate=hits.length===1?hits[0]:null;
  const prev=candidate===null?null:f.map.get(candidate-1);
  const separate=prev===undefined||prev===0||prev===255;
  let reason='';
  if(!stm)reason='This release only accepts STM32 internal-flash address images.';
  else if(!markers.length||stats.length<2)reason='Betaflight identification/statistics markers not sufficient.';
  else if(hits.length!==1)reason=hits.length?'Ambiguous heading: multiple matches.':'Supported statistics heading was not found.';
  else if(!separate)reason='Heading is not a clearly isolated string; refusing possible shared-string suffix.';
  return {hits,markers,stats,stm,candidate,allowed:!reason,reason};
 }
 function patch(f,replacement){
  const result=inspect(f);if(!result.allowed)throw Error(result.reason);
  if(typeof replacement!=='string'||!replacement.trim()||replacement.length>original.length||!/^[A-Z0-9 .!?:_+&/-]+$/.test(replacement))throw Error('Use 1–13 uppercase display characters from the allowed set.');
  const text=replacement.padEnd(original.length,' '),start=result.candidate;
  const changed=new Map();for(let i=0;i<text.length;i++)if(text.charCodeAt(i)!==f.map.get(start+i))changed.set(start+i,text.charCodeAt(i));
  if(!changed.size)throw Error('No bytes changed.');
  const output=f.records.map(r=>{if(r.type!==0)return r.raw;let dirty=false;const d=r.data.map((v,i)=>{const a=r.base+r.offset+i;if(changed.has(a)){dirty=true;return changed.get(a);}return v;});return dirty?record(r.type,r.offset,d):r.raw;}).join('\n')+'\n';
  const checked=parse(output);if(checked.count!==f.count||checked.records.length!==f.records.length)throw Error('Verification failed: image shape.');
  for(const [a,v] of f.map)if(checked.map.get(a)!==(changed.has(a)?changed.get(a):v))throw Error('Verification failed: unexpected address change.');
  for(let i=0;i<f.records.length;i++){const a=f.records[i],b=checked.records[i];if(a.type!==b.type||a.offset!==b.offset||a.base!==b.base||a.data.length!==b.data.length||(a.type!==0&&a.raw!==b.raw))throw Error('Verification failed: record structure.');}
  return {output,changed:[...changed].map(([a,v])=>({address:address(a),before:hex(f.map.get(a)),after:hex(v)})),start:address(start),text};
 }
 // This fixture is deliberately not executable firmware. Never export as HEX.
 function fixture(){const bytes=Array.from('\0BTFL\0MIN BATTERY\0MAX CURRENT\0'+original+'\0OTHER\0',c=>c.charCodeAt(0));const lines=[record(4,0,[8,0])];for(let i=0;i<bytes.length;i+=16)lines.push(record(0,0x200+i,bytes.slice(i,i+16)));return lines.concat(record(1,0,[])).join('\n')+'\n';}
 return {parse,inspect,patch,fixture,record,address,original};
})();