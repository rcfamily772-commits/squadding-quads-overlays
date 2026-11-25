-- Host-side mocked smoke test: lua smoke.lua path/to/main.lua
local widget
system={registerWidget=function(w) widget=w end}
FONT_S=1;FONT_STD=2;FONT_L=3
EVT_TOUCH=1;TOUCH_END=2;EVT_KEY=3;KEY_ROTARY_RIGHT=4;KEY_ROTARY_LEFT=5;KEY_ENTER_BREAK=6
local width,height=480,320
lcd={RGB=function(...) return 0 end,color=function()end,drawFilledRectangle=function()end,font=function()end,drawText=function()end,getTextSize=function(s)return #s*7,16 end,getWindowSize=function()return width,height end,invalidate=function()end}
dofile(arg[1]).init()
assert(widget.key=="SQWing")
local w=widget.create()
widget.paint(w)
local function tap(i)
  local b=w.buttons[i]; assert(widget.event(w,EVT_TOUCH,TOUCH_END,b.x+1,b.y+1))
end
local seen={}
for i=1,20 do tap(1); assert(w.card<=20 and not seen[w.card]); seen[w.card]=true end
local before=w.card;tap(2);assert(w.card==before and w.retries==1 and w.focus==2)
tap(3);tap(3);assert(w.landed==1 and w.focus==3)
tap(4);assert(w.sim and not w.card)
seen={}
for i=1,25 do tap(1);assert(not seen[w.card]);seen[w.card]=true end
assert(seen[25])
tap(4);assert(not w.sim and not w.card)
widget.event(w,EVT_KEY,KEY_ROTARY_RIGHT);assert(w.focus==1)
widget.event(w,EVT_KEY,KEY_ENTER_BREAK);assert(w.card<=20)
width,height=800,480;widget.paint(w);assert(#w.buttons==4)
width,height=160,80;widget.paint(w);assert(#w.buttons==0)
print("ETHOS mock smoke test passed")
