-- Run from the repository root: lua trick-lottery/tests/smoke.lua
-- Mock classic EdgeTX APIs; not physical radio verification.
LCD_W,LCD_H=480,272
SMLSIZE,MIDSIZE,RIGHT,CENTER,SOLID=1,2,4,8,0
BOOL,VALUE=1,2
EVT_VIRTUAL_NEXT,EVT_VIRTUAL_PREV,EVT_VIRTUAL_ENTER,EVT_TOUCH_TAP=1,2,3,4
local tick=100
function getTime() return tick end
local texts={}
lcd={RGB=function(r,g,b) return 256 end,sizeText=function(s,f) return #s*7,14 end}
for _,k in ipairs({"drawFilledRectangle","drawRectangle","drawCircle","drawLine"}) do lcd[k]=function(...) end end
lcd.drawText=function(x,y,s,f) texts[#texts+1]=s end
lcd.drawTextLines=function(x,y,w,h,s,f) texts[#texts+1]=s end
local files={}
io={open=function(p,m) if m=="r" and not files[p] then return nil end return {p=p,m=m,body=files[p] or ""} end,read=function(f,n) return string.sub(f.body,1,n) end,write=function(f,s) f.body=s end,close=function(f) if f.m=="w" then files[f.p]=f.body end end}
local api=assert(loadfile("trick-lottery/WIDGETS/SQLotto/main.lua"))()
local w=api.create({w=480,h=230},{Motion=0,Mode=1})
local function has(q) for _,s in ipairs(texts) do if string.find(s,q,1,true) then return true end end return false end
local function frame(e,t) texts={};api.refresh(w,e,t) end
frame(nil);assert(has("PRESS & HOLD TO PLAY"));assert(has("Full screen"));assert(has("ROOKIE"));assert(w.album.draws==0)
frame(0);assert(has("Draw"));assert(w.album.draws==0)
frame(EVT_VIRTUAL_ENTER);assert(w.card and w.album.draws==1 and w.focus==3);assert(not w.unsaved)
frame(nil);assert(w.album.draws==1 and w.focus==3)
frame(EVT_VIRTUAL_ENTER);assert(w.card and w.album.draws==2 and w.focus==3)
frame(EVT_VIRTUAL_PREV);assert(w.focus==2)
frame(EVT_VIRTUAL_ENTER);assert(w.attempts==2 and w.focus==2)
frame(EVT_VIRTUAL_ENTER);assert(w.attempts==3 and w.focus==2)
frame(EVT_TOUCH_TAP,{x=170,y=240});assert(w.card and w.album.draws==3 and w.focus==3)
frame(EVT_TOUCH_TAP,{});assert(w.album.draws==3 and w.focus==3)
frame(EVT_VIRTUAL_NEXT);frame(EVT_VIRTUAL_ENTER);assert(w.level==2 and w.card==nil and w.focus==2)
frame(EVT_VIRTUAL_ENTER);assert(w.level==3 and w.card==nil and w.focus==2)
frame(EVT_VIRTUAL_PREV);frame(EVT_VIRTUAL_ENTER);assert(w.card and w.album.draws==4 and w.focus==3)
frame(EVT_VIRTUAL_NEXT);frame(EVT_VIRTUAL_NEXT);frame(EVT_VIRTUAL_ENTER);assert(w.view==1 and w.focus==1)
frame(EVT_VIRTUAL_NEXT);frame(EVT_VIRTUAL_ENTER);assert(w.view==2 and w.focus==2)
frame(EVT_VIRTUAL_ENTER);assert(w.view==3 and w.focus==2)
frame(EVT_VIRTUAL_PREV);frame(EVT_VIRTUAL_ENTER);assert(w.view==0 and w.focus==5)
frame(EVT_TOUCH_TAP,{x=15,y=240});assert(w.card==nil and w.album.wins[3]==1 and w.focus==1)
api.update(w,{Mode=2,Motion=0});assert(#w.bags==6)
w.level=6;frame(EVT_VIRTUAL_ENTER);assert(w.card and w.album.draws==5 and w.focus==3)
local copy=api.create({w=120,h=80},{Motion=0});assert(copy.album.draws==5)
texts={};api.refresh(copy,nil);assert(has("PRESS & HOLD"))
print("PASS: splash, drawing, sticky Deal/Retry/Deck, menu return, landed, modes and SD persistence")

-- Standalone tool must render live even with a nil idle event and ignore the launch event.
EVT_VIRTUAL_EXIT=5
local tool=assert(loadfile("trick-lottery/SCRIPTS/TOOLS/SQTrick.lua"))()
local before=api.create({w=480,h=272},{Motion=0}).album.draws
tool.init();texts={};assert(tool.run(EVT_VIRTUAL_ENTER)==0);assert(has("TOOL"));assert(has("Draw"))
assert(api.create({w=480,h=272},{Motion=0}).album.draws==before)
texts={};assert(tool.run(nil)==0);assert(has("Draw"));assert(not has("PRESS & HOLD TO PLAY"))
assert(tool.run(EVT_TOUCH_TAP,{x=15,y=240})==0)
assert(api.create({w=480,h=272},{Motion=0}).album.draws==before+1)
assert(tool.run(EVT_VIRTUAL_EXIT)==1)
print("PASS: independent Tools launch, nil frames, launch-event suppression, touch draw, shared album, exit")
