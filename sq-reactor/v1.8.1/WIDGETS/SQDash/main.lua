-- SQ Pilot Dash v1.8.1 | Apex Nocturne | telemetry read-only, opt-in SD log, colour EdgeTX 2.11+
local floor,min,max=math.floor,math.min,math.max
local rgb=lcd.RGB
local options={{"ArmSrc",SOURCE,0},{"ArmHigh",BOOL,1},{"Cells",VALUE,0,0,12},{"Theme",VALUE,7,1,7},{"MPH",BOOL,0},{"Feet",BOOL,0},{"Layout",VALUE,1,1,4},{"LogSD",BOOL,0}}
local palettes={{67,218,255},{99,234,154},{255,111,75},{229,190,107},{187,137,255},{35,221,250},{216,183,130}}
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
 w.cells=clamp(o.Cells,0,12,0);w.theme=clamp(o.Theme,1,7,7);w.mph=o.MPH==1 or o.MPH==true;w.feet=o.Feet==1 or o.Feet==true;w.layout=clamp(o.Layout,1,4,1);w.page=w.layout;w.logOn=o.LogSD==1 or o.LogSD==true
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
-- Apex: sparse instrument hierarchy. All drawing is local to the widget zone.
-- Seven-segment numerals use LCD rectangles/triangles; no bitmap/font assets.
local apexBg=rgb(8,12,16);local apexPanel=rgb(17,23,29);local apexLine=rgb(44,55,63)
local apexWhite=rgb(241,244,239);local apexMuted=rgb(149,165,175)
local apexBlue=rgb(98,218,231);local apexDim=rgb(29,57,64);local apexAmber=rgb(244,190,91)
local apexDigits={"abcdef","bc","abdeg","abcdg","bcfg","acdfg","acdefg","abc","abcdefg","abcdfg"}
local function measure(s,f)
 if lcd.sizeText then return lcd.sizeText(s,f) end
 return #s*7,14
end
local function textBox(x,y,W,H,s,c,align,big)
 s=tostring(s)
 local fonts=big and {XXLSIZE or DBLSIZE,DBLSIZE,MIDSIZE,SMLSIZE} or {MIDSIZE,SMLSIZE}
 local f=SMLSIZE;local tw,th
 for _,ff in ipairs(fonts) do tw,th=measure(s,ff);if tw<=W and th<=H then f=ff;break end end
 tw,th=measure(s,f)
 if tw>W then s="--";tw,th=measure(s,f) end
 local xx=x;if align==CENTER then xx=x+floor(W/2) elseif align==RIGHT then xx=x+W end
 txt(xx,y+max(0,floor((H-th)/2)),s,f+(align or 0),c)
end
local function caption(x,y,W,s,c,align)
 local tw=measure(s,SMLSIZE)
 while tw>W and #s>1 do s=s:sub(1,-2);tw=measure(s,SMLSIZE) end
 txt(align==CENTER and x+floor(W/2) or (align==RIGHT and x+W or x),y,s,SMLSIZE+(align or 0),c or apexMuted)
