'use strict';
const SQCollector=(()=>{
const key='sq.pack-lottery.album.v1', rarities=['standard','rare','legendary','mythical'];
let data={cards:{},totals:[0,0,0,0]},stored=true;
const count=n=>Number.isSafeInteger(n)&&n>=0?n:0;
const id=(l,c)=>l+'-'+c;
try{const a=JSON.parse(localStorage.getItem(key));if(a&&a.cards){for(let l=0;l<decks.length;l++)for(let c=0;c<decks[l].length;c++){const k=id(l,c),v=a.cards[k];if(v&&count(v.seen)>0){data.cards[k]={seen:count(v.seen),completed:count(v.completed),best:rarities.includes(v.best)?v.best:'standard',lastSeen:count(v.lastSeen),favorite:v.favorite===true,finishes:rarities.map((_,i)=>count(v.finishes?.[i]))};}}data.totals=rarities.map((_,i)=>count(a.totals?.[i]));}}catch{}
function save(){try{localStorage.setItem(key,JSON.stringify(data));}catch{stored=false;}}
function roll(random=Math.random){const x=random();return x<.01?'mythical':x<.10?'legendary':x<.30?'rare':'standard';}
function draw(l,c,r){const k=id(l,c),i=rarities.indexOf(r);if(i<0)return;let v=data.cards[k]||{seen:0,completed:0,best:'standard',lastSeen:0,favorite:false,finishes:[0,0,0,0]};v.seen++;v.lastSeen=Date.now();v.finishes[i]++;if(i>rarities.indexOf(v.best))v.best=r;data.cards[k]=v;data.totals[i]++;save();}
function complete(l,c){const v=data.cards[id(l,c)];if(v){v.completed++;save();}}
function favorite(l,c){const v=data.cards[id(l,c)];if(v){v.favorite=!v.favorite;save();}}
function stats(){const all=Object.values(data.cards);return {discovered:all.length,draws:all.reduce((a,v)=>a+v.seen,0),completed:all.reduce((a,v)=>a+v.completed,0),totals:[...data.totals],stored};}
return {rarities,roll,draw,complete,favorite,stats,get:(l,c)=>data.cards[id(l,c)]};
})();