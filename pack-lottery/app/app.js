'use strict';
const key = 'sq.pack-lottery.session.v1';
const el = id => document.getElementById(id);
const levels = Array.from(document.querySelectorAll('nav button'));
const ranks=['B','I','A','OD','BP','18+'], suits=['♣','♦','♠','♥','♣','♠'];
let busy=false;
const controls=()=>[...levels,...['draw','landed','retry','redraw','reset'].map(el)];
function setBusy(value){busy=value;controls().forEach(b=>b.disabled=value);}
const face=()=>el('challenge-card');
const collector=SQCollector, rarityNames=['Standard','Rare','Legendary','Mythical'];
let haptics=true,adultAlbum=false;
try{haptics=localStorage.getItem('sq.pack-lottery.haptics.v1')!=='off';}catch{}
function buzz(pattern){if(haptics)try{navigator.vibrate?.(pattern);}catch{}}
function syncHaptics(){const b=el('haptics');const available=typeof navigator!=='undefined'&&typeof navigator.vibrate==='function';b.disabled=!available;b.textContent=!available?'Haptics: unavailable':haptics?'Haptics: on':'Haptics: off';b.setAttribute('aria-pressed',String(available&&haptics));}
el('haptics').onclick=()=>{haptics=!haptics;try{localStorage.setItem('sq.pack-lottery.haptics.v1',haptics?'on':'off');}catch{}syncHaptics();if(haptics)buzz(15);else try{navigator.vibrate?.(0);}catch{}};
syncHaptics();
const titleCase=r=>rarityNames[collector.rarities.indexOf(r)]||'Standard';
function updateAlbumCount(){el('album-open').textContent='Album '+collector.stats().discovered+'/60';}
function make(tag,cls,content){const a=document.createElement(tag);if(cls)a.className=cls;if(content!==undefined)a.textContent=content;return a;}
function renderAlbum(){const stats=collector.stats(),grid=el('album-grid');el('album-stats').textContent=stats.discovered+'/60 discovered · '+stats.draws+' draws · '+stats.completed+' completed'+(stats.stored?'':' · storage unavailable');el('album-rarities').textContent=stats.totals.map((v,i)=>rarityNames[i]+': '+v).join(' · ');grid.replaceChildren();const filter=el('album-filter').value, fav=el('album-favorites').checked;
decks.forEach((deck,l)=>{if(filter!=='all'&&Number(filter)!==l)return;deck.forEach((entry,c)=>{const v=collector.get(l,c);if(fav&&!v?.favorite)return;const hiddenAdult=l===5&&!adultAlbum;const tile=make('article','album-tile '+(v?v.best:'unknown'));tile.dataset.deck=String(l);const emblem=make('img');emblem.src='art/deck-'+l+'.svg';emblem.alt='';tile.append(emblem,make('small','',levels[l].textContent+' · '+String(c+1).padStart(2,'0')),make('h3','',!v?'Undiscovered':hiddenAdult?'Adults Only card':entry[0]));
if(v){tile.append(make('p','',hiddenAdult?'Strong language hidden.':entry[1]),make('small','',titleCase(v.best)+' · Drawn '+v.seen+' · Landed '+v.completed),make('small','',v.finishes.map((f,i)=>f?rarityNames[i]+' ×'+f:'').filter(Boolean).join(' · ')));const button=make('button','favorite',v.favorite?'★ Favourited':'☆ Favourite');button.type='button';button.setAttribute('aria-pressed',String(v.favorite));button.onclick=()=>{collector.favorite(l,c);button.textContent=collector.get(l,c).favorite?'★ Favourited':'☆ Favourite';button.setAttribute('aria-pressed',String(collector.get(l,c).favorite));if(el('album-favorites').checked&&!collector.get(l,c).favorite)tile.remove();};tile.append(button);}else tile.append(make('p','','Deal this card to unlock it.'));grid.append(tile);});});
if(!grid.children.length)grid.append(make('p','','No matching cards yet.'));el('album-adult').hidden=adultAlbum;}
el('album-open').onclick=()=>{if(busy)return;adultAlbum=false;renderAlbum();el('album').showModal();};
el('album-close').onclick=()=>el('album').close();
el('album-filter').onchange=el('album-favorites').onchange=renderAlbum;
el('album-adult').onclick=()=>{if(confirm('Reveal strong language in the Adults Only collection?')){adultAlbum=true;renderAlbum();}};
el('album').addEventListener('close',()=>{adultAlbum=false;el('album-grid').replaceChildren();});
const reduced=()=>window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches;
face().addEventListener('pointermove',e=>{if(busy||reduced()||e.pointerType==='touch')return;const r=face().getBoundingClientRect();face().style.setProperty('--rx',((.5-(e.clientY-r.top)/r.height)*9)+'deg');face().style.setProperty('--ry',(((e.clientX-r.left)/r.width-.5)*9)+'deg');});
face().addEventListener('pointerleave',()=>{face().style.setProperty('--rx','0deg');face().style.setProperty('--ry','0deg');});
async function reveal(r){const card=face();card.classList.remove('foil-reveal');void card.offsetWidth;card.classList.add('foil-reveal');if(r==='mythical'||r==='legendary'){sfx(r);buzz(r==='mythical'?[30,40,30,60]:[20,30,20]);}else if(r==='rare'){sfx('rare');buzz(25);}else buzz(15);if(!reduced()&&r!=='standard')await new Promise(resolve=>setTimeout(resolve,r==='mythical'?700:480));card.classList.remove('foil-reveal');}

