'use strict';
self.window=self;
importScripts('vendor/fengari.js');
let draw,snapshot,commands,metrics;
const fontSize=f=>f&0x10000000?64:f&0x08000000?32:f&0x04000000?22:12;
function measure(s,f){metrics.font=`${fontSize(f)>=22?600:500} ${fontSize(f)}px Arial`;return Math.ceil(metrics.measureText(String(s)).width);}
self.onmessage=({data})=>{
 try{
  commands=[];snapshot=data.snapshot;
  if(data.source){
   metrics=new OffscreenCanvas(1,1).getContext('2d');
   const init=fengari.load(data.adapter,'@preview-runtime.lua')();
   draw=init(data.source,(...args)=>{if(commands.length>2500)throw Error('Frame exceeds drawing budget');commands.push(args);},key=>{
    let v=snapshot;for(const p of key.split('.'))v=v?.[p];return v==null?undefined:v;
   },measure);
  }
  if(!draw)throw Error('Renderer not loaded');
  const tabHeight=draw();
  self.postMessage({commands,id:data.id,width:snapshot.width,height:snapshot.height,tabHeight});
 }catch(e){self.postMessage({error:String(e),id:data.id});}
};
