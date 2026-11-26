-- SQ Pilot Dash v1.1 | Black Label | read-only, colour EdgeTX 2.8+
local floor,min,max=math.floor,math.min,math.max
local rgb=lcd.RGB
local options={{"ArmSrc",SOURCE,0},{"ArmHigh",BOOL,1},{"Cells",VALUE,0,0,12},{"Theme",VALUE,1,1,5},{"MPH",BOOL,0}}
local palettes={{67,218,255},{99,234,154},{255,111,75},{229,190,107},{187,137,255}}
local bg=rgb(5,10,17);local panel=rgb(12,22,32);local border=rgb(35,53,66)
local white=rgb(234,244,250);local muted=rgb(139,163,180);local gold=rgb(235,193,109);local red=rgb(255,107,89)
local function clamp(v,a,b,d) if type(v)~="number" or v~=v then return d end return max(a,min(b,floor(v))) end
-- Field metadata and physical units. Unknown units are rejected, not guessed.
local specs={
 speed={{"GSpd","GPS Speed","Speed"},{[4]=1.852,[5]=3.6,[6]=1.09728,[7]=1,[8]=1.609344},0,700},
 volt={{"RxBt","VFAS","Vbat","Bat"},{[1]=1},0.1,100},
 amp={{"Curr","Current"},{[2]=1,[3]=.001},-20,500},
 mah={{"Capa","mAh","Consumption"},{[14]=1},0,100000},
 lq={{"RQly","LQ","Link Quality"},{[13]=1,[0]=1},0,100},
 rssi={{"1RSS","2RSS","RSSI dBm"},{[17]=1},-150,0},
 alt={{"Alt","GAlt","Altitude"},{[9]=1,[10]=.3048},-2000,15000},
}
local function resolve(w)
 w.ids={}
 if type(getFieldInfo)~="function" then return end
 for key,s in pairs(specs) do
  for _,name in ipairs(s[1]) do
   local f=getFieldInfo(name)
   if f and f.id and s[2][f.unit] then w.ids[key]={id=f.id,scale=s[2][f.unit]};break end
  end
 end
end
local function read(id)
 if not id or type(getSourceValue)~="function" then return nil end
 local ok,v,current,fresh=pcall(getSourceValue,id)
 if ok and type(v)=="number" and v==v and current and fresh then return v end
 return nil
end
local function sample(w)
 local now=getTime()
 if w.last and now>=w.last and now-w.last<10 then return end
 if w.last and (now<w.last or now-w.last>100) and w.state=="FLIGHT" then w.gap=true end
 w.last=now
 if not w.resolved or now<w.resolved or now-w.resolved>=300 then resolve(w);w.resolved=now end
 local a=w.armSrc>0 and read(w.armSrc) or nil
 -- Arm source should be a dedicated AUX output or logical/physical switch; middle is unknown.
 local armed=nil
 if a and a>512 then armed=w.high elseif a and a< -512 then armed=not w.high end
 local d={}
 for key,s in pairs(specs) do
  local field=w.ids[key];local v=field and read(field.id) or nil
  if v then v=v*field.scale;if v>=s[3] and v<=s[4] then d[key]=v end end
 end
 w.data=d
 if armed==nil then
  if w.state=="FLIGHT" then w.gap=true end
  w.armUnknown=true
  return
 end
 w.armUnknown=false
 if not w.seenSafe then
  if not armed then w.seenSafe=true;w.state="READY" end
  return
 end
 if armed and w.state~="FLIGHT" then
  w.state="FLIGHT";w.start=now;w.stats={};w.elapsed=0;w.gap=false;w.startMah=d.mah;w.mahReset=false;w.prevMah=nil;w.mahPartial=d.mah==nil
 elseif not armed and w.state=="FLIGHT" then
  w.elapsed=max(0,(now-w.start)/100);w.state="REPORT";return
 end
 if w.state~="FLIGHT" then return end
 w.elapsed=max(0,(now-w.start)/100)
 local s=w.stats
 for _,k in ipairs({"speed","amp","alt"}) do if d[k]~=nil then s[k]=s[k] and max(s[k],d[k]) or d[k] end end
 for _,k in ipairs({"volt","lq","rssi"}) do if d[k]~=nil then s[k]=s[k] and min(s[k],d[k]) or d[k] end end
 if d.mah then
  if not w.startMah then w.startMah=d.mah;w.mahPartial=true end
  if w.prevMah and d.mah<w.prevMah then w.mahReset=true end
  if not w.mahReset then s.mah=max(0,d.mah-w.startMah) else s.mah=nil end
  w.prevMah=d.mah
 end
