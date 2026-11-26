-- SQ Reactor v1.0 | Squadding Quads Black Label
-- Decorative, read-only colour widget. No control outputs or SD writes.
local floor,min,max,abs=math.floor,math.min,math.max,math.abs
local rgb=lcd.RGB
local options={{"Theme",VALUE,1,1,5},{"Speed",VALUE,2,0,3},{"React",BOOL,1},{"Telemetry",BOOL,1},{"Callsign",STRING,"SQ"}}
local names={"ION BLUE","TOXIC GREEN","MOLTEN RED","BLACK GOLD","NEON VIOLET"}
local palettes={{52,207,255},{95,247,116},{255,88,46},{239,189,91},{192,99,255}}
local dark=rgb(5,9,15)
local panel=rgb(12,20,28)
local white=rgb(229,242,249)
local muted=rgb(118,145,160)
local C,S={},{}
for i=0,95 do local t=i*math.pi/48;C[i]=math.cos(t);S[i]=math.sin(t) end
local function clamp(n,a,b,d)
 if type(n)~="number" or n~=n then return d end
 return max(a,min(b,floor(n)))
end
local function round(n) return floor(n+0.5) end
local function color(p,k) return rgb(round(p[1]*k),round(p[2]*k),round(p[3]*k)) end
local function update(w,o)
 o=o or {}
 w.theme=clamp(o.Theme,1,5,1)
 w.speed=clamp(o.Speed,0,3,2)
 w.react=o.React==nil or o.React==1 or o.React==true
 w.tele=o.Telemetry==nil or o.Telemetry==1 or o.Telemetry==true
 w.callsign=type(o.Callsign)=="string" and string.sub(o.Callsign,1,8) or "SQ"
 if w.callsign=="" then w.callsign="SQ" end
 local p=palettes[w.theme]
 w.dim=color(p,.22);w.mid=color(p,.52);w.bright=color(p,1)
 w.halo=color(p,.10);w.core=color(p,.18)
 w.pulse={color(p,.34),color(p,.45),color(p,.60),color(p,.78)}
 w.sample=nil;w.volts=nil;w.lq=nil
end
local function create(zone,o)
 local w={zone=zone,started=getTime(),phase=0,energy=0,last=nil}
 update(w,o);return w
end
local function source(name,lo,hi)
 if type(getSourceValue)~="function" then return nil end
 local ok,v,current,fresh=pcall(getSourceValue,name)
 if ok and type(v)=="number" and v==v and v>=lo and v<=hi and current and fresh then return v end
 return nil
end
local function point(cx,cy,r,a)
 a=a%96
 return round(cx+C[a]*r),round(cy+S[a]*r)
end
local function segment(cx,cy,r,a,b,col)
 local x1,y1=point(cx,cy,r,a);local x2,y2=point(cx,cy,r,b)
 lcd.drawLine(x1,y1,x2,y2,SOLID,col)
end
local function radial(cx,cy,r1,r2,a,col)
 local x1,y1=point(cx,cy,r1,a);local x2,y2=point(cx,cy,r2,a)
 lcd.drawLine(x1,y1,x2,y2,SOLID,col)
end
local function arc(cx,cy,r,start,len,col)
 local a=start
 while a<start+len do local b=min(a+4,start+len);segment(cx,cy,r,a,b,col);a=b end
end
local function disc(cx,cy,r,col)
 if r<1 then return end
 if type(lcd.drawFilledCircle)=="function" then lcd.drawFilledCircle(cx,cy,r,col)
 else lcd.drawCircle(cx,cy,r,col) end
end
local function txt(x,y,v,flags,col) lcd.drawText(x,y,v,flags+col) end
local function meter(x,y,width,label,value,accent)
 lcd.drawLine(x,y,x+width,y,SOLID,accent)
 txt(x,y+4,label,SMLSIZE,muted)
 txt(x,y+18,value,MIDSIZE,white)