const sound=typeof SQSfx!=='undefined'?SQSfx:null;
function sfx(name){if(sound)sound.play(name);}
function syncSound(){const b=el('sound');b.textContent=sound&&sound.enabled?'Sound: on':'Sound: off';b.setAttribute('aria-pressed',String(!!(sound&&sound.enabled)));if(!sound)b.disabled=true;}
el('sound').onclick=()=>{if(sound){sound.set(!sound.enabled);syncSound();}};
syncSound();
function motion(name,ms){const card=face();card.classList.remove('deal-in','deal-out','win-out','retry');if(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches)return Promise.resolve();void card.offsetWidth;card.classList.add(name);return new Promise(resolve=>setTimeout(()=>{card.classList.remove(name);resolve();},ms));}
function fresh() {
  return {level:0, bags:decks.map(()=>[]), last:decks.map(()=>null), card:null, rarity:'standard', collected:false, tries:0, total:0, complete:''};
}
const index = (n, level) => Number.isInteger(n) && n >= 0 && n < decks[level].length;
function valid(s) {
  return s && Number.isInteger(s.level) && levels[s.level] &&
    Array.isArray(s.bags) && s.bags.length === decks.length && s.bags.every((b,i) => Array.isArray(b) && b.length <= decks[i].length && b.every(n=>index(n,i)) && new Set(b).size === b.length) &&
    Array.isArray(s.last) && s.last.length === decks.length && s.last.every((n,i) => n === null || index(n,i)) &&
    (s.card === null || index(s.card,s.level)) && Number.isSafeInteger(s.tries) && s.tries >= 0 &&
    Number.isSafeInteger(s.total) && s.total >= 0 && typeof s.complete === 'string';
}
let state = fresh();
try {
  const stored = JSON.parse(localStorage.getItem(key));
  if (stored && Array.isArray(stored.bags) && Array.isArray(stored.last) && stored.bags.length===stored.last.length && stored.bags.length>=3 && stored.bags.length<decks.length) { while(stored.bags.length<decks.length) { stored.bags.push([]); stored.last.push(null); } }
  if (valid(stored)) { state = stored; if(!collector.rarities.includes(state.rarity)){state.rarity='standard';state.collected=false;} state.collected=state.collected===true; if (state.level===5) { state.level=0; state.card=null; state.complete=''; } }
} catch {}
function render() {
  const {level,card,tries,total,complete} = state;
  const active = card !== null;
  face().dataset.rarity=active?state.rarity:'standard';
  el('card-art').src=el('back-art').src='art/deck-'+level+'.svg';
  el('rarity').textContent=active?titleCase(state.rarity):'Collector’s edition';
  updateAlbumCount();
  el('table').dataset.level=String(level);
  el('rank').textContent=el('rank-bottom').textContent=ranks[level];
  el('suit').textContent=el('suit-bottom').textContent=suits[level];
  el('remaining').textContent=(state.last[level]===null?decks[level].length:state.bags[level].length)+' / '+decks[level].length+' left in deck';
  el('level').textContent = levels[level].textContent+' deck';
  el('attempt').textContent = active ? 'Attempt '+tries : level>=3 ? '1 challenge · '+decks[level].length+' messages' : decks[level].length+' challenges';
  el('title').textContent = active ? decks[level][card][0] : complete ? 'Landed it.' : 'Your next pack';
  el('brief').textContent = active ? decks[level][card][1] : complete ? complete+' complete. Ready for another draw?' : level===3 ? 'No tricks. No pressure. Just fly when it is safe.' : level===4 ? 'Finish your safety checks, leave the bench and fly when conditions are safe.' : level===5 ? 'Adults only: strong language. Draw to reveal. Fly only when safe.' : 'Draw a card before take-off to see your challenge.';
  el('total').textContent = total+' landed this session';
  levels.forEach((b,i) => b.setAttribute('aria-pressed',i===level));
  el('draw').hidden = active;
  for (const id of ['landed','retry','redraw']) el(id).hidden = !active;
}
function save() {
  try { localStorage.setItem(key,JSON.stringify(state)); }
  catch { el('saved').textContent = 'Session available in this tab only'; }
  render();
}
function drawCard() {
  const bag = state.bags[state.level];
  if (!bag.length) {
    decks[state.level].forEach((_,i) => bag.push(i));
    for (let i=bag.length-1;i>0;i--) {
      const j = Math.floor(Math.random()*(i+1));
      [bag[i],bag[j]] = [bag[j],bag[i]];
    }
    const end = bag.length-1;
    if (bag[end] === state.last[state.level]) [bag[0],bag[end]] = [bag[end],bag[0]];
  }
  state.card = bag.pop();
  state.rarity=collector.roll();
  state.collected=true;
  collector.draw(state.level,state.card,state.rarity);
  state.last[state.level] = state.card;
  state.tries = 1;
  state.complete = '';
  save();
}
async function deal(){if(busy)return;setBusy(true);try{if(sound)sound.unlock();sfx(state.bags[state.level].length?'tap':'shuffle');await motion('deal-out',180);drawCard();sfx('deal');await motion('deal-in',420);await reveal(state.rarity);}finally{setBusy(false);el('landed').focus();}}
el('draw').onclick = el('redraw').onclick = deal;
el('retry').onclick = async () => { if(busy)return;setBusy(true);try{sfx('retry');buzz([10,20,10]);state.tries++;save();await motion('retry',240);}finally{setBusy(false);} };
el('landed').onclick = async () => {
  if (busy || state.card === null) return;
  setBusy(true);
  try{sfx('win');buzz([20,40,20]);await motion('win-out',250);
  if(state.collected)collector.complete(state.level,state.card);
  state.complete = decks[state.level][state.card][0];
  state.total++;
  state.card = null;
  state.collected=false;
  save();
  await motion('deal-in',420);
  }finally{setBusy(false);el('draw').focus();}
};
levels.forEach((button,i) => button.onclick = () => {
  if (busy || i === state.level) return;
  if (i === 5 && !confirm('Adults Only contains strong language. Continue?')) return;
  sfx('level');
  state.level = i;
  state.card = null;
  state.collected=false;
  state.complete = '';
  save();
});
el('reset').onclick = () => {
  if (busy) return;
  if (confirm('Start a new session and clear this tally and deck progress?')) {
    sfx('tap');
    state = fresh();
    save();
  }
};
render();
