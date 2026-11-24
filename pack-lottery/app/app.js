'use strict';
const key = 'sq.pack-lottery.session.v1';
const el = id => document.getElementById(id);
const levels = Array.from(document.querySelectorAll('nav button'));
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
  if (stored && Array.isArray(stored.bags) && stored.bags.length===3 && Array.isArray(stored.last) && stored.last.length===3) { stored.bags.push([]); stored.last.push(null); }
  if (valid(stored)) state = stored;
} catch {}
function render() {
  const {level,card,tries,total,complete} = state;
  const active = card !== null;
  el('level').textContent = levels[level].textContent+' deck';
  el('attempt').textContent = active ? 'Attempt '+tries : level===3 ? '1 challenge · 12 messages' : decks[level].length+' challenges';
  el('title').textContent = active ? decks[level][card][0] : complete ? 'Landed it.' : 'Your next pack';
  el('brief').textContent = active ? decks[level][card][1] : complete ? complete+' complete. Ready for another draw?' : level===3 ? 'No tricks. No pressure. Just fly when it is safe.' : 'Draw a card before take-off to see your challenge.';
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
function draw() {
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
  el('landed').focus();
}
el('draw').onclick = el('redraw').onclick = draw;
el('retry').onclick = () => { state.tries++; save(); };
el('landed').onclick = () => {
  if (state.card === null) return;
  state.complete = decks[state.level][state.card][0];
  state.total++;
  state.card = null;
  save();
  el('draw').focus();
};
levels.forEach((button,i) => button.onclick = () => {
  if (i === state.level) return;
  state.level = i;
  state.card = null;
  state.complete = '';
  save();
});
el('reset').onclick = () => {
  if (confirm('Start a new session and clear this tally and deck progress?')) {
    state = fresh();
    save();
  }
};
render();