end
local function numerals(cx,y,s,h,c)
 local scale=h/48;local width=(#s*34-6)*scale;local x=cx-width/2
 local function polygon(points)
  local q={};for i=1,#points,2 do q[#q+1]=floor(x+points[i]*scale+.5);q[#q+1]=floor(y+points[i+1]*scale+.5) end
  for i=3,#q-2,2 do lcd.drawFilledTriangle(q[1],q[2],q[i],q[i+1],q[i+2],q[i+3],c) end
 end
 local shapes={a={4,0,24,0,21,5,7,5},g={7,21,21,21,25,24,21,27,7,27,3,24},d={7,43,21,43,24,48,4,48},
 b={23,6,28,2,28,21,23,24},c={23,26,28,29,28,46,23,42},e={0,29,5,26,5,42,0,46},f={0,2,5,6,5,24,0,21}}
 for i=1,#s do
  local ch=s:sub(i,i);local n=tonumber(ch);local segments=n and apexDigits[n+1] or "g"
  for j=1,#segments do polygon(shapes[segments:sub(j,j)]) end
  x=x+34*scale
 end
end
local function apex(w,W,H,d,rep,status,sv,unit,alt,altUnit,duration,page)
 if W<360 or H<180 or W/H<1.4 or (page==1 and H<210) then return false end
 local a=rep and apexAmber or apexBlue;local m=10;local gap=6
 local rich=H>=245;local header=rich and 34 or 28
 local footer=18;local smallH=select(2,measure("A",SMLSIZE))
 rect(0,0,W,H,apexBg)
 -- Brand and state share one calm header; model names are measured and clipped.
 rect(m,7,25,18,a);txt(m+3,8,"SQ",SMLSIZE,apexBg)
 local chip=min(154,floor(W*.34));local chipX=W-m-chip
 caption(43,8,chipX-51,w.aircraft:upper(),apexWhite)
 local sc=(w.armUnknown or not w.seenSafe) and red or a
 rect(chipX,6,chip,20,rep and rgb(44,34,20) or apexPanel)
 caption(chipX+4,8,chip-8,status,sc,CENTER)
 line(m,header-1,W-m-1,header-1,apexLine)
 local note=w.armUnknown and "CHECK ARM SOURCE" or (w.gap and "PARTIAL / SAMPLE GAP" or (rep and w.speedMissing and "PARTIAL / GPS SAMPLES" or (not rep and not d.speed and "GPS SPEED UNAVAILABLE" or (w.mahReset and "mAh COUNTER RESET" or (w.mahPartial and "mAh PARTIAL" or (rep and w.logOn and w.logStatus or "APEX / V1.8"))))))
 caption(m,H-footer+2,W-65,note,(w.armUnknown or w.gap or w.mahReset) and red or apexMuted)
 caption(W-48,H-footer+2,38,page.." / 4",a,RIGHT)
 local sf=w.mph and .621371 or 1
 local function tile(x,y,tw,th,label,value,unitText,sub)
  rect(x,y,tw,th,apexPanel);rect(x,y,2,th,apexLine)
  local pad=tw>=120 and 9 or 7
  caption(x+pad,y+3,tw-2*pad,label,apexMuted)
  local valH=th-smallH-9
  if sub and th>=65 then valH=valH-smallH end
  local unitW=measure(unitText,SMLSIZE)
  textBox(x+pad,y+smallH+4,tw-2*pad-unitW-4,valH,value,apexWhite,0,th>=65)
  caption(x+tw-pad-unitW,y+th-smallH-4,unitW,unitText,a)
  if sub and th>=65 then caption(x+pad,y+th-smallH-4,tw-2*pad-unitW-8,sub,apexMuted) end
 end
 if page==1 then
  -- 24 light segments encode speed only, on a fixed 0..180 km/h scale.
  local ledY=header+5;local ledH=rich and 5 or 3;local ledGap=3
  local ledW=(W-2*m-23*ledGap)/24
  local ratio=d.speed and max(0,min(1,d.speed/180)) or 0
  for i=0,23 do local x=m+floor(i*(ledW+ledGap));rect(x,ledY,floor(ledW),ledH,i<math.ceil(ratio*24) and a or apexDim) end
  local y=ledY+ledH+7;local railH=rich and 42 or 31;local railY=H-footer-railH-4
  local h=railY-y-gap;local side=floor((W-2*m)*.245);local center=W-2*m-2*side-2*gap
  local mid=m+side+gap;local cx=mid+floor(center/2);local right=W-m-side
  local th=floor((h-2*gap)/3)
  if th<29 then return false end
  tile(m,y,side,th,rep and "MIN PACK" or "PACK",fmt(d.volt,"%.2f"),"V")
  tile(m,y+th+gap,side,th,rep and "PEAK AMPS" or "CURRENT",fmt(d.amp,"%.1f"),"A")
  tile(m,y+2*(th+gap),side,th,rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f"),"W")
  tile(right,y,side,th,rep and "MIN LINK" or "LINK",fmt(d.lq,"%.0f"),"%")
  tile(right,y+th+gap,side,th,rep and "MIN RSSI" or "RSSI",fmt(d.rssi,"%.0f"),"dBm")
  tile(right,y+2*(th+gap),side,th,rep and "MAX ALT" or "ALTITUDE",fmt(alt,"%.0f"),altUnit:gsub(" ",""))
  caption(mid,y+1,center,rep and "PEAK GROUND SPEED" or "GPS GROUND SPEED",apexMuted,CENTER)
  local digits=fmt(sv,"%03.0f");local nh=min(rich and 64 or 43,floor(h*.42),floor((center-18)*48/(#digits*34-6)))
  local ny=y+smallH+8
  numerals(cx,ny,digits,nh,apexWhite)
  caption(mid,ny+nh+5,center,unit,a,CENTER)
  -- A small central trace supports the number without competing with it.
  if rich and h>=150 then
   local gx=mid+12;local gw=center-24;local gy=ny+nh+smallH+14;local gh=max(6,h-(gy-y)-36)
   line(gx,gy+gh,gx+gw,gy+gh,apexLine)
   local hi=1;for i=1,#w.hist do if w.hist[i] then hi=max(hi,w.hist[i]) end end
   for i=2,#w.hist do local aa,bb=w.hist[i-1],w.hist[i];if aa and bb then line(gx+floor((i-2)*gw/35),gy+gh-floor(aa/hi*gh),gx+floor((i-1)*gw/35),gy+gh-floor(bb/hi*gh),a) end end
  end
  local timerH=rich and 27 or 20
  textBox(mid+65,y+h-timerH,center-68,timerH,duration,apexWhite,CENTER,false)
  -- Arm time label shares the rail; units always remain attached to values.
  local rw=floor((W-2*m-2*gap)/3)
  local vals={{"PEAK SPEED",fmt(w.stats.speed and w.stats.speed*sf,"%.0f"),unit},{"PEAK ALT",fmt(w.stats.alt and w.stats.alt*(w.feet and 3.28084 or 1),"%.0f"),altUnit:gsub(" ","")},{"USED",fmt((rep or w.state=="FLIGHT") and w.stats.mah or nil,"%.0f"),"mAh"}}
  for i,v in ipairs(vals) do
   local x=m+(i-1)*(rw+gap);line(x,railY,x+rw-1,railY,rep and a or apexLine)
   caption(x+3,railY+4,rw-6,v[1],rep and a or apexMuted)
   local uh=measure(v[3],SMLSIZE)
   textBox(x+3,railY+smallH+4,rw-uh-13,railH-smallH-5,v[2],apexWhite,0,false)
   caption(x+rw-uh-3,railY+railH-smallH-1,uh,v[3],a)
  end
  -- Timer is explicitly labelled; radio arm input is not confirmed FC arming.
  caption(mid+3,y+h-timerH+5,65,rich and "ARM TIME" or "ARM",apexMuted)
 elseif page==2 or page==3 then
  caption(m,header+5,W-2*m,page==2 and "ESSENTIALS" or "BATTERY / OBSERVED",a)
  local y=header+smallH+12;local tw=floor((W-2*m-gap)/2);local th=floor((H-footer-y-2*gap-4)/3)
  local values
  if page==2 then values={{rep and "PEAK GROUND SPEED" or "GPS GROUND SPEED",fmt(sv,"%.0f"),unit},{rep and "MAX ALTITUDE" or "ALTITUDE",fmt(alt,"%.0f"),altUnit:gsub(" ","")},{rep and "MIN PACK" or "PACK VOLTAGE",fmt(d.volt,"%.2f"),"V"},{rep and "MIN LINK" or "LINK QUALITY",fmt(d.lq,"%.0f"),"%"},{"ARM TIME",duration,""},{rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f"),"W"}}
  else
   local sag=w.firstVolt and w.stats.volt and max(0,w.firstVolt-w.stats.volt) or nil
   values={{rep and "MIN PACK" or "LIVE PACK",fmt(d.volt,"%.2f"),"V"},{rep and "LAST ARMED VOLT" or "MIN PACK",fmt(rep and w.endVolt or w.stats.volt,"%.2f"),"V"},{"DROP FROM FIRST",fmt(sag,"%.2f"),"V"},{rep and "PEAK CURRENT" or "CURRENT",fmt(d.amp,"%.1f"),"A"},{"OBSERVED CAPACITY",fmt((rep or w.state=="FLIGHT") and w.stats.mah or nil,"%.0f"),"mAh"},{rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f"),"W"}}
  end
  for i,v in ipairs(values) do tile(m+((i-1)%2)*(tw+gap),y+floor((i-1)/2)*(th+gap),tw,th,v[1],v[2],v[3]) end
 else
  caption(m,header+5,W-2*m,"AIRCRAFT LOGBOOK",a)
  local y=header+smallH+12;local tw=floor((W-2*m-gap)/2);local th=rich and 51 or 40
  tile(m,y,tw,th,"SAVED FLIGHTS",tostring(w.total),"")
  tile(m+tw+gap,y,tw,th,"BEST GROUND SPEED",fmt(w.allSpeed and w.allSpeed*sf,"%.0f"),unit)
  local yy=y+th+8
  caption(m,yy,W-2*m,"TOTAL "..time(w.totalTime).."  /  PEAK "..fmt(w.allPower,"%.0f W"),apexMuted)
  yy=yy+smallH+6
  if #w.recent==0 then
   caption(m,yy,W-2*m,w.logOn and "NO SAVED FLIGHTS" or "ENABLE LogSD TO SAVE FLIGHTS",apexWhite)
  else
   local rows=min(#w.recent,floor((H-footer-smallH-8-yy)/(smallH+7)))
   for i=1,rows do
    local r=w.recent[i];local yy2=yy+(i-1)*(smallH+7)
    if i%2==1 then rect(m,yy2-1,W-2*m,smallH+5,apexPanel) end
    caption(m+5,yy2,floor(W*.51),r.date:sub(1,16)..(r.partial and "*" or ""),apexWhite)
    caption(floor(W*.54),yy2,floor(W*.46)-m-5,time(r.duration).." / "..fmt(r.speed and r.speed*sf,"%.0f").." "..unit,a,RIGHT)
   end
  end
  caption(m,H-footer-smallH-5,W-2*m,w.logStatus,apexMuted)
 end
 return true
end

-- Original Nocturne numeral outlines, triangulated at build time.
local figures = {
  { [===[4(3$0&2.+*)./A'5%D1Y&Q+\/`/O6a8c8a@XB`G\IXCEKQMBC&A-G*?'@$6&:#05>^?bL53_C72b<`:%<%BQ]===], [===[$%&'()*+,-./-/0,1*2345675789:;<=>?<@%ABC)+1,..-16DE>=FC+*G-0HF=)C'IG0('&GI2&'$32I%$AJ43BAKEJ3LBKEDJBL@65D@L?M58<?=:M8FH;M:99;H]===] },
  { [===[4+*36/4`*a*cB`KcKa@#=#)0@^6^]===], [===[$%&'()*+,&-.%$/+').$&+*'-&00'*0&1'01]===] },
  { [===[&4'7)925.90722+YIcCYGVLRJRL6B5J<L3A,I*D%?(@$9&4$5'/-)*'/?=K./+/&%c1(%_5MDC:#=']===], [===[$%&'()('*+,-./0123214567879:;<=>?*?$($&?*=/.,@3265A>BC(*$,.->=B,+DECBD+FCE;GF+;E<HG+;:IH@GJI:3@HIJ9A249J82A5785]===] },
  { [===[*++00)<C2@1C-R2Y2V0T'U*R(S&X/^'[)^,`0b5a:c:aKYBZH]CSMTAHIFFD@FABK3B3I9B/K/A+J+F&='B$=#.'3$(/:?C`?;4'7&<A8#1_4c=`D=@]=>LLCN]===], [===[$%&'()*+,,-*./0/.1234256789:;<=:>?@ABACDEFGDHIJKLMNO&P&O$%$Q('R/+*+/1245<;S?ABTFEIKMUP&VPUW'B3+1BCWPVX+32XVN26YNVLZY6IMLYZ7JIG87ZJGH[98DGES[8FT\[S]^\TS;]\^W:=;W^R_=>'WR=_``@?@`_]===] },
  { [===[(M$N$R;1;R9`2a2cF`LcLaDMLRMMD#@#;MDR;_D^]===], [===[$%&%$'($&)*+,-./01'23%'3$(4-)+0/52'/,)-4/'),6/456,7(54(675(7]===] },
  { [===[-?)C,D+R2W.R1T&V(S&Y/^'\*_3a/b7c@]=bE^CTKWMQCJLHIB>BB><</B3=H%I-M$L#1\;@7</-5@-%:a=_AF]===], [===[$%&'()(*)+','+-./0123456789:;<=>?@A$BCDDEB(-F('-.02;:9G?HCBI/F-AJHIBKF/.%IK21.I%$L13$&@5L3A@JL5MHJG54M?G=746N>=876>N<79:<N:]===] },
  { [===[E&J&D#8)7%0)4.-,24)3&=/I%B&P0a1Z+]3^3b;a9cBaA[G^KWCRMQLH>@F>?;<?8;2C3>/BI(<'@BIA6@@&?#BG0T>_(W7a]===], [===[$%&'()*)+,-./01234526789:;<=>?@ABCBDEFGG/E%$H('IG.0253=<>AJKLFEM$&FLDNM&DLCMNIBC@(INA@J)*'OKJ,*+KO?-,+?O=,.G<=:0/G;:9P/19:QRP19Q7PR3S8743R8S6S56]===] },
  { [===[+0%6'6;U5O2Y/c9bF-M'M$($/->ID8]===], [===[$%&'())*+,-.%$/)+'/$0('1,/02(1/,.(2,-,2]===] },
  { [===[2(2$+(/0(-'203'6):28->'L-L+G+R+X&X(\-[+_1_5c6a?_>bF_EWKZMUCPMNJI4D?@<?K3E4I8E/J,C*H)E&>%A$:#0+/H%RESC8B(7<2B6%AM/b<aC\E<@<ED]===], [===[$%&'()*+,-,.)*'/010/234565789:;<=>?@ABCDEFGHIJGKLMNOPQ*)+(R&,-*S10T2/243BU@VIHWNPR('X-.1SY42T&R$YX.YSD563Z%$DXYED[867%ZQXDF\87QZOC[A98\WPO]:9NWL<]9JML<;]MJK^;=GJH?^=IV_^?>`_V>@U_`EBAUE`Fa[CE[a]===] },
  { [===[,_'_.b:];aB]>XEZ@RLICDC=MDL6B%?(E'<#1+3$+(/4'/%50?&>)E2D,H6G1J8K@C>H(]6`3cA,0`4'4F7%<F;%ISI,B2]===], [===[$%&'()*)+,-./012343256789:;<=>?>@=<9ABCDE.%$F(GH.-0I43=9;:68>?<J$&6:9B?@HJ&76K?BLJHG7KMLBA('G7M5NAC)*'5MOENC,*+5O3NEDP,+4IQ/D.-,PRQI0/.QR1R/1]===] },
}

-- Nocturne uses warm metal only for instrument marks. Error text has its own ink.
local noir = {
  black=rgb(16,14,15), field=rgb(26,23,24), ivory=rgb(248,239,221),
  gilt=rgb(216,183,130), soft=rgb(192,178,164), rule=rgb(77,65,62),
  wine=rgb(76,28,41), rose=rgb(255,148,139),
}

-- A cut lapel forms the SQ Apex hallmark; the same mark appears on the case.
local function hallmark(x,y,c)
  lcd.drawFilledTriangle(x,y+18,x+11,y,x+8,y+13,c)
  lcd.drawFilledTriangle(x+12,y+2,x+18,y+18,x+13,y+15,c)
  line(x+3,y+17,x+14,y+11,c)
end

-- The two packed strings hold x/y vertex pairs and triangle vertex indices.
-- ASCII 35 represents zero. Only integer coordinates reach the LCD driver.
local function dialFigures(x,y,h,value)
  local scale=h/64
  local advance=floor(49*scale+.5)
  for i=1,#value do
    local digit=tonumber(value:sub(i,i))
    local glyph=digit and figures[digit+1]
    if glyph then
      local points,faces=glyph[1],glyph[2]
      local function point(v)
        local offset=(v-36)*2+1
        local px,py=points:byte(offset,offset+1)
        return x+floor((px-35)*scale+.5),y+floor((py-35)*scale+.5)
      end
      for j=1,#faces,3 do
        local a,b,c=faces:byte(j,j+2)
        local ax,ay=point(a)
        local bx,by=point(b)
        local cx,cy=point(c)
        lcd.drawFilledTriangle(ax,ay,bx,by,cx,cy,noir.ivory)
      end
    else
      rect(x+floor(h*.10),y+floor(h*.52),max(3,floor(h*.42)),max(2,floor(h*.055)),noir.soft)
    end
    x=x+advance
  end
end

local function field(x,y,W,H,label,value,unit,big)
  local labelH=select(2,measure("A",SMLSIZE))
  caption(x,y,W,label,noir.soft)
  local unitW=measure(unit,SMLSIZE)
  local gap=unitW>0 and 4 or 0
  local room=W-unitW-gap
  local top=y+labelH+2
  local f=big and DBLSIZE or MIDSIZE
  local tw,th=measure(value,f)
  if th>H-labelH-2 or tw>room then f=MIDSIZE;tw,th=measure(value,f) end
  if th>H-labelH-2 or tw>room then f=SMLSIZE;tw,th=measure(value,f) end
  if tw>room then value="--";tw=measure(value,f) end
  txt(x,top,value,f,noir.ivory)
  if unitW>0 then txt(x+tw+gap,top+max(0,th-labelH-1),unit,SMLSIZE,noir.gilt) end
end

local function trace(w,x,y,W,H)
  local peak=1
  for _,value in ipairs(w.hist) do if value then peak=max(value,peak) end end
  line(x,y+H,x+W-1,y+H,noir.rule)
  local dx=(W-1)/35
  for i=2,#w.hist do
    local a,b=w.hist[i-1],w.hist[i]
    if a and b then
      line(x+floor((i-2)*dx),y+H-floor(a/peak*H),
           x+floor((i-1)*dx),y+H-floor(b/peak*H),noir.gilt)
    end
  end
end

local function instrumentNote(w,d,rep,page)
  if w.armUnknown then return "CHECK ARM SOURCE",noir.rose end
  if w.gap then return "PARTIAL / SAMPLE GAP",noir.rose end
  if rep and w.speedMissing then return "PARTIAL / GPS SAMPLES",noir.rose end
  if not rep and not d.speed then return "GPS SPEED UNAVAILABLE",noir.rose end
  if w.mahReset then return "mAh COUNTER RESET",noir.rose end
  if w.mahPartial then return "mAh PARTIAL",noir.rose end
  if rep and w.logOn and page~=4 then return w.logStatus,noir.soft end
  return w.aircraft:upper(),noir.soft
end

local function nocturne(w,W,H,d,rep,status,sv,unit,alt,altUnit,duration,page)
  local labelH=select(2,measure("A",SMLSIZE))
  local margin=W>=450 and 12 or 8
  local head=H>=245 and 32 or 27
  local bottom=H-labelH-7
  rect(0,0,W,H,noir.black)
  if W<65 or H<30 then return end
  if W<160 or H<100 then
    caption(3,2,W-6,"SQ DASH",noir.gilt)
    if H>=2*labelH+5 then caption(3,3+labelH,W-6,"Larger zone",noir.soft) end
    return
  end

  local compact=W<345 or H<190 or W/H<1.35
  local narrow=W<300
  if rep then rect(0,0,W,head,noir.wine) end
  if not narrow then hallmark(margin,4,noir.gilt) end
  local brandX=narrow and margin or margin+26
  local stateW=measure(status,SMLSIZE)
  local available=W-margin-stateW-brandX-15
  if available>30 then
    caption(brandX,6,available,available>=110 and "APEX / NOCTURNE" or "APEX",noir.gilt)
  end
  caption(margin,6,W-2*margin,status,(w.armUnknown or not w.seenSafe) and noir.rose or noir.ivory,RIGHT)
  line(margin,head-1,W-margin-1,head-1,noir.rule)

  local note,ink=instrumentNote(w,d,rep,page)
  if compact and (narrow or H<160) then
    local y=head+4
    local val=fmt(sv,"%.0f").." "..unit
    textBox(margin,y,W-2*margin,min(38,bottom-y),val,noir.ivory,0,true)
    if bottom-y>=48 then
      caption(margin,y+37,W-2*margin,"LQ "..fmt(d.lq,"%.0f%%").."   "..fmt(d.volt,"%.1f V"),noir.gilt)
    end
    if bottom-y>=65 then caption(margin,y+54,W-2*margin,duration.."   "..fmt(d.amp,"%.1f A"),noir.soft) end
    caption(margin,bottom+2,W-2*margin,note,ink)
    return
  end

  local pageNames={"PERFORMANCE","ESSENTIALS","BATTERY","LOGBOOK"}
  local foot=pageNames[page].."  "..page.."/4"
  local footW=measure(foot,SMLSIZE)
  line(margin,bottom-2,W-margin-1,bottom-2,noir.rule)
  caption(margin,bottom+1,W-2*margin-footW-10,note,ink)
  caption(W-margin-footW,bottom+1,footW,foot,noir.gilt,RIGHT)
  local top=head+7
  local inner=W-2*margin
  local tall=H>=245
  local au=w.feet and "ft" or "m"
  local used=(rep or w.state=="FLIGHT") and w.stats.mah or nil

  if page==1 then
    local left=floor(inner*.49)
    local sep=margin+left
    local showRail=H>=205
    local railH=showRail and (tall and 44 or 33) or 0
    local rail=bottom-railH-7
    local heroH=rail-top-6
    line(sep,top,sep,rail-6,noir.rule)
    caption(margin,top,left-6,rep and "PEAK GROUND SPEED" or "GPS GROUND SPEED",noir.gilt)
    local value=fmt(sv,"%.0f")
    local ny=top+labelH+4
    local timerY=rail-labelH-7
    local uh=measure(unit,SMLSIZE)
    local digitH=min(tall and 126 or 89, timerY-ny-(tall and 18 or 7),
                     floor((left-uh-15)*64/(49*#value)))
    digitH=max(12,digitH)
    dialFigures(margin,ny,digitH,value)
    local after=margin+floor(49*digitH/64+.5)*#value+2
    txt(after,ny+digitH-labelH,unit,SMLSIZE,noir.gilt)
    if tall and timerY-(ny+digitH)>=16 then trace(w,margin,ny+digitH+4,left-13,timerY-ny-digitH-9) end
    caption(margin,timerY,left-9,"ARM TIME",noir.soft)
    caption(margin,timerY,left-11,duration,noir.ivory,RIGHT)

    local start=sep+9
    local cw=floor((W-margin-start-9)/2)
    local rowH=floor(heroH/3)
    local function metric(col,row,label,v,u)
      local x=start+col*(cw+9)
      field(x,top+row*rowH,cw,rowH-2,label,v,u,tall and H>=340)
    end
    for row=1,2 do line(start,top+row*rowH-3,W-margin-1,top+row*rowH-3,noir.rule) end
    metric(0,0,rep and "MIN PACK" or "PACK",fmt(d.volt,"%.2f"),"V")
    metric(1,0,rep and "MIN LINK" or "LINK",fmt(d.lq,"%.0f"),"%")
    metric(0,1,rep and "PEAK AMPS" or "CURRENT",fmt(d.amp,"%.1f"),"A")
    metric(1,1,rep and "MIN RSSI" or "RSSI",fmt(d.rssi,"%.0f"),"dBm")
    metric(0,2,rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f"),"W")
    metric(1,2,rep and "MAX ALT" or "ALTITUDE",fmt(alt,"%.0f"),au)

    if not showRail then return end
    rect(margin,rail,inner,railH,rep and noir.wine or noir.field)
    local slot=floor(inner/3)
    local function peak(i,label,v,u)
      local x=margin+i*slot+7
      if i>0 then line(x-7,rail+5,x-7,rail+railH-6,noir.rule) end
      field(x,rail+3,slot-12,railH-5,label,v,u,false)
    end
    peak(0,"PEAK SPEED",fmt(w.stats.speed and w.stats.speed*(w.mph and .621371 or 1),"%.0f"),unit)
    peak(1,"PEAK ALT",fmt(w.stats.alt and w.stats.alt*(w.feet and 3.28084 or 1),"%.0f"),au)
    peak(2,"USED",fmt(used,"%.0f"),"mAh")

  elseif page==2 or page==3 then
    local vals
    if page==2 then
      vals={{rep and "PEAK GROUND SPEED" or "GPS GROUND SPEED",fmt(sv,"%.0f"),unit},
            {rep and "MAX ALTITUDE" or "ALTITUDE",fmt(alt,"%.0f"),au},
            {rep and "MIN PACK" or "PACK VOLTAGE",fmt(d.volt,"%.2f"),"V"},
            {rep and "MIN LINK" or "LINK QUALITY",fmt(d.lq,"%.0f"),"%"},
            {"ARM TIME",duration,""},{rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f"),"W"}}
    else
      local drop=w.firstVolt and w.stats.volt and max(0,w.firstVolt-w.stats.volt)
      local second=w.stats.volt
      if rep then second=w.endVolt end
      vals={{rep and "MIN PACK" or "LIVE PACK",fmt(d.volt,"%.2f"),"V"},
            {rep and "LAST ARMED VOLT" or "MIN PACK",fmt(second,"%.2f"),"V"},
            {"DROP FROM FIRST",fmt(drop,"%.2f"),"V"},
            {rep and "PEAK CURRENT" or "CURRENT",fmt(d.amp,"%.1f"),"A"},
            {"OBSERVED CAPACITY",fmt(used,"%.0f"),"mAh"},
            {rep and "PEAK POWER" or "POWER",fmt(d.watts,"%.0f"),"W"}}
    end
    local cw=floor(inner/2)
    local rowH=floor((bottom-top-5)/3)
    rect(margin,top,inner,rowH-2,rep and noir.wine or noir.field)
    for i,v in ipairs(vals) do
      local row=floor((i-1)/2)
      local x=margin+(i-1)%2*cw+7
      local y=top+row*rowH+3
      if i%2==1 and row>0 then line(margin,y-4,W-margin-1,y-4,noir.rule) end
      field(x,y,cw-13,rowH-6,v[1],v[2],v[3],true)
    end
  else
    caption(margin,top,inner,"AIRCRAFT LOGBOOK",noir.gilt)
    local y=top+labelH+5
    local half=floor(inner/2)
    local metricH=tall and 55 or 40
    rect(margin,y,inner,metricH,noir.field)
    field(margin+7,y+3,half-12,metricH-5,"SAVED FLIGHTS",tostring(w.total),"",true)
    field(margin+half+7,y+3,half-12,metricH-5,"BEST GROUND SPEED",fmt(w.allSpeed and w.allSpeed*(w.mph and .621371 or 1),"%.0f"),unit,true)
    y=y+metricH+5
    caption(margin,y,inner,"TOTAL "..time(w.totalTime).."   /   PEAK "..fmt(w.allPower,"%.0f W"),noir.soft)
    y=y+labelH+6
    local statusY=bottom-labelH-5
    if #w.recent==0 and y+labelH<=statusY then
      caption(margin,y,inner,w.logOn and "NO SAVED FLIGHTS" or "ENABLE LogSD TO SAVE FLIGHTS",noir.ivory)
    else
      local step=labelH+7
      local rows=min(#w.recent,max(0,floor((statusY-y)/step)))
      for i=1,rows do
        local r=w.recent[i]
        line(margin,y-2,W-margin-1,y-2,noir.rule)
        caption(margin,y,half,r.date:sub(1,16)..(r.partial and "*" or ""),noir.ivory)
        caption(margin+half,y,inner-half,time(r.duration).."   /   "..fmt(r.speed and r.speed*(w.mph and .621371 or 1),"%.0f").." "..unit,noir.gilt,RIGHT)
        y=y+step
      end
    end
    caption(margin,statusY,inner,w.logStatus,noir.soft)
  end
end

local function refresh(w,event,touch)
 local W,H=w.zone.w,w.zone.h;if event~=nil then W,H=LCD_W,LCD_H end
 if W<1 or H<1 then return end
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
 local page=w.page
 if page==4 and not w.safeInput then page=1 end
 if w.theme==7 then
  nocturne(w,W,H,d,rep,status,sv,unit,alt,altUnit,duration,page)
  return
 end
 if w.theme==6 and apex(w,W,H,d,rep,status,sv,unit,alt,altUnit,duration,page) then return end
 rect(0,0,W,H,bg)
 if W<160 or H<100 then if W>=65 and H>=30 then txt(3,3,"SQ DASH",SMLSIZE,w.accent);txt(3,16,"Larger zone",SMLSIZE,muted) end;return end
 txt(6,3,"SQ / PILOT DASH  1.8.1",SMLSIZE,accent)
 if W>=300 then txt(W-6,3,status,RIGHT+SMLSIZE,w.armUnknown and red or accent) end
 line(6,17,W-7,17,border)
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
 local foot=w.armUnknown and "CHECK ARM SOURCE" or (w.gap and "PARTIAL / ARM OR SAMPLE GAP" or (w.mahReset and "mAh COUNTER RESET" or (w.mahPartial and "mAh PARTIAL" or "APEX / V1.8")))
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
