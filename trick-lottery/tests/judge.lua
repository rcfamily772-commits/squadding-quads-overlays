-- Run from repo root: lua trick-lottery/tests/judge.lua
-- Mock data only. Not a physical flight validation.
VALUE,BOOL=1,2
SMLSIZE,MIDSIZE,DBLSIZE,RIGHT,CENTER,SOLID=1,2,4,8,16,0
LCD_W,LCD_H=480,272
EVT_VIRTUAL_NEXT,EVT_VIRTUAL_PREV,EVT_VIRTUAL_ENTER,EVT_TOUCH_TAP=1,2,3,4
local tick=0
local arm=-1024
local fresh=true
local speed=0
local altitude=100
function getTime() return tick end
function getSourceValue(name)
 if name=="ch5" then return arm,true,true end
 local v=({Sats=10,GSpd=speed,Alt=altitude,Hdg=90})[name]
 return v,fresh,fresh
end
lcd={RGB=function() return 256 end,sizeText=function(s) return #s*7 end}
for _,k in ipairs({"drawFilledRectangle","drawRectangle","drawCircle","drawLine","drawText","drawTextLines"}) do lcd[k]=function(...) end end
local api=assert(loadfile("trick-lottery/WIDGETS/SQLotto/main.lua"))()
local function setup(card)
 local w=api.create({w=480,h=230},{Motion=0,Mode=1})
 w.card=card;w.level=1;w.rarity=1;w.focus=7;w.attempts=1
 api.refresh(w,3);assert(w.view==6)
 w.focus=5;api.refresh(w,3)
 return w
end
local w=setup(18);assert(w.judge.state=="wait")
arm=1024;tick=tick+20;api.background(w);tick=tick+20;api.background(w)
assert(w.judge.state=="record")
speed=20
for i=1,35 do tick=tick+20;api.background(w) end
arm=-1024;tick=tick+20;api.background(w);tick=tick+20;api.background(w)
assert(w.judge.state=="result" and w.judge.score==100 and w.judge.confidence=="MEDIUM")
assert(w.album.wins[1]==0)
api.refresh(w,3);assert(w.view==0 and w.focus==7)
local u=setup(1);assert(u.judge.state=="setup" and not u.judge.profile)
fresh=false;local m=setup(18);assert(m.judge.state=="setup")
fresh=true;local v=setup(18);arm=1024
tick=tick+20;api.background(v);tick=tick+20;api.background(v)
fresh=false
for i=1,35 do tick=tick+20;api.background(v) end
arm=-1024;tick=tick+20;api.background(v);tick=tick+20;api.background(v)
assert(v.judge.state=="result" and v.judge.score==nil)
print("PASS: supported/unsupported, arm transitions, background, missing data, score, no XP change")
