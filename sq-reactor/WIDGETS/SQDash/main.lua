-- SQ Pilot Dash v1.7 | Black Label | telemetry read-only, opt-in SD log, colour EdgeTX 2.11+
local floor,min,max=math.floor,math.min,math.max
local rgb=lcd.RGB
local options={{"ArmSrc",SOURCE,0},{"ArmHigh",BOOL,1},{"Cells",VALUE,0,0,12},{"Theme",VALUE,6,1,6},{"MPH",BOOL,0},{"Feet",BOOL,0},{"Layout",VALUE,1,1,4},{"LogSD",BOOL,0}}
local palettes={{67,218,255},{99,234,154},{255,111,75},{229,190,107},{187,137,255},{35,221,250}}
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
 w.cells=clamp(o.Cells,0,12,0);w.theme=clamp(o.Theme,1,6,6);w.mph=o.MPH==1 or o.MPH==true;w.feet=o.Feet==1 or o.Feet==true;w.layout=clamp(o.Layout,1,4,1);w.page=w.layout;w.logOn=o.LogSD==1 or o.LogSD==true
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
-- Velocity: layered bevels, six compact instrument pods, large timer, trace and gold peak rail.
-- Uses integer LCD primitives only; no bitmaps, animations, file I/O or new sensors.
local navy=rgb(7,17,27);local glass=rgb(12,31,44);local bevel=rgb(33,71,88)
local cyan=rgb(35,221,250);local dimCyan=rgb(16,67,83);local bronze=rgb(71,53,24)
local shine=rgb(40,83,108);local shade=rgb(12,24,36);local ice=rgb(110,202,232);local green=rgb(88,224,164)
local function shell(x,y,W,H,c,inside)
 if W<12 or H<10 then return end
 local k=min(7,floor(H/3))
 rect(x+k,y,W-2*k,H,inside);rect(x,y+k,W,H-2*k,inside)
 -- Stepped corner fill and restrained glass highlight, no alpha/bitmap dependency.
 rect(x+2,y+2,W-4,H-4,inside)
 if H>=22 then
  rect(x+k,y+3,W-2*k,max(2,floor(H/4)),inside==bronze and bronze or rgb(22,47,64))
  line(x+k,y+2,x+W-k-1,y+2,inside==bronze and gold or shine)
  line(x+k,y+H-3,x+W-k-1,y+H-3,shade)
 end
 line(x+k,y,x+W-k-1,y,c);line(x+k,y+H-1,x+W-k-1,y+H-1,c)
 line(x,y+k,x,y+H-k-1,c);line(x+W-1,y+k,x+W-1,y+H-k-1,c)
 line(x,y+k,x+k,y,c);line(x+W-k-1,y,x+W-1,y+k,c)
 line(x,y+H-k-1,x+k,y+H-1,c);line(x+W-k-1,y+H-1,x+W-1,y+H-k-1,c)
 if H>=18 then line(x+k+2,y+2,x+W-k-3,y+2,bevel) end
end
local function fit(x,y,v,f,c,maxW)
 if lcd.sizeText and lcd.sizeText(v,f)>maxW then f=SMLSIZE end
 txt(x,y,v,CENTER+f,c)
end
local function pod(x,y,W,H,label,value,c)
 shell(x,y,W,H,bevel,glass)
 txt(x+7,y+3,label,SMLSIZE,muted)
 local f=H>=41 and MIDSIZE or SMLSIZE
 if lcd.sizeText and lcd.sizeText(value,f)>W-14 then f=SMLSIZE end
 txt(x+7,y+15,value,f,white)
 if W>=95 and H>=37 then rect(x+W-10,y+7,3,3,c) end