end
local function update(w,o)
 o=o or {};w.armSrc=clamp(o.ArmSrc,0,65535,0);w.high=o.ArmHigh==nil or o.ArmHigh==1 or o.ArmHigh==true
 w.cells=clamp(o.Cells,0,12,0);w.theme=clamp(o.Theme,1,5,1);w.mph=o.MPH==1 or o.MPH==true
 local p=palettes[w.theme];w.accent=rgb(p[1],p[2],p[3]);w.dim=rgb(floor(p[1]*.22),floor(p[2]*.22),floor(p[3]*.22))
 w.state="SETUP";w.seenSafe=false;w.armUnknown=true;w.stats={};w.data={};w.elapsed=0;w.last=nil;w.resolved=nil;w.prevMah=nil;w.mahPartial=false
end
local function create(zone,o) local w={zone=zone};update(w,o);return w end
local function fmt(v,f) return v~=nil and string.format(f,v) or "--" end
local function time(s) s=floor(s or 0);return string.format("%02d:%02d",floor(s/60),s%60) end
local function rect(x,y,W,H,col) if W>0 and H>0 then lcd.drawFilledRectangle(x,y,W,H,col) end end
local function txt(x,y,t,f,c) lcd.drawText(x,y,t,f+c) end
local function line(x,y,X,Y,c) lcd.drawLine(x,y,X,Y,SOLID,c) end
local function card(x,y,W,H,label,value,sub,c)
 rect(x,y,W,H,panel);rect(x,y,2,H,c);lcd.drawRectangle(x,y,W,H,border)
 txt(x+6,y+3,label,SMLSIZE,muted)
 local f=H>=47 and MIDSIZE or SMLSIZE
 if lcd.sizeText and lcd.sizeText(value,f)>W-12 then f=SMLSIZE end
 txt(x+6,y+15,value,f,white)
 if H>=57 and sub then txt(x+6,y+H-14,sub,SMLSIZE,c) end
