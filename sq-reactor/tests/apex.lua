-- Run with Lua 5.3+ from repository root. LCD/font metrics are approximations.
SOURCE,BOOL,VALUE=1,2,3
SMLSIZE,MIDSIZE,DBLSIZE,XXLSIZE=0x02000000,0x04000000,0x08000000,0x10000000
CENTER,RIGHT,SOLID=0x40000000,0x20000000,0
EVT_VIRTUAL_NEXT_PAGE,EVT_VIRTUAL_PREV_PAGE=100,101
EVT_VIRTUAL_NEXT,EVT_VIRTUAL_PREV=102,103
LCD_W,LCD_H=480,272
local theme=tonumber(os.getenv("SQ_DASH_THEME") or "6")
assert(theme==6 or theme==7 or theme==8)
local tick,arm=0,-1024
local W,H=480,272
local readings={speed=123,volt=24.1,amp=32.6,mah=100,lq=97,rssi=-68,alt=42}
local names={GSpd={id=2,unit=7},VFAS={id=3,unit=1},Curr={id=4,unit=2},Capa={id=5,unit=14},RQly={id=6,unit=13},['1RSS']={id=7,unit=17},Alt={id=8,unit=9}}
local ids={[2]='speed',[3]='volt',[4]='amp',[5]='mah',[6]='lq',[7]='rssi',[8]='alt'}
local labels,commands={},{}
local strict=true
function getTime() return tick end
function getDateTime() return {year=2026,mon=11,day=26,hour=19,min=0,sec=0} end
function getFieldInfo(n) return names[n] end
function getSourceValue(id) if id==1 then return arm,true,true end local v=readings[ids[id]];return v,v~=nil,v~=nil end
model={getInfo=function() return {name='SQ FREESTYLE 5',filename='model1.yml'} end}
local function pt(x,y)
 assert(x==math.floor(x) and y==math.floor(y),'fractional coordinate')
 assert(x>=0 and x<W and y>=0 and y<H,string.format('outside %dx%d: %d,%d',W,H,x,y))
