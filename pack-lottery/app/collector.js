'use strict';
const SQCollector=(()=>{
const key='sq.pack-lottery.album.v1', rarities=['standard','rare','legendary','mythical','golden'];
let data={cards:{},totals:[0,0,0,0,0]},stored=true;
const count=n=>Number.isSafeInteger(n)&&n>=0?n:0;
const id=(l,c)=>l+'-'+c;
try{const a=JSON.parse(localStorage.getItem(key));if(a&&a.cards){for(let l=0;l<decks.length;l++)for(let c=0;c<decks[l].length;c++){const k=id(l,c),v=a.cards[k];if(v&&count(v.seen)>0){data.cards[k]={seen:count(v.seen),completed:count(v.completed),best:rarities.includes(v.best)?v.best:'standard',lastSeen:count(v.lastSeen),favorite:v.favorite===true,finishes:rarities.map((_,i)=>count(v.finishes?.[i]))};}}data.totals=rarities.map((_,i)=>count(a.totals?.[i]));}}catch{}
function save(){try{localStorage.setItem(key,JSON.stringify(data));stored=true;return true;}catch{stored=false;return false;}}
function roll(random=Math.random){const x=random();return x<.002?'golden':x<.01?'mythical':x<.10?'legendary':x<.30?'rare':'standard';}
function draw(l,c,r){const k=id(l,c),i=rarities.indexOf(r);if(i<0)return;let v=data.cards[k]||{seen:0,completed:0,best:'standard',lastSeen:0,favorite:false,finishes:[0,0,0,0,0]};v.seen++;v.lastSeen=Date.now();v.finishes[i]++;if(i>rarities.indexOf(v.best))v.best=r;data.cards[k]=v;data.totals[i]++;save();}
function complete(l,c){const v=data.cards[id(l,c)];if(v){v.completed++;save();}}
function favorite(l,c){const v=data.cards[id(l,c)];if(v){v.favorite=!v.favorite;save();}}
function stats(){const all=Object.values(data.cards);return {discovered:all.length,draws:all.reduce((a,v)=>a+v.seen,0),completed:all.reduce((a,v)=>a+v.completed,0),totals:[...data.totals],stored};}
function snapshot(){return JSON.parse(JSON.stringify(data));}
function validateBackup(b){
 if(!b||!['SQ-Pack-Lottery-Collection','SQ-Trick-Lottery-Collection'].includes(b.format)||b.schema!==1||!b.collection||typeof b.collection.cards!=='object'||!b.collection.cards||Array.isArray(b.collection.cards))throw Error('Not a Pack Lottery collection backup.');
 const cards={},totals=[0,0,0,0,0]; const validCount=x=>Number.isSafeInteger(x)&&x>=0&&x<=10000000;
 for(const [k,v] of Object.entries(b.collection.cards)){
  if(!/^\d-\d{1,2}$/.test(k))throw Error('Unknown card ID');
  const [l,c]=k.split('-').map(Number);if(!decks[l]||!decks[l][c]||id(l,c)!==k||!v||!validCount(v.seen)||!v.seen||!validCount(v.completed)||v.completed>v.seen||!rarities.includes(v.best)||!Number.isSafeInteger(v.lastSeen)||v.lastSeen<0||typeof v.favorite!=='boolean'||!Array.isArray(v.finishes)||![4,5].includes(v.finishes.length)||!v.finishes.every(validCount)||v.finishes.reduce((a,x)=>a+x,0)!==v.seen||rarities[v.finishes.reduce((a,x,i)=>x>0?i:a,-1)]!==v.best)throw Error('Invalid card record: '+k);
  cards[k]={seen:v.seen,completed:v.completed,best:v.best,lastSeen:v.lastSeen,favorite:v.favorite,finishes:rarities.map((_,i)=>v.finishes[i]||0)};v.finishes.forEach((x,i)=>totals[i]+=x);
 }
 return {cards,totals};
}
function restore(b){const next=validateBackup(b),old=data;data=next;if(!save()){data=old;throw Error('Storage is unavailable. Your existing collection has not been replaced.');}return stats();}
return {rarities,roll,draw,complete,favorite,stats,snapshot,validateBackup,restore,get:(l,c)=>data.cards[id(l,c)]};
})();