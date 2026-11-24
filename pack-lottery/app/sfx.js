/* SQ Card Room original procedural SFX, v1.5. */
'use strict';
const SQSfx=(()=>{
  const key='sq.pack-lottery.sound.v1';
  let enabled=true, ctx=null, master=null, bank={}, pending=new Set();
  try {enabled=localStorage.getItem(key)!=='off';}catch{}
  const rate=24000;
  const durations={shuffle:.31,deal:.26,tap:.09,retry:.22,win:.67,level:.10};
  const clamp=(x,a,b)=>Math.min(b,Math.max(a,x));
  function make(name){
    const out=new Float32Array(Math.ceil(rate*durations[name]));
    let seed=0x51a7+name.length*531,low=0;
    function noise(){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/2147483648-1;}
    function addNoise(start,len,amp,decay=3,shape='paper'){
      let prev=0;low=0;
      for(let j=0;j<Math.floor(len*rate);j++){
        const i=Math.floor(start*rate)+j;if(i>=out.length)break;
        const t=j/rate,u=t/len,raw=noise();low+=.13*(raw-low);
        const x=shape==='thud'?low:shape==='air'?raw*.35+low*.65:raw-prev*.82;
        prev=raw;const env=Math.min(1,t/.002)*Math.pow(1-u,decay);
        out[i]+=amp*x*env;
      }
    }
    function note(start,len,f0,f1,amp,shape='sine'){
      let phase=0;
      for(let j=0;j<Math.floor(len*rate);j++){
        const i=Math.floor(start*rate)+j;if(i>=out.length)break;
        const t=j/rate,u=t/len;phase+=2*Math.PI*(f0+(f1-f0)*u)/rate;
        const env=Math.min(1,t/.006)*Math.pow(1-u,2.2);
        out[i]+=amp*env*(Math.sin(phase)+(shape==='bell'?.20*Math.sin(2.76*phase):0));
      }
    }
    if(name==='shuffle'){for(let j=0;j<7;j++)addNoise(j*.034,.045,.19,2.7);addNoise(.22,.075,.20,3,'thud');note(.22,.08,160,82,.11);}
    if(name==='deal'){addNoise(0,.20,.13,1.4,'air');addNoise(.03,.13,.16,2.0);addNoise(.17,.07,.24,3,'thud');note(.17,.075,155,80,.16);}
    if(name==='tap'){addNoise(0,.075,.21,3,'thud');note(0,.07,190,105,.14);}
    if(name==='retry'){note(0,.12,410,320,.18);note(.095,.11,440,440,.13,'bell');}
    if(name==='win'){for(const [i,f] of [523.25,659.25,783.99,1046.5].entries())note(i*.105,.31,f,f,.16,'bell');}
    if(name==='level'){note(0,.09,660,570,.12);addNoise(0,.04,.08,3);}
    let peak=0;for(const x of out)peak=Math.max(peak,Math.abs(x));
    const gain=peak>.66?.66/peak:1;for(let i=0;i<out.length;i++)out[i]=clamp(out[i]*gain,-1,1);
    return out;
  }
  function unlock(){
    if(!enabled)return false;
    try{
      if(!ctx){const AC=window.AudioContext||window.webkitAudioContext;if(!AC)return false;ctx=new AC();master=ctx.createGain();master.gain.value=.65;master.connect(ctx.destination);}
      if(ctx.state==='suspended')Promise.resolve(ctx.resume()).catch(()=>{});
      return ctx.state!=='closed';
    }catch{return false;}
  }
  function play(name){
    if(!enabled||!durations[name]||!unlock())return;
    try{
      if(!bank[name]){const a=make(name),b=ctx.createBuffer(1,a.length,rate);b.getChannelData(0).set(a);bank[name]=b;}
      const source=ctx.createBufferSource();source.buffer=bank[name];source.connect(master);pending.add(source);
      source.onended=()=>{pending.delete(source);try{source.disconnect();}catch{}};
      source.start();
    }catch{}
  }
  function set(value){enabled=!!value;try{localStorage.setItem(key,enabled?'on':'off');}catch{}
    if(master)master.gain.value=enabled?.65:0;
    if(!enabled){for(const source of pending){try{source.stop();}catch{}}pending.clear();}
    else {unlock();play('tap');}
    return enabled;
  }
  return {play,unlock,set,get enabled(){return enabled;},make};
})();