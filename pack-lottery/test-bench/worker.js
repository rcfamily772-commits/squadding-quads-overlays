'use strict';
self.window=self;
importScripts('vendor/fengari.js');
let step, commands;
const start = performance.now();
function emit(...args) {
  if (commands.length >= 2048) throw Error('Frame drawing limit exceeded');
  commands.push(args);
}
self.onmessage = ({data}) => {
  try {
    commands=[];
    if (data.source !== undefined) {
      const init = fengari.load(data.adapter,'@adapter.lua')();
      const images=data.images || [];
      let state=data.last;const lipo=data.lipoFiles||{};
      function assets(op,path,index) {
        if(op==='lipoState')return lipo[path];
        if(op==='lipoSave'){lipo[path]=String(index).slice(0,2048);self.postMessage({lipoFiles:lipo});return;}
        if(op==='clock')return data.epoch+Math.floor((performance.now()-start)/1000);
        if(op==='state')return state || undefined;
        if(op==='save'){state=String(path).slice(0,300);self.postMessage({saved:state});return;}
        if(op==='name')return path==='/IMAGES/SQWALL'?images[index-1]?.name:undefined;
        const item=images.find(i=>'/IMAGES/SQWALL/'+i.name===path);
        return item?.[op];
      }
      step = init(data.source,data.width,data.height,data.tile,emit,()=>Math.floor((performance.now()-start)/10),assets);
    }
    step(data.event || 0,data.x || 0,data.y || 0);
    self.postMessage({commands});
  } catch (err) { self.postMessage({error:String(err)}); }
};