end
local function refresh(w,event,touch)
 local W,H=w.zone.w,w.zone.h
 if event~=nil then W,H=LCD_W,LCD_H end
 W=floor(W or 0);H=floor(H or 0)
 if W<1 or H<1 then return end
 lcd.drawFilledRectangle(0,0,W,H,dark)
 if W<36 or H<24 then return end
 if W<80 or H<64 then txt(3,3,"SQ",SMLSIZE,w.bright);return end
 local now=getTime()
 local dt=w.last and now-w.last or 0
 if dt<0 or dt>100 then dt=0 end
 w.last=now
 if not w.sample or now-w.sample>=25 or now<w.sample then
  w.sample=now
  w.volts=w.tele and source("tx-voltage",1,30) or nil
  w.lq=w.tele and (source("RQly",0,100) or source("LQ",0,100)) or nil
  if w.react then
   local a=source("ail",-1024,1024) or 0
   local e=source("ele",-1024,1024) or 0
   w.energy=min(1,(abs(a)+abs(e))/1400)
  else w.energy=0 end
 end
 if w.speed>0 then w.phase=(w.phase+dt*(.045*w.speed+.13*w.energy))%96 end
 local p=floor(w.phase)
 local wide=W>=320 and H>=175
 local compact=not wide
 local cx=floor(W/2)
 local cy=wide and floor((H+3)/2) or floor(H/2)
 local r=floor(min(wide and W*.25 or W*.43,H*(wide and .37 or .40)))
 if r<10 then return end
 -- All geometry is scaled and fits inside its widget zone.
 for i=1,3 do
  local inset=2+i*3
  if W>inset*2+3 and H>inset*2+3 then
   lcd.drawRectangle(inset,inset,W-2*inset,H-2*inset,i==1 and w.dim or panel)
  end
 end
 if wide then
  txt(14,9,"SQ / REACTOR",SMLSIZE,w.bright)
  txt(W-14,9,names[w.theme],RIGHT+SMLSIZE,w.bright)
  lcd.drawLine(14,28,W-15,28,SOLID,w.dim)
  lcd.drawLine(14,H-26,W-15,H-26,SOLID,w.dim)
  txt(14,H-22,"BLACK LABEL / V1.0",SMLSIZE,muted)
  txt(W-14,H-22,w.speed==0 and "STATIC" or "REACTOR ONLINE",RIGHT+SMLSIZE,muted)
 end
 disc(cx,cy,r-1,w.halo)
 lcd.drawCircle(cx,cy,r,w.dim)
 lcd.drawCircle(cx,cy,floor(r*.91),w.mid)
 for i=0,23 do
  radial(cx,cy,floor(r*.93),r,i*4,i%3==0 and w.bright or w.dim)
 end
 for i=0,3 do
  arc(cx,cy,floor(r*.84),p+i*24,15,w.bright)
  arc(cx,cy,floor(r*.81),p+i*24,15,w.mid)
  arc(cx,cy,floor(r*.72),-p+i*24,13,w.mid)
  arc(cx,cy,floor(r*.69),-p+i*24,13,w.bright)
 end
 for i=0,7 do
  local a=p+i*12
  radial(cx,cy,floor(r*.53),floor(r*.66),a,w.mid)
  radial(cx,cy,floor(r*.53),floor(r*.66),a+1,w.mid)
  local x,y=point(cx,cy,floor(r*.64),a)
  disc(x,y,max(1,floor(r*.021)),w.bright)
 end
 local core=floor(r*.46)
 disc(cx,cy,core,w.core)
 lcd.drawCircle(cx,cy,core,w.bright)
 local pulse=w.speed==0 and 2 or (floor(p/8)%4+1)
 if w.energy>.65 and w.speed>0 then pulse=4 end
 disc(cx,cy,max(1,floor(core*.80)),w.pulse[pulse])
 disc(cx,cy,max(1,floor(core*.60)),w.core)
 if core>=14 then
  local flags=core>=29 and MIDSIZE or SMLSIZE
  local label=core>=26 and w.callsign or "SQ"
  if type(lcd.sizeText)=="function" and lcd.sizeText(label,flags)>core*1.7 then label="SQ" end
  txt(cx,cy-(flags==MIDSIZE and 11 or 7),label,CENTER+flags,white)
 end
 for i=0,5 do
  local a=(p*2+i*16)%96
  local x,y=point(cx,cy,floor(r*.96),a)
  disc(x,y,max(1,floor(r*.018)),white)
 end
 if wide then
  local side=floor(cx-r-20)
  if side>=58 then
   local v=w.volts and string.format("%.1fV",w.volts) or "--"
   local lq=w.lq and string.format("%d%%",round(w.lq)) or "--"
   local seconds=max(0,floor((now-w.started)/100))
   local session=string.format("%02d:%02d",floor(seconds/60)%100,seconds%60)
   local x=W-side-12
   local y=floor(H*.28)
   meter(12,y,side,"TX VOLTS",v,w.dim)
   meter(12,y+floor(H*.27),side,"SESSION",session,w.dim)
   meter(x,y,side,"RF LINK",lq,w.dim)
   meter(x,y+floor(H*.27),side,"STICK FX",w.react and string.format("%d%%",round(w.energy*100)) or "OFF",w.dim)
  end
 elseif H>=90 and W>=100 then
  txt(cx,H-16,"SQ REACTOR",CENTER+SMLSIZE,w.bright)
 end
end
return {name="SQReact",options=options,create=create,update=update,refresh=refresh}
