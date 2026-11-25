-- Desktop Lua mock. Run from repository root.
VALUE,BOOL,STRING=1,2,3
SMLSIZE,MIDSIZE,CENTER,RIGHT,SOLID=1,2,4,8,0
LCD_W,LCD_H=480,272
local tick=0
local W,H=480,272
local current=true
local tx=7.8
local draws=0
local labels={}
function getTime() return tick end
function getSourceValue(name)
 if name=="tx-voltage" then return tx,true,true end
 if name=="RQly" then return 0,current,current end
 if name=="ail" then return 900,true,true end
 if name=="ele" then return 300,true,true end
 return nil,false,false
end
local function pt(x,y) assert(x>=0 and x<W and y>=0 and y<H,"point outside zone") end
local function rect(x,y,w,h) assert(w>0 and h>0);pt(x,y);pt(x+w-1,y+h-1);draws=draws+1 end
local function circle(x,y,r) assert(r>=1);pt(x-r,y-r);pt(x+r,y+r);draws=draws+1 end
lcd={RGB=function(r,g,b) assert(r>=0 and r<=255 and g>=0 and g<=255 and b>=0 and b<=255);return 256 end,drawRectangle=rect,drawFilledRectangle=rect,drawCircle=circle,drawFilledCircle=circle,
drawLine=function(x,y,X,Y) pt(x,y);pt(X,Y);draws=draws+1 end,
drawText=function(x,y,s,f) pt(x,y);labels[s]=true;draws=draws+1 end,
sizeText=function(s,f) return #s*7,14 end}
local api=assert(loadfile("sq-reactor/WIDGETS/SQReact/main.lua"))()
for _,size in ipairs({{480,272},{320,240},{800,480},{480,320},{320,480},{160,100},{80,64},{60,35},{36,24},{20,10}}) do
 W,H=size[1],size[2]
 for theme=1,5 do
  local w=api.create({w=W,h=H},{Theme=theme,Speed=2,React=1,Telemetry=1,Callsign="ABCDEFGH"})
  api.refresh(w,nil);tick=tick+50;api.refresh(w,nil)
  assert(w.phase>0 or W<80 or H<64)
  if W>=80 and H>=64 then assert(w.energy>0 and w.lq==0) end
  api.update(w,{Theme=theme,Speed=0,React=0,Telemetry=0})
  local phase=w.phase;tick=tick+50;api.refresh(w,nil);assert(w.phase==phase and w.volts==nil and w.lq==nil)
 end
end
W,H=480,272
local w=api.create({w=160,h=100},{})
labels={};api.refresh(w,0);assert(labels["0%"] and labels["7.8V"])
current=false;tick=tick+50;labels={};api.refresh(w,0);assert(labels["--"] and not labels["0%"])
assert(draws>0)
print("PASS: sizes, five palettes, dashboard/full screen, zero LQ, stale telemetry, static and stick response")