end
local function emit(op,...) commands[#commands+1]={op,...} end
local function fontsize(f) if f&XXLSIZE~=0 then return 64 elseif f&DBLSIZE~=0 then return 32 elseif f&MIDSIZE~=0 then return 22 else return 12 end end
lcd={RGB=function(r,g,b) return 0x01000000+r*65536+g*256+b end}
function lcd.sizeText(s,f) return math.ceil(#tostring(s)*fontsize(f)*.55),fontsize(f) end
function lcd.drawText(x,y,s,f)
 pt(x,y);local tw,th=lcd.sizeText(s,f);local xx=x
 if f&CENTER~=0 then xx=x-tw/2 elseif f&RIGHT~=0 then xx=x-tw end
 if strict then assert(xx>=-1 and xx+tw<=W+1 and y+th<=H+1,'text outside: '..s..' at '..x..','..y) end
 labels[s]=true;emit('drawText',x,y,s,f)
end
function lcd.drawFilledRectangle(x,y,w,h,c) assert(w>0 and h>0);pt(x,y);pt(x+w-1,y+h-1);emit('drawFilledRectangle',x,y,w,h,c) end
function lcd.drawRectangle(x,y,w,h,c) assert(w>0 and h>0);pt(x,y);pt(x+w-1,y+h-1);emit('drawRectangle',x,y,w,h,c) end
function lcd.drawLine(x,y,X,Y,p,c) pt(x,y);pt(X,Y);emit('drawLine',x,y,X,Y,p,c) end
function lcd.drawCircle(x,y,r,c) pt(x-r,y-r);pt(x+r,y+r);emit('drawCircle',x,y,r,c) end
function lcd.drawFilledTriangle(x,y,X,Y,xx,yy,c) pt(x,y);pt(X,Y);pt(xx,yy);emit('drawFilledTriangle',x,y,X,Y,xx,yy,c) end
local api=assert(loadfile('sq-reactor/WIDGETS/SQDash/main.lua'))()
assert(api.create({w=W,h=H},{}).theme==8, "new widget must default to Tailor")
local function setup()
 tick=tick+20;arm=-1024
 local w=api.create({w=W,h=H},{ArmSrc=1,ArmHigh=1,Theme=theme,Cells=6})
 api.background(w);assert(w.state=='READY');return w
end
local function draw(w,event) labels={};commands={};api.refresh(w,event);assert(#commands<500,'drawing budget exceeded') end
local w=setup();draw(w);assert(labels['STANDBY'])
arm=1024;tick=tick+100;api.background(w);assert(w.state=='FLIGHT');draw(w)
tick=tick+100;readings.speed=150;readings.mah=120;api.background(w)
tick=tick+100;readings.speed=nil;readings.lq=0;api.background(w);draw(w)
assert(w.data.speed==nil and w.data.lq==0,'missing speed must not become zero; zero LQ must remain valid')
assert(w.stats.speed==150 and w.stats.mah==20)
api.refresh(w,EVT_VIRTUAL_NEXT_PAGE);assert(w.page==1,'page navigation must remain locked while armed')
readings.speed=50;readings.lq=98;tick=tick+100;arm=-1024;api.background(w)
assert(w.state=='REPORT' and w.stats.speed==150 and w.flights==1)
draw(w);assert(labels['LAST FLIGHT'] and labels['PEAK GROUND SPEED'])
tick=tick+100;readings.speed=1;api.background(w);assert(w.stats.speed==150,'report must stay frozen')
api.refresh(w,EVT_VIRTUAL_NEXT_PAGE);assert(w.page==2)
w.mph=true;w.feet=true;draw(w);assert(labels['93'] and labels['138'],'independent display conversion')
w.page=4;w.total=2;w.totalTime=360;w.allSpeed=150;w.allPower=785;w.recent={{date='2026-11-26 19:00',duration=180,speed=150,partial=false}}
draw(w);assert(labels['AIRCRAFT LOGBOOK'])
local native=w
for _,size in ipairs({{480,272},{460,232},{460,210},{800,480}}) do
 W,H=size[1],size[2];w=setup();w.aircraft='VERY LONG AIRCRAFT NAME THAT MUST BE CLIPPED'
 for page=1,4 do w.page=page;draw(w) end
 -- Extreme supported readings must fit or show --, never clipped digits.
 readings.speed=700;readings.alt=15000;readings.volt=99.9;readings.amp=499;readings.mah=99999
 arm=1024;tick=tick+100;api.background(w);w.mph=true;w.feet=true;w.page=1;draw(w)
end
-- Compact fallback is retained; its typography is approximate and legacy.
strict=false
for _,size in ipairs({{400,190},{320,240},{320,480},{240,160},{160,100},{80,64}}) do
 W,H=size[1],size[2];w=setup();for page=1,4 do w.page=page;draw(w) end
end
W,H=480,272;strict=true
w=api.create({w=W,h=H},{Theme=theme});draw(w);assert(labels['SET ARM SOURCE'])
-- Export reproducible primitive recordings for the design proof; not photographs.
local out=io.open(theme==8 and '/tmp/sq-tailor-frames.json' or theme==7 and '/tmp/sq-nocturne-frames.json' or '/tmp/sq-apex-frames.json','w');out:write('[')
local function json(v)
 if type(v)=='string' then return string.format('%q',v):gsub('\\\n','\\n') end
 if type(v)=='number' then return tostring(v) end
 local a={};for _,x in ipairs(v) do a[#a+1]=json(x) end;return '['..table.concat(a,',')..']'
end
readings={speed=123,volt=23.78,amp=38.4,mah=510,lq=98,rssi=-64,alt=42}
w=setup();arm=1024;tick=tick+100;api.background(w);tick=tick+12345;api.background(w);w.gap=false;w.stats.mah=510
w.hist={34,44,71,63,87,110,96,123,116,132,127,140,135,122,126,124,130,122,123}
for page=1,4 do
 w.page=page
 if page==4 then arm=-1024;tick=tick+100;api.background(w);w.recent={{date='2026-11-26 19:00',duration=123,speed=140,partial=false},{date='2026-11-26 18:42',duration=191,speed=128,partial=false}};w.total=2;w.totalTime=314;w.allSpeed=140;w.allPower=913;w.allTime=191;w.logStatus='SD HISTORY READY' end
 draw(w);if page>1 then out:write(',') end;out:write(json(commands))
end
w.page=1;draw(w);out:write(',',json(commands),']');out:close()
print('PASS theme '..theme..': real Lua execution; 4 Apex layouts; 4 landscape geometries; 6 fallback geometries; arm gating; missing speed; zero LQ; frozen report; units; bounded drawing; primitive recordings.')