end
local function refresh(w,event)
 sample(w)
 local W,H=w.zone.w,w.zone.h;if event~=nil then W,H=LCD_W,LCD_H end
 if W<1 or H<1 then return end
 rect(0,0,W,H,bg)
 if W<160 or H<100 then if W>=65 and H>=30 then txt(3,3,"SQ DASH",SMLSIZE,w.accent);txt(3,16,"Larger zone",SMLSIZE,muted) end;return end
 local rep=w.state=="REPORT" and not w.armUnknown;local d=rep and w.stats or w.data
 local status=w.armSrc==0 and "SET ARM SOURCE" or (w.armUnknown and "ARM UNKNOWN" or (not w.seenSafe and "DISARM TO SYNC" or (rep and "LAST FLIGHT" or (w.state=="FLIGHT" and "ARM INPUT ON" or "STANDBY"))))
 local accent=rep and gold or w.accent
 local sv=d.speed and d.speed*(w.mph and .621371 or 1) or nil
 local unit=w.mph and "mph" or "km/h"
 local voltage=d.volt and w.cells>0 and d.volt/w.cells or nil
 local battery=fmt(d.volt,"%.1f V")
 local cell=voltage and fmt(voltage,"%.2f V/c") or "PACK"
 local duration=time(w.elapsed)
 txt(6,3,"SQ / PILOT DASH",SMLSIZE,accent)
 if W>=300 then txt(W-6,3,status,RIGHT+SMLSIZE,w.armUnknown and red or accent) end
 line(6,17,W-7,17,border)
 if W<300 or H<175 then
  txt(6,21,status,SMLSIZE,w.armUnknown and red or accent)
  txt(6,37,fmt(sv,"%.0f").." "..unit,MIDSIZE,white)
  txt(W-6,39,battery,RIGHT+SMLSIZE,white)
  txt(6,62,"LQ "..fmt(d.lq,"%.0f%%").."  "..duration,SMLSIZE,muted)
  if H>=100 then txt(6,79,(rep and "PEAK / MIN" or "LIVE").."  "..fmt(d.amp,"%.1f A"),SMLSIZE,accent) end
  return
 end
 local margin=8;local gap=5;local side=floor(W*.25);local hero=W-2*side-2*gap-2*margin
 local y=23;local top= floor((H-49)*.57);local bot=H-y-top-gap-19
 local hx=margin+side+gap;local rx=hx+hero+gap
 local ch=floor((top-gap)/2)
 card(margin,y,side,ch,rep and "MIN PACK" or "PACK VOLTAGE",battery,cell,accent)
 card(margin,y+ch+gap,side,top-ch-gap,rep and "PEAK CURRENT" or "CURRENT",fmt(d.amp,"%.1f A"),nil,accent)
 card(rx,y,side,ch,rep and "MIN LINK" or "LINK QUALITY",fmt(d.lq,"%.0f%%"),nil,accent)
 card(rx,y+ch+gap,side,top-ch-gap,rep and "WEAKEST RSSI" or "RSSI dBm",fmt(d.rssi,"%.0f dBm"),nil,accent)
 rect(hx,y,hero,top,panel);lcd.drawRectangle(hx,y,hero,top,border)
 local cx=hx+floor(hero/2);local cy=y+floor(top*.58)
 local radius=floor(min(hero*.43,top*.43))
 local ratio=sv and min(1,max(0,d.speed/180)) or 0
 for i=0,23 do
  local a=(135+i*270/23)*math.pi/180
  local r1=radius-(i%3==0 and 7 or 4)
  line(cx+floor(r1*math.cos(a)),cy+floor(r1*math.sin(a)),cx+floor(radius*math.cos(a)),cy+floor(radius*math.sin(a)),sv and i/23<=ratio and accent or w.dim)
 end
 txt(cx,y+5,rep and "PEAK SPEED" or "GPS SPEED",CENTER+SMLSIZE,muted)
 local val=fmt(sv,"%.0f")
 local f=hero>=125 and DBLSIZE or MIDSIZE
 if lcd.sizeText and lcd.sizeText(val,f)>hero-12 then f=MIDSIZE end
 txt(cx,cy-12,val,CENTER+f,white)
 txt(cx,y+top-15,unit,CENTER+SMLSIZE,accent)
 local by=y+top+gap;local bw=floor((W-2*margin-3*gap)/4)
 card(margin,by,bw,bot,"FLIGHT TIME",duration,nil,accent)
 card(margin+bw+gap,by,bw,bot,rep and "MAX ALT" or "ALTITUDE",fmt(d.alt,"%.0f m"),nil,accent)
 local m=rep and d.mah or nil;if w.state=="FLIGHT" then m=w.stats.mah end
 card(margin+2*(bw+gap),by,bw,bot,"USED mAh",fmt(m,"%.0f"),nil,accent)
 card(margin+3*(bw+gap),by,bw,bot,"PACK / CELL",voltage and fmt(voltage,"%.2f V") or "--",nil,accent)
 local foot=w.armUnknown and "CHECK ARM SOURCE" or (w.gap and "PARTIAL / ARM OR SAMPLE GAP" or (w.mahReset and "mAh COUNTER RESET" or (w.mahPartial and "mAh PARTIAL" or "BLACK LABEL / V1.1")))
 txt(8,H-14,foot,SMLSIZE,w.gap and red or muted)
 txt(W-8,H-14,rep and "RE-ARM TO RESET" or "READ ONLY",RIGHT+SMLSIZE,muted)
end
-- Reset consumption bookkeeping on each observed arm edge.
local function poll(w)
 local old=w.state;sample(w)
 if old~="FLIGHT" and w.state=="FLIGHT" then w.prevMah=w.data.mah;w.mahPartial=w.startMah==nil;w.mahReset=false;w.stats.mah=w.startMah and 0 or nil end
end
-- refresh uses poll via background before drawing; sample is throttled.
local draw=refresh
refresh=function(w,event,touch) poll(w);draw(w,event,touch) end
return {name="SQDash",options=options,create=create,update=update,background=poll,refresh=refresh}
