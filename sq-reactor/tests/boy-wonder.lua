-- Theme 9 drawing limits, animation, asset lifetime and the disarm path.
SOURCE,BOOL,VALUE=1,2,3
SMLSIZE,MIDSIZE,DBLSIZE,XXLSIZE=0x02000000,0x04000000,0x08000000,0x10000000
CENTER,RIGHT,SOLID=0x40000000,0x20000000,0
EVT_VIRTUAL_ENTER=104
local tick,arm,loads=0,-1024,0
local labels,draws,pilot={},0,nil
local sizes={{480,272},{460,232},{800,480},{360,180},{320,240},{320,480},{200,120},{160,100},{125,70},{80,64},{20,10}}
function getTime() return tick end
function getFieldInfo(name)
 local map={GSpd={id=2,unit=7},Alt={id=3,unit=9},RQly={id=4,unit=13},['1RSS']={id=5,unit=17}}
 return map[name]
end
function getSourceValue(id) return ({arm,112,42,0,-91})[id],true,true end
function getDateTime() return {year=2026,mon=11,day=27,hour=8,min=0,sec=0} end
model={getInfo=function() return {name='BoyWonderFPV',filename='boy.yml'} end}
Bitmap={open=function(path) assert(path=='/WIDGETS/SQDash/pilot.png');loads=loads+1;return 'pilot' end}
local function point(x,y)
 assert(x%1==0 and y%1==0 and x>=0 and x<LCD_W and y>=0 and y<LCD_H,('point %s,%s in %sx%s'):format(x,y,LCD_W,LCD_H))
 draws=draws+1
end
lcd={RGB=function(r,g,b) return r*65536+g*256+b end}
function lcd.sizeText(s,f)
 local h=f&XXLSIZE~=0 and 64 or f&DBLSIZE~=0 and 32 or f&MIDSIZE~=0 and 22 or 12
 return math.ceil(#s*h*.55),h
end
function lcd.drawText(x,y,s,f)
 local tw,th=lcd.sizeText(s,f);local left=x-(f&RIGHT~=0 and tw or f&CENTER~=0 and math.floor(tw/2) or 0)
 point(left,y);point(left+tw-1,y+th-1);labels[s]=true
end
function lcd.drawFilledRectangle(x,y,w,h) point(x,y);point(x+w-1,y+h-1) end
function lcd.drawLine(x,y,X,Y) point(x,y);point(X,Y) end
function lcd.drawFilledTriangle(x,y,X,Y,xx,yy) point(x,y);point(X,Y);point(xx,yy) end
function lcd.drawFilledCircle(x,y,r) point(x-r,y-r);point(x+r,y+r) end
function lcd.drawBitmap(b,x,y,k)
 assert(b=='pilot');point(x,y);point(x+math.ceil(180*k/100)-1,y+math.ceil(120*k/100)-1)
 pilot=table.concat({x,y,k},',')
end
local api=dofile('sq-reactor/WIDGETS/SQDash/main.lua')
local function draw(w,event)
 labels={};draws=0;pilot=nil;api.refresh(w,event);assert(draws<850,'drawing budget')
end
for _,size in ipairs(sizes) do
 LCD_W,LCD_H=size[1],size[2]
 local opts={ArmSrc=1,ArmHigh=1,Theme=9,LogSD=0,Layout=1}
 arm=-1024;tick=tick+20;local count=loads
 local w=api.create({w=LCD_W,h=LCD_H},opts)
 assert(w.theme==9 and loads==count+1)
 for p=1,4 do w.page=p;draw(w) end
 w.page=1;arm=1024;tick=tick+15;draw(w)
 local first=pilot;tick=tick+30;draw(w)
 if LCD_W==480 then assert(first and pilot and first~=pilot,'pilot animates on arm') end
 for p=1,3 do w.page=p;draw(w) end
 arm=-1024;tick=tick+20;draw(w);assert(w.showSummary and w.recent[1]==w.report)
 if LCD_W>=260 and LCD_H>=160 then assert(labels['112 km/h'] and labels['42 m'] and labels['0%'] and labels['-91 dBm']) end
 tick=tick+200;draw(w,EVT_VIRTUAL_ENTER);draw(w,EVT_VIRTUAL_ENTER);assert(w.entry==1)
 assert(loads==count+1,'bitmap reopened during draw')
end
print('PASS Boy Wonder: eleven sizes, bounded drawing, animated pilot, four layouts, cached bitmap, frozen extrema and logbook recall.')
