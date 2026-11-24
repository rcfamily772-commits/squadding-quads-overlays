'use strict';
const key = 'sq.pack-lottery.session.v1';
const el = id => document.getElementById(id);
const levels = Array.from(document.querySelectorAll('nav button'));
const ranks=['B','I','A','OD','BP','18+'], suits=['♣','♦','♠','♥','♣','♠'];
let busy=false;
const controls=()=>[...levels,...['draw','landed','retry','redraw','reset'].map(el)];
function setBusy(value){busy=value;controls().forEach(b=>b.disabled=value);}
const face=()=>el('challenge-card');
function motion(name,ms){const card=face();card.classList.remove('deal-in','deal-out','win-out','retry');if(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches)return Promise.resolve();void card.offsetWidth;card.classList.add(name);return new Promise(resolve=>setTimeout(()=>{card.classList.remove(name);resolve();},ms));}
function fresh() {
  return {level:0, bags:decks.map(()=>[]), last:decks.map(()=>null), card:null, tries:0, total:0, complete:''};
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
  if (valid(stored)) { state = stored; if (state.level===5) { state.level=0; state.card=null; state.complete=''; } }
} catch {}
function render() {
  const {level,card,tries,total,complete} = state;
  const active = card !== null;
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
  state.last[state.level] = state.card;
  state.tries = 1;
  state.complete = '';
  save();
}
async function deal(){if(busy)return;setBusy(true);try{await motion('deal-out',180);drawCard();await motion('deal-in',420);}finally{setBusy(false);el('landed').focus();}}
el('draw').onclick = el('redraw').onclick = deal;
el('retry').onclick = async () => { if(busy)return;setBusy(true);try{state.tries++;save();await motion('retry',240);}finally{setBusy(false);} };
el('landed').onclick = async () => {
  if (busy || state.card === null) return;
  setBusy(true);
  try{await motion('win-out',250);
  state.complete = decks[state.level][state.card][0];
  state.total++;
  state.card = null;
  save();
  await motion('deal-in',420);
  }finally{setBusy(false);el('draw').focus();}
};
levels.forEach((button,i) => button.onclick = () => {
  if (busy || i === state.level) return;
  if (i === 5 && !confirm('Adults Only contains strong language. Continue?')) return;
  state.level = i;
  state.card = null;
  state.complete = '';
  save();
});
el('reset').onclick = () => {
  if (busy) return;
  if (confirm('Start a new session and clear this tally and deck progress?')) {
    state = fresh();
    save();
  }
};
render();
