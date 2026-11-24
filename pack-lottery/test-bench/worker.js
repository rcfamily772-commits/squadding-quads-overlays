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
      step = init(data.source,data.width,data.height,data.tile,emit,()=>Math.floor((performance.now()-start)/10));
    }
    step(data.event || 0,data.x || 0,data.y || 0);
    self.postMessage({commands});
  } catch (err) { self.postMessage({error:String(err)}); }
};
