-- SQ Pilot Dash v1.4 | Black Label | telemetry read-only, opt-in SD log, colour EdgeTX 2.11+
local floor,min,max=math.floor,math.min,math.max
local rgb=lcd.RGB
local options={{"ArmSrc",SOURCE,0},{"ArmHigh",BOOL,1},{"Cells",VALUE,0,0,12},{"Theme",VALUE,1,1,5},{"MPH",BOOL,0},{"Feet",BOOL,0},{"Layout",VALUE,1,1,4},{"LogSD",BOOL,0}}
local palettes={{67,218,255},{99,234,154},{255,111,75},{229,190,107},{187,137,255}}
local bg=rgb(5,10,17);local panel=rgb(12,22,32);local border=rgb(35,53,66)
local white=rgb(234,244,250);local muted=rgb(139,163,180);local gold=rgb(235,193,109);local red=rgb(255,107,89)
local function clamp(v,a,b,d) if type(v)~="number" or v~=v then return d end return max(a,min(b,floor(v))) end
-- Field metadata and physical units. Unknown units are rejected, not guessed.
local specs={
 speed={{"GSpd","GPS Speed","Speed"},{[4]=1.852,[5]=3.6,[6]=1.09728,[7]=1,[8]=1.609344},0,700},
 volt={{"VFAS","Vbat","Bat","RxBt"},{[1]=1},0.1,100},
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
-- Bounded history: one speed sample per second, at most 36, no SD writes.
local function history(w,now,v)
 if w.histAt and now-w.histAt<100 and now>=w.histAt then return end
 w.histAt=now
 w.hist[#w.hist+1]=v or false
 if #w.hist>36 then table.remove(w.hist,1) end
end
-- One append after observed disarm; incremental history loading when disarmed.
local function num(v) return v and string.format("%.2f",v) or "-" end
local function date()
 local ok,t=pcall(getDateTime)
 if ok and type(t)=="table" and t.year and t.mon and t.day and t.hour and t.min and t.sec then return string.format("%04d-%02d-%02d %02d:%02d:%02d",t.year,t.mon,t.day,t.hour,t.min,t.sec) end
 return "unknown"
end
local function close(f) if f and io then pcall(io.close,f) end end
local function modelId(w)
 local ok,t=pcall(function() return model.getInfo() end)
 if not ok or type(t)~="table" then return end
 w.aircraft=type(t.name)=="string" and t.name or "Aircraft"
 local id=t.filename
 if type(id)=="string" then id=id:match("([^/]+)$") end
 if type(id)=="string" and #id<=64 and id:match("^[%w_.%-]+$") then w.logPath="/LOGS/SQD_"..id..".csv" end
end
local function accept(w,r)
 w.total=w.total+1;w.totalTime=w.totalTime+r.duration
 if not r.partial then
  if r.speed and (not w.allSpeed or r.speed>w.allSpeed) then w.allSpeed=r.speed end
  if not w.allTime or r.duration>w.allTime then w.allTime=r.duration end
  if r.watts and (not w.allPower or r.watts>w.allPower) then w.allPower=r.watts end
 end
 table.insert(w.recent,1,r);if #w.recent>8 then table.remove(w.recent) end
end
local function decode(w,line)
 local a={};for v in (line..","):gmatch("(.-),") do a[#a+1]=v end
 if #a~=15 or a[1]~="SQ14" or a[15]~="END" then return end
 local d=tonumber(a[3]);if not d or d<0 or d>86400 then return end
 accept(w,{date=a[2],duration=d,speed=tonumber(a[4]),avg=tonumber(a[5]),alt=tonumber(a[6]),volt=tonumber(a[7]),amp=tonumber(a[8]),watts=tonumber(a[9]),mah=tonumber(a[10]),lq=tonumber(a[11]),rssi=tonumber(a[12]),endV=tonumber(a[13]),partial=a[14]~="0"})
end
local function readLog(w)
 if not w.logOn then return end
 if not io or not io.open or not io.read or not io.close or not io.write then w.loaded=true;w.logBlocked=true;w.logStatus="SD API UNAVAILABLE";return end
 if w.loaded or not w.logOn or not w.logPath then return end
 if not w.readStarted then
  w.readStarted=true
  local ok,f=pcall(io.open,w.logPath,"r")
  if not ok or not f then w.loaded=true;w.logStatus="SD READY / NEW OR UNREADABLE";return end
  w.reader=f
 end
 if not w.reader then return end
 local ok,b=pcall(io.read,w.reader,256)
 if not ok or type(b)~="string" then close(w.reader);w.reader=nil;w.loaded=true;w.logBlocked=true;w.logStatus="SD READ ERROR";return end
 if #b==0 then close(w.reader);w.reader=nil;w.loaded=true;w.logStatus="SD HISTORY READY";return end
 w.bytes=w.bytes+#b
 if w.bytes>262144 then close(w.reader);w.reader=nil;w.loaded=true;w.logBlocked=true;w.logStatus="ARCHIVE CSV / SIZE LIMIT";return end
 local all=w.buffer..b;local pos=1
 while true do local n=all:find("\n",pos,true);if not n then break end;decode(w,all:sub(pos,n-1):gsub("\r$",""));pos=n+1 end
 w.buffer=all:sub(pos);if #w.buffer>512 then w.buffer="" end
end
local function saveLog(w)
 if not w.pending then return end
 local r=w.pending;w.pending=nil
 if not w.logOn then w.logStatus="SD LOG OFF";return end
 if not w.logPath or not w.loaded or w.logBlocked then w.logStatus="NOT SAVED / SD NOT READY";return end
 local row=table.concat({"SQ14",r.date,num(r.duration),num(r.speed),num(r.avg),num(r.alt),num(r.volt),num(r.amp),num(r.watts),num(r.mah),num(r.lq),num(r.rssi),num(r.endV),r.partial and "1" or "0","END"},",")
 if w.bytes+#row+2>262144 then w.logBlocked=true;w.logStatus="ARCHIVE CSV / SIZE LIMIT";return end
 local ok,f=pcall(io.open,w.logPath,"a")
 if not ok or not f then w.logStatus="NOT SAVED / OPEN FAILED";return end
 local good,result=pcall(io.write,f,"\n",row,"\n");local closed=pcall(io.close,f)
 if good and result and closed then w.bytes=w.bytes+#row+2;accept(w,r);w.logStatus="SD FLIGHT SAVED" else w.logStatus="NOT SAVED / WRITE FAILED" end
end
local function finish(w)
 w.flights=w.flights+1
 local s=w.stats;w.newBest=false
 if s.speed and (not w.bestSpeed or s.speed>w.bestSpeed) then w.bestSpeed=s.speed;w.newBest=true end
 if not w.bestTime or w.elapsed>w.bestTime then w.bestTime=w.elapsed end
 if s.amp and (not w.bestAmp or s.amp>w.bestAmp) then w.bestAmp=s.amp end
 local r={date=date(),duration=w.elapsed,speed=s.speed,avg=s.avg,alt=s.alt,volt=s.volt,amp=s.amp,watts=s.watts,mah=s.mah,lq=s.lq,rssi=s.rssi,endV=w.endVolt,partial=w.gap or w.mahReset or (w.mahPartial and s.mah~=nil) or (w.speedMissing and s.speed~=nil) or (w.voltMissing and s.volt~=nil)}
 if w.logOn then w.pending=r end
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
 if d.volt and d.amp then d.watts=d.volt*d.amp end
 w.data=d
 w.safeInput=armed==false
 if armed==nil then
  if w.state=="FLIGHT" then w.gap=true;history(w,now,nil) end
  w.armUnknown=true
  return
 end
 w.armUnknown=false
 if not w.seenSafe then
  if not armed then w.seenSafe=true;w.state="READY" end
  return
 end
 if armed and w.state~="FLIGHT" then
  if w.pending then w.pending=nil;w.logStatus="NOT SAVED / RE-ARMED" end
  w.state="FLIGHT";w.start=now;w.stats={};w.elapsed=0;w.gap=false;w.startMah=d.mah;w.mahReset=false;w.prevMah=nil;w.mahPartial=d.mah==nil;w.hist={};w.histAt=nil;w.speedSum=0;w.speedN=0;w.newBest=false;w.firstVolt=d.volt;w.endVolt=d.volt;w.speedMissing=false;w.voltMissing=false
 elseif not armed and w.state=="FLIGHT" then
  w.elapsed=max(0,(now-w.start)/100);w.state="REPORT";finish(w);return
 end
 if w.state~="FLIGHT" then return end
 w.elapsed=max(0,(now-w.start)/100)
 local s=w.stats
 history(w,now,d.speed)
 if not d.speed then w.speedMissing=true end
 if not d.volt then w.voltMissing=true else w.endVolt=d.volt end
 if d.speed then w.speedSum=w.speedSum+d.speed;w.speedN=w.speedN+1;s.avg=w.speedSum/w.speedN end
 for _,k in ipairs({"speed","amp","alt","watts"}) do if d[k]~=nil then s[k]=s[k] and max(s[k],d[k]) or d[k] end end
 for _,k in ipairs({"volt","lq","rssi"}) do if d[k]~=nil then s[k]=s[k] and min(s[k],d[k]) or d[k] end end
 if d.mah then
  if not w.startMah then w.startMah=d.mah;w.mahPartial=true end
  if w.prevMah and d.mah<w.prevMah then w.mahReset=true end
  if not w.mahReset then s.mah=max(0,d.mah-w.startMah) else s.mah=nil end
  w.prevMah=d.mah
 end
end
local function update(w,o)
 if w.reader then close(w.reader);w.reader=nil end
 o=o or {};w.armSrc=clamp(o.ArmSrc,0,65535,0);w.high=o.ArmHigh==nil or o.ArmHigh==1 or o.ArmHigh==true
 w.cells=clamp(o.Cells,0,12,0);w.theme=clamp(o.Theme,1,5,1);w.mph=o.MPH==1 or o.MPH==true;w.feet=o.Feet==1 or o.Feet==true;w.layout=clamp(o.Layout,1,4,1);w.page=w.layout;w.logOn=o.LogSD==1 or o.LogSD==true
 local p=palettes[w.theme];w.accent=rgb(p[1],p[2],p[3]);w.dim=rgb(floor(p[1]*.22),floor(p[2]*.22),floor(p[3]*.22))
 w.state="SETUP";w.seenSafe=false;w.armUnknown=true;w.stats={};w.data={};w.elapsed=0;w.last=nil;w.resolved=nil;w.prevMah=nil;w.mahPartial=false;w.hist={};w.histAt=nil;w.flights=0;w.bestSpeed=nil;w.bestTime=nil;w.bestAmp=nil;w.newBest=false
 w.recent={};w.total=0;w.totalTime=0;w.allSpeed=nil;w.allTime=nil;w.allPower=nil;w.bytes=0;w.buffer="";w.loaded=false;w.readStarted=false;w.logBlocked=false;w.pending=nil;w.logPath=nil;w.safeInput=false;w.logStatus=w.logOn and "WAIT DISARM / LOAD SD" or "SD LOG OFF";w.aircraft="Aircraft";modelId(w);if w.logOn and not w.logPath then w.logStatus="SD MODEL ID UNAVAILABLE" end
end
local function create(zone,o) local w={zone=zone};update(w,o);return w end
local function fmt(v,f) return v~=nil and string.format(f,v) or "--" end
local function time(s) s=floor(s or 0);return string.format("%02d:%02d",floor(s/60),s%60) end
local function rect(x,y,W,H,col) if W>0 and H>0 then lcd.drawFilledRectangle(x,y,W,H,col) end end
local function txt(x,y,t,f,c) lcd.drawText(x,y,t,f+c) end
local function line(x,y,X,Y,c) lcd.drawLine(x,y,X,Y,SOLID,c) end
local function card(x,y,W,H,label,value,sub,c)
 rect(x,y,W,H,panel);rect(x+1,y+1,W-2,2,c);lcd.drawRectangle(x,y,W,H,border)
 txt(x+6,y+3,label,SMLSIZE,muted)
 local f=H>=47 and MIDSIZE or SMLSIZE
 if lcd.sizeText and lcd.sizeText(value,f)>W-12 then f=SMLSIZE end
 txt(x+6,y+15,value,f,white)
 if H>=49 and sub then txt(x+6,y+H-14,sub,SMLSIZE,c) end
end
local function refresh(w,event,touch)
 local W,H=w.zone.w,w.zone.h;if event~=nil then W,H=LCD_W,LCD_H end
 if W<1 or H<1 then return end
 rect(0,0,W,H,bg)
 if W<160 or H<100 then if W>=65 and H>=30 then txt(3,3,"SQ DASH",SMLSIZE,w.accent);txt(3,16,"Larger zone",SMLSIZE,muted) end;return end
 local rep=w.state=="REPORT";local d=rep and w.stats or w.data
 local status=w.armSrc==0 and "SET ARM SOURCE" or (w.armUnknown and "ARM UNKNOWN" or (not w.seenSafe and "DISARM TO SYNC" or (rep and "LAST FLIGHT" or (w.state=="FLIGHT" and "ARM INPUT ON" or "STANDBY"))))
 local accent=rep and gold or w.accent
 local sv=d.speed and d.speed*(w.mph and .621371 or 1) or nil
 local unit=w.mph and "mph" or "km/h"
 local voltage=d.volt and w.cells>0 and d.volt/w.cells or nil
 local battery=fmt(d.volt,"%.1f V")
 local cell=voltage and fmt(voltage,"%.2f V/c") or "PACK"
 local duration=time(w.elapsed)
 local alt=d.alt and d.alt*(w.feet and 3.28084 or 1) or nil;local altUnit=w.feet and " ft" or " m"
 txt(6,3,"SQ / PILOT DASH  1.4",SMLSIZE,accent)
 if W>=300 then txt(W-6,3,status,RIGHT+SMLSIZE,w.armUnknown and red or accent) end
 line(6,17,W-7,17,border)
 local page=w.page
 if page==4 and not w.safeInput then page=1 end
 if W>=300 and H>=175 and page~=1 then
  local cw=floor((W-21)/2);local h=floor((H-60)/3);local x=8;local x2=x+cw+5;local y=38
  local function c(i,label,value,sub) card(i%2==0 and x2 or x,y+floor((i-1)/2)*(h+4),cw,h,label,value,sub,accent) end
  if page==2 then
   txt(8,22,"02 / ESSENTIALS",SMLSIZE,accent)
   c(1,rep and "PEAK SPEED" or "GPS SPEED",fmt(sv,"%.0f").." "..unit)
   c(2,rep and "MAX ALT" or "ALTITUDE",fmt(alt,"%.0f"..altUnit))
   c(3,rep and "MIN PACK" or "PACK VOLTAGE",battery,cell);c(4,rep and "MIN LINK" or "LINK QUALITY",fmt(d.lq,"%.0f%%"))
   c(5,"ARM TIME",duration);c(6,rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f W"))
  elseif page==3 then
   txt(8,22,"03 / BATTERY PERFORMANCE",SMLSIZE,accent)
   local sag=w.firstVolt and w.stats.volt and max(0,w.firstVolt-w.stats.volt) or nil
   local m=(rep or w.state=="FLIGHT") and w.stats.mah or nil
   c(1,rep and "MIN PACK" or "LIVE PACK",battery,cell)
   c(2,rep and "LAST ARMED VOLT" or "MIN PACK",fmt(rep and w.endVolt or w.stats.volt,"%.2f V"))
   c(3,"DROP FROM FIRST",fmt(sag,"%.2f V"))
   c(4,rep and "PEAK CURRENT" or "CURRENT",fmt(d.amp,"%.1f A"))
   c(5,"OBSERVED mAh",fmt(m,"%.0f"))
   c(6,rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f W"))
  else
   txt(8,22,"04 / LOGBOOK / "..w.aircraft:sub(1,20),SMLSIZE,accent)
   local factor=w.mph and .621371 or 1
   local h2=H>=230 and 45 or 34
   card(8,39,cw,h2,"SAVED FLIGHTS",tostring(w.total),nil,accent)
   card(x2,39,cw,h2,"AIRCRAFT BEST",fmt(w.allSpeed and w.allSpeed*factor,"%.0f").." "..unit,nil,accent)
   txt(8,43+h2,"TOTAL "..time(w.totalTime).."  |  BEST "..(w.allTime and time(w.allTime) or "--").."  |  "..fmt(w.allPower,"%.0f W"),SMLSIZE,muted)
   local rows=min(#w.recent,floor((H-82-h2)/17))
   for i=1,rows do local r=w.recent[i];local yy=59+h2+(i-1)*17
    txt(8,yy,r.date:sub(1,16)..(r.partial and "*" or ""),SMLSIZE,white)
    txt(W-8,yy,time(r.duration).."  "..fmt(r.speed and r.speed*factor,"%.0f").." "..unit,RIGHT+SMLSIZE,accent)
   end
  end
  txt(8,H-14,w.logStatus,SMLSIZE,muted)
  if W>=400 then txt(W-8,H-14,"PAGE  "..page.."/4",RIGHT+SMLSIZE,accent) end
  return
 end
 if W<300 or H<175 then
  txt(6,21,status,SMLSIZE,w.armUnknown and red or accent)
  txt(6,37,fmt(sv,"%.0f").." "..unit,MIDSIZE,white)
  txt(W-6,39,battery,RIGHT+SMLSIZE,white)
  txt(6,62,"LQ "..fmt(d.lq,"%.0f%%").."  "..duration,SMLSIZE,muted)
  if H>=100 then txt(6,79,(rep and "PEAK / MIN" or "LIVE").."  "..fmt(d.amp,"%.1f A"),SMLSIZE,accent) end
  return
 end
 local margin=8;local gap=5;local side=floor(W*.25);local hero=W-2*side-2*gap-2*margin
 local rich=W>=400 and H>=230
 local y=23;local strip=rich and 43 or 0;local top=floor((H-49-strip)*.61);local bot=H-y-top-gap-19-strip
 local hx=margin+side+gap;local rx=hx+hero+gap
 local ch=floor((top-gap)/2)
 card(margin,y,side,ch,rep and "MIN PACK" or "PACK VOLTAGE",battery,cell,accent)
 card(margin,y+ch+gap,side,top-ch-gap,rep and "PEAK CURRENT" or "CURRENT",fmt(d.amp,"%.1f A"),nil,accent)
 card(rx,y,side,ch,rep and "MIN LINK" or "LINK QUALITY",fmt(d.lq,"%.0f%%"),nil,accent)
 card(rx,y+ch+gap,side,top-ch-gap,rep and "MIN RSSI" or "RSSI dBm",fmt(d.rssi,"%.0f dBm"),nil,accent)
 rect(hx,y,hero,top,panel);lcd.drawRectangle(hx,y,hero,top,border)
 local cx=hx+floor(hero/2);local cy=y+floor(top*.58)
 local radius=floor(min(hero*.43,top*.43))
 if radius>=15 then lcd.drawCircle(cx,cy,radius+2,border) end
 local ratio=sv and min(1,max(0,d.speed/180)) or 0
 for i=0,31 do
  local a=(135+i*270/31)*math.pi/180
  local r1=max(1,radius-(i%4==0 and 8 or 4))
  line(cx+floor(r1*math.cos(a)),cy+floor(r1*math.sin(a)),cx+floor(radius*math.cos(a)),cy+floor(radius*math.sin(a)),sv and i/31<=ratio and accent or w.dim)
 end
 txt(cx,y+5,rep and "PEAK SPEED" or "GPS SPEED",CENTER+SMLSIZE,muted)
 local val=fmt(sv,"%.0f")
 local f=hero>=125 and DBLSIZE or MIDSIZE
 if lcd.sizeText and lcd.sizeText(val,f)>hero-12 then f=MIDSIZE end
 txt(cx,cy-12,val,CENTER+f,white)
 txt(cx,y+top-15,unit,CENTER+SMLSIZE,accent)
 local by=y+top+gap;local bw=floor((W-2*margin-3*gap)/4)
 card(margin,by,bw,bot,"FLIGHT TIME",duration,nil,accent)
 card(margin+bw+gap,by,bw,bot,rep and "MAX ALT" or "ALTITUDE",fmt(alt,"%.0f"..altUnit),nil,accent)
 local m=rep and d.mah or nil;if w.state=="FLIGHT" and d.mah~=nil then m=w.stats.mah end
 card(margin+2*(bw+gap),by,bw,bot,"USED mAh",fmt(m,"%.0f"),nil,accent)
 card(margin+3*(bw+gap),by,bw,bot,rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f W"),nil,accent)
 if rich then
  local sy=by+bot+4;local sw=floor(W*.49);local bx=margin+sw+gap;local rw=W-bx-margin
  rect(margin,sy,sw,strip-6,panel);lcd.drawRectangle(margin,sy,sw,strip-6,border)
  txt(margin+5,sy+2,"SPEED TRACE / 36 SAMPLES",SMLSIZE,muted)
  local peak=1;for i=1,#w.hist do if w.hist[i] then peak=max(peak,w.hist[i]) end end
  local gx=margin+6;local gy=sy+16;local gw=sw-12;local gh=strip-24
  line(gx,gy+gh,gx+gw,gy+gh,border)
  for i=2,#w.hist do
   local a,b=w.hist[i-1],w.hist[i]
   if a and b then line(gx+floor((i-2)*gw/35),gy+gh-floor(a/peak*gh),gx+floor((i-1)*gw/35),gy+gh-floor(b/peak*gh),accent) end
  end
  rect(bx,sy,rw,strip-6,panel);lcd.drawRectangle(bx,sy,rw,strip-6,border)
  local factor=w.mph and .621371 or 1
  if rep then
   txt(bx+5,sy+2,w.newBest and "NEW SESSION SPEED BEST" or "SESSION BEST / PACK "..w.flights,SMLSIZE,accent)
   local av=d.avg and d.avg*factor or nil
   txt(bx+5,sy+16,"BEST "..fmt(w.bestSpeed and w.bestSpeed*factor,"%.0f").."  AVG "..fmt(av,"%.0f").." "..unit,SMLSIZE,white)
  else
   txt(bx+5,sy+2,"POWER / SESSION BEST",SMLSIZE,muted)
   txt(bx+5,sy+16,fmt(d.watts,"%.0f W").."  |  "..fmt(w.bestSpeed and w.bestSpeed*factor,"%.0f").." "..unit,SMLSIZE,white)
  end
 end
 local foot=w.armUnknown and "CHECK ARM SOURCE" or (w.gap and "PARTIAL / ARM OR SAMPLE GAP" or (w.mahReset and "mAh COUNTER RESET" or (w.mahPartial and "mAh PARTIAL" or "BLACK LABEL / V1.4")))
 txt(8,H-14,foot,SMLSIZE,w.gap and red or muted)
 if not w.gap and not w.armUnknown then txt(W-8,H-14,rep and (w.logOn and (w.logStatus=="SD FLIGHT SAVED" and "SAVED" or "SEE LOGBOOK") or "RE-ARM TO RESET") or "READ ONLY",RIGHT+SMLSIZE,muted) end
end
-- Reset consumption bookkeeping on each observed arm edge.
local function poll(w)
 local old=w.state;local before=w.last;sample(w)
 if before~=w.last and w.safeInput and w.seenSafe then readLog(w);if w.loaded or not w.logPath then saveLog(w) end end
 if old~="FLIGHT" and w.state=="FLIGHT" then w.prevMah=w.data.mah;w.mahPartial=w.startMah==nil;w.mahReset=false;w.stats.mah=w.startMah and 0 or nil end
end
-- refresh uses poll via background before drawing; sample is throttled.
local draw=refresh
refresh=function(w,event,touch)
 poll(w)
 if event and event~=0 and w.safeInput then
  if event==EVT_VIRTUAL_NEXT_PAGE or event==EVT_VIRTUAL_NEXT then w.page=w.page%4+1
  elseif event==EVT_VIRTUAL_PREV_PAGE or event==EVT_VIRTUAL_PREV then w.page=(w.page+2)%4+1 end
 end
 draw(w,event,touch)
end
return {name="SQDash",options=options,create=create,update=update,background=poll,refresh=refresh}