end
-- V15 native landscape: never scale horizontal and vertical coordinates independently.
-- Reflow to the actual widget zone; full view 480x272, reduced home zone >= 400x190.
local function velocity(w,W,H,d,rep,status,sv,unit,alt,altUnit,duration)
 if W<400 or H<190 or W/H<1.45 then return false end
 local accent=rep and gold or cyan
 local m=6;local g=5;local footer=14
 local header=H>=250 and 43 or 30
 local railH=H>=250 and 31 or 24
 local traceH=H>=250 and 33 or 25
 local railY=H-footer-railH
 local traceY=railY-g-traceH
 local y=header+g;local h=traceY-y-g
 local side=floor((W-2*m-2*g)*.29);local center=W-2*m-2*g-2*side
 local left=m;local right=W-m-side;local mid=m+side+g
 local cx=mid+floor(center/2);local cy=y+floor(h/2)
 local ph=floor((h-2*g)/3)
 if ph<22 or center<90 then return false end
 rect(0,0,W,H,bg)
 shell(m,3,side,header-4,bevel,navy)
 txt(m+7,6,"SQ / VELOCITY",SMLSIZE,accent)
 txt(m+7,header>=36 and 23 or 17,rep and "FLIGHT REPORT" or "BLACK LABEL",SMLSIZE,muted)
 shell(mid,3,center,header-4,rep and gold or dimCyan,navy)
 local timerLabel=rep and "LAST ARM TIME" or "ARM TIME"
 txt(cx,5,timerLabel,CENTER+SMLSIZE,accent)
 fit(cx,header>=40 and 15 or 16,duration,header>=40 and DBLSIZE or SMLSIZE,white,center-26)
 if header>=40 then
  line(mid+9,23,mid+18,14,gold);line(mid+9,23,mid+18,32,gold)
  line(mid+center-10,23,mid+center-19,14,gold);line(mid+center-10,23,mid+center-19,32,gold)
 end
 shell(right,3,side,header-4,bevel,navy)
 fit(right+floor(side/2),6,status,SMLSIZE,w.armUnknown and red or accent,side-10)
 fit(right+floor(side/2),header>=36 and 20 or 17,"PACK "..(w.flights+(w.state=="FLIGHT" and 1 or 0)),SMLSIZE,muted,side-10)
 local function tile(x,i,label,value,kind)
  local yy=y+i*(ph+g)
  shell(x,yy,side,ph,bevel,glass)
  if ph>=36 then
   local ix=x+12;local iy=yy+floor(ph/2)
   local iconColor=rep and gold or ice
   if kind=="volt" or kind=="power" then
    line(ix+3,iy-9,ix-3,iy,iconColor);line(ix-3,iy,ix+3,iy,iconColor);line(ix+3,iy,ix-2,iy+8,iconColor)
   elseif kind=="amp" then
    lcd.drawCircle(ix,iy,7,iconColor);txt(ix,iy-5,"A",CENTER+SMLSIZE,iconColor)
   elseif kind=="alt" then
    line(ix-8,iy+5,ix-1,iy-6,iconColor);line(ix-1,iy-6,ix+5,iy+5,iconColor);line(ix+2,iy-1,ix+8,iy+5,iconColor)
   else
    for j=0,3 do
     local level=kind=="link" and d.lq and floor(d.lq*4/100+.5) or 0
     local col=kind=="link" and (j<level and green or dimCyan) or iconColor
     if kind=="link" then rect(ix-7+j*4,iy+5-(j+1)*3,2,(j+1)*3,col)
     else line(ix-6+j*4,iy+5,ix-6+j*4,iy+3-j*2,col) end
    end
   end
   txt(x+25,yy+3,label,SMLSIZE,muted)
   local fl=MIDSIZE
   if lcd.sizeText and lcd.sizeText(value,fl)>side-31 then fl=SMLSIZE end
   txt(x+25,yy+15,value,fl,white)
  else
   txt(x+6,yy+floor((ph-12)/2),label,SMLSIZE,muted)
   txt(x+side-6,yy+floor((ph-12)/2),value,RIGHT+SMLSIZE,white)
  end
 end
 tile(left,0,rep and "MIN V" or "VOLT",fmt(d.volt,"%.2f V"),"volt")
 tile(left,1,rep and "MAX A" or "AMPS",fmt(d.amp,"%.1f A"),"amp")
 tile(left,2,rep and "MAX W" or "POWER",fmt(d.watts,"%.0f W"),"power")
 tile(right,0,rep and "MIN LQ" or "LINK",fmt(d.lq,"%.0f%%"),"link")
 tile(right,1,rep and "MIN RF" or "RSSI",fmt(d.rssi,"%.0f dBm"),"rssi")
 tile(right,2,rep and "MAX ALT" or "ALT",fmt(alt,"%.0f"..altUnit),"alt")
 shell(mid,y,center,h,bevel,navy)
 -- Equal pixel radii: circular dial, even in an inset widget zone.
 local r=floor(min((center-12)/2,(h-10)/2))
 local ratio=d.speed and min(1,max(0,d.speed/180)) or -1
 if r>=21 then
  lcd.drawCircle(cx,cy,r,bevel)
  if r>=36 then lcd.drawCircle(cx,cy,r-12,dimCyan) end
  for i=0,31 do
   local angle=(135+i*270/31)*math.pi/180
   local ca,sa=math.cos(angle),math.sin(angle)
   local col=i/31<=ratio and accent or dimCyan
   local inner=r-(i%4==0 and 11 or 8)
   for j=-1,1 do
    local aa=angle+j*.022
    line(cx+floor(inner*math.cos(aa)),cy+floor(inner*math.sin(aa)),cx+floor((r-2)*math.cos(aa)),cy+floor((r-2)*math.sin(aa)),col)
   end
  end
 end
 txt(cx,cy-(r>=46 and 31 or 25),rep and "PEAK SPEED" or "GPS SPEED",CENTER+SMLSIZE,muted)
 fit(cx,cy-13,fmt(sv,"%.0f"),r>=46 and DBLSIZE or MIDSIZE,white,center-22)
 txt(cx,cy+(r>=46 and 17 or 10),unit,CENTER+SMLSIZE,accent)
 shell(m,traceY,W-2*m,traceH,bevel,navy)
 local sf=w.mph and .621371 or 1
 local hi=1;local have=false
 for i=1,#w.hist do if w.hist[i] then hi=max(hi,w.hist[i]);have=true end end
 txt(m+7,traceY+3,"SPEED TRACE",SMLSIZE,muted)
 txt(W-m-7,traceY+3,have and fmt(hi*sf,"%.0f").." "..unit or "--",RIGHT+SMLSIZE,muted)
 local gx=m+7;local gw=W-2*m-14;local gy=traceY+15;local gh=traceH-19
 for i=0,4 do local xx=gx+floor(i*gw/4);line(xx,gy,xx,gy+gh,border) end
 line(gx,gy+gh,gx+gw,gy+gh,border)
 for i=2,#w.hist do local aa,bb=w.hist[i-1],w.hist[i]
  if aa and bb then line(gx+floor((i-2)*gw/35),gy+gh-floor(aa/hi*gh),gx+floor((i-1)*gw/35),gy+gh-floor(bb/hi*gh),accent) end
 end
 shell(m,railY,W-2*m,railH,gold,bronze)
 local cut1=m+floor((W-2*m)*.22);local cut2=m+floor((W-2*m)*.61)
 local ps=w.stats.speed and w.stats.speed*sf or nil
 local pa=w.stats.alt and w.stats.alt*(w.feet and 3.28084 or 1) or nil
 local yy=railY+floor((railH-12)/2)
 if W>=440 then
  line(m+9,yy+1,m+21,yy+1,gold);line(m+10,yy+2,m+14,yy+7,gold);line(m+20,yy+2,m+16,yy+7,gold);line(m+15,yy+7,m+15,yy+11,gold);line(m+11,yy+11,m+19,yy+11,gold)
  txt(m+26,yy,"PEAKS",SMLSIZE,gold)
 else txt(m+8,yy,"PEAKS",SMLSIZE,gold) end
 line(cut1,railY+4,cut1,railY+railH-5,gold);line(cut2,railY+4,cut2,railY+railH-5,gold)
 txt(cut1+6,yy,"SPD",SMLSIZE,gold);txt(cut2-6,yy,fmt(ps,"%.0f").." "..unit,RIGHT+SMLSIZE,white)
 txt(cut2+6,yy,"ALT",SMLSIZE,gold);txt(W-m-7,yy,fmt(pa,"%.0f"..altUnit),RIGHT+SMLSIZE,white)
 local note=w.armUnknown and "CHECK ARM SOURCE" or (w.gap and "PARTIAL / SAMPLE GAP" or (w.mahReset and "mAh RESET" or (rep and w.logOn and (w.logStatus=="SD FLIGHT SAVED" and "SD SAVED" or "SEE LOGBOOK") or "BLACK LABEL / V1.7")))
 txt(m,H-12,note,SMLSIZE,muted)
 local used=(rep or w.state=="FLIGHT") and w.stats.mah or nil
 txt(W-m,H-12,fmt(used,"%.0f mAh"),RIGHT+SMLSIZE,muted)
 return true
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
 txt(6,3,"SQ / PILOT DASH  1.7",SMLSIZE,accent)
 if W>=300 then txt(W-6,3,status,RIGHT+SMLSIZE,w.armUnknown and red or accent) end
 line(6,17,W-7,17,border)
 local page=w.page
 if page==4 and not w.safeInput then page=1 end
 if page==1 and w.theme==6 and W>=400 and H>=190 and velocity(w,W,H,d,rep,status,sv,unit,alt,altUnit,duration) then return end
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
 local foot=w.armUnknown and "CHECK ARM SOURCE" or (w.gap and "PARTIAL / ARM OR SAMPLE GAP" or (w.mahReset and "mAh COUNTER RESET" or (w.mahPartial and "mAh PARTIAL" or "BLACK LABEL / V1.7")))
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
