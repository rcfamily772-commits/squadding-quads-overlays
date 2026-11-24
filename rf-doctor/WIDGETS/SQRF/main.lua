-- SQ Lab | RF Doctor v1.0 | Read-only colour EdgeTX widget
local floor,min,max=math.floor,math.min,math.max
local rgb=lcd.RGB
local bg,panel,gold,white,muted,green,red=rgb(13,16,18),rgb(29,35,38),rgb(224,191,124),rgb(245,242,232),rgb(154,166,169),rgb(117,220,158),rgb(245,119,109)
local sensors={
 {"LQ","%","RQly","Rqly"},{"RSSI 1","dBm","1RSS"},{"RSSI 2","dBm","2RSS"},{"SNR","dB","RSNR"},{"TX power","mW","TPWR"},{"RF mode","raw","RFMD"},{"Downlink LQ","%","TQly"}
}
local scales={{0,100},{-130,-30},{-130,-30},{-25,25},{0,2000},{0,20},{0,100}}
local header="elapsed_s,lq_pct,rssi1_dbm,rssi2_dbm,snr_db,tx_mw,rf_mode,downlink_lq_pct,rx_sample_current\n"
local options={{"Low LQ",VALUE,80,0,100}}
local function newStats() local a={};for i=1,#sensors do a[i]={n=0,sum=0} end;return a end
local function update(w,o) w.threshold=o and o["Low LQ"] or 80 end
local function create(zone,o)
 local w={zone=zone,ids={},values={},history={},head=0,count=0,metric=1,page=1,focus=1,stats=newStats(),samples=0,gaps=0,low=0,buffer={},record=false,status="Ready",last=nil}
 update(w,o);return w
end
local function discover(w)
 for i,s in ipairs(sensors) do
  if not w.ids[i] then
   for j=3,#s do local f=getFieldInfo(s[j]);if f and f.id then w.ids[i]=f.id;break end end
  end
 end
end
local function value(w,i)
 if not w.ids[i] or type(getSourceValue)~="function" then return nil end
 local v,current,fresh=getSourceValue(w.ids[i])
 if type(v)~="number" or v~=v or not current or not fresh then return nil end
 if (i==1 or i==7) and (v<0 or v>100) then return nil end
 if (i==2 or i==3) and (v>=0 or v< -160) then return nil end
 if i==5 and v<0 then return nil end
 return v
end
local function writeFile(path,mode,data)
 local ok,good=pcall(function()
  local f=io.open(path,mode);if not f then return false end
  local result=io.write(f,data);io.close(f);return result~=nil and result~=false
 end)
 return ok and good
end
local function flush(w)
 if #w.buffer==0 then return true end
 if not writeFile(w.path,"a",table.concat(w.buffer)) then w.status="SD WRITE FAILED";w.record=false;w.buffer={};return false end
 w.buffer={};return true
end
local function stop(w)
 if not w.record then return end
 w.record=false;if flush(w) then w.status="Saved: "..w.filename end
end
local function start(w)
 if type(getSourceValue)~="function" then w.status="Requires EdgeTX 2.8+";return end
 if not io or not io.open then w.status="SD unavailable";return end
 local epoch=type(getRtcTime)=="function" and getRtcTime() or 0
 local base="RF-"..tostring(epoch).."-"..tostring(getTime())
 local file,path
 for k=0,9 do
  file=base.."-"..k..".csv";path="/WIDGETS/SQRF/"..file
  local ok,exists=pcall(function() local f=io.open(path,"r");if f then io.close(f);return true end return false end)
  if not ok then w.status="SD unavailable";return end
  if not exists then break end
  path=nil
 end
 if not path or not writeFile(path,"w",header) then w.status="SD CREATE FAILED";return end
 w.path,w.filename=path,file;w.record=true;w.start=getTime();w.stats=newStats();w.samples=0;w.gaps=0;w.low=0;w.buffer={};w.last=nil;w.head=0;w.count=0;w.history={};w.status="Recording"
end
local function csv(v) if v==nil then return "" end return string.format("%.2f",v) end
local function sample(w)
 local now=getTime()
 if w.last and now>=w.last and now-w.last<100 then return end
 if not w.discovered or now-w.discovered>=500 then discover(w);w.discovered=now end
 w.last=now
 local row={}
 for i=1,#sensors do row[i]=value(w,i) end
 w.values=row
 -- Receiver freshness is inferred only from receiver-side fields, never TX power.
 local rx=row[1]~=nil or row[2]~=nil or row[3]~=nil or row[4]~=nil
 w.rx=rx
 w.head=w.head%60+1;w.history[w.head]={v=row,t=now};w.count=min(60,w.count+1)
 if not w.record then return end
 if now<w.start then stop(w);return end
 local elapsed=(now-w.start)/100
 if elapsed>=3600 or w.samples>=3600 then stop(w);return end
 w.samples=w.samples+1;if not rx then w.gaps=w.gaps+1 end
 if row[1] and row[1]<w.threshold then w.low=w.low+1 end
 for i=1,#sensors do local v=row[i];if v~=nil then local s=w.stats[i];s.n=s.n+1;s.sum=s.sum+v;s.lo=s.lo and min(s.lo,v) or v;s.hi=s.hi and max(s.hi,v) or v end end
 local parts={string.format("%.2f",elapsed)}
 for i=1,#sensors do parts[i+1]=csv(row[i]) end
 parts[9]=rx and "1" or "0"
 w.buffer[#w.buffer+1]=table.concat(parts,",").."\n"
 if #w.buffer>=5 then flush(w) end
end
local function background(w) sample(w) end
local function fmt(v) return v==nil and "--" or string.format("%.0f",v) end
local function fit(x,y,s,f,col,width)
 if lcd.sizeText(s,f)>width then f=SMLSIZE end
 lcd.drawText(x,y,s,f+col)
end
local function tile(w)
 local W,H=w.zone.w,w.zone.h
 lcd.drawFilledRectangle(0,0,W,H,bg)
 if W<40 or H<18 then return end
 lcd.drawFilledRectangle(0,0,3,H,gold);lcd.drawText(7,3,"SQ RF",SMLSIZE+gold)
 if H>=40 then fit(7,20,"LQ "..fmt(w.values[1]).."%",MIDSIZE,w.values[1] and (w.values[1]<w.threshold and red or green) or muted,W-12) end
 if H>=65 then fit(7,46,"RSSI "..fmt(w.values[2]).." dBm",SMLSIZE,white,W-12) end
 if H>=85 then lcd.drawText(7,65,w.record and "REC" or (w.rx and "RX DATA" or "NO RX DATA"),SMLSIZE+(w.record and red or muted)) end
end
local function graph(w,x,y,W,H)
 local i=w.metric;local lo,hi=scales[i][1],scales[i][2]
 if i==5 then for k=1,w.count do local p=w.history[(w.head-w.count+k-1)%60+1];if p.v[i] and p.v[i]>hi then hi=p.v[i] end end end
 if i==6 then for k=1,w.count do local p=w.history[(w.head-w.count+k-1)%60+1];if p.v[i] and p.v[i]>hi then hi=p.v[i] end end end
 lcd.drawFilledRectangle(x,y,W,H,panel)
 for j=0,2 do local yy=y+floor((H-1)*j/2);lcd.drawLine(x,yy,x+W-1,yy,SOLID,muted) end
 local lastX,lastY,lastT
 for k=1,w.count do
  local p=w.history[(w.head-w.count+k-1)%60+1];local v=p.v[i]
  local age=w.last-p.t;local xx=x+W-1-floor(age*(W-1)/5900)
  if xx>=x and v~=nil then
   local yy=y+H-1-floor((H-1)*max(0,min(1,(v-lo)/(hi-lo))))
   if lastX and p.t-lastT<=150 then lcd.drawLine(lastX,lastY,xx,yy,SOLID,green) else lcd.drawFilledRectangle(xx,yy,2,2,green) end
   lastX,lastY,lastT=xx,yy,p.t
  else lastX=nil end
 end
end
local function choose(w,a)
 if a==1 then if w.record then stop(w) else start(w) end
 elseif a==2 then w.metric=w.metric%#sensors+1;w.page=1
 elseif a==3 then w.page=w.page%3+1 end
end
local function refresh(w,event,touch)
 sample(w)
 if event==nil then tile(w);return end
 local W,H=LCD_W,LCD_H
 if W<300 or H<230 then lcd.drawFilledRectangle(0,0,W,H,bg);lcd.drawText(5,5,"Colour screen 320x240+",SMLSIZE+white);return end
 local by=H-42;local slot=floor((W-16)/3)
 if event==EVT_VIRTUAL_NEXT then w.focus=w.focus%3+1
 elseif event==EVT_VIRTUAL_PREV then w.focus=(w.focus-2)%3+1
 elseif event==EVT_VIRTUAL_ENTER then choose(w,w.focus)
 elseif event==EVT_TOUCH_TAP and touch and touch.y>=by and touch.y<H and touch.x>=8 and touch.x<8+slot*3 then w.focus=1+floor((touch.x-8)/slot);choose(w,w.focus) end
 lcd.drawFilledRectangle(0,0,W,H,bg)
 lcd.drawText(8,3,"SQ LAB / RF DOCTOR",SMLSIZE+gold)
 lcd.drawText(W-8,3,w.record and "REC" or (w.rx and "RX DATA" or "NO RX DATA"),RIGHT+SMLSIZE+(w.record and red or muted))
 local content=by-48
 if w.page==1 then
  local cw=floor((W-24)/3)
  local metrics={1,2,5}
  for j,i in ipairs(metrics) do local x=8+(j-1)*(cw+4);lcd.drawFilledRectangle(x,25,cw,44,panel);lcd.drawText(x+5,27,sensors[i][1],SMLSIZE+muted);fit(x+5,43,fmt(w.values[i]).." "..sensors[i][2],0,i==1 and w.values[i] and w.values[i]<w.threshold and red or white,cw-10) end
  lcd.drawText(8,76,sensors[w.metric][1].." / "..sensors[w.metric][2].."   LAST 60s",SMLSIZE+gold)
  graph(w,8,96,W-16,max(16,by-125))
  lcd.drawText(8,by-23,"Now "..fmt(w.values[w.metric]).."   |   Missing = gap",SMLSIZE+muted)
 elseif w.page==2 then
  lcd.drawText(8,25,"SESSION REPORT",0+gold)
  local dx=floor((W-16)/4)
  for j,s in ipairs({"Sensor","Min","Mean","Max"}) do lcd.drawText(8+(j-1)*dx,48,s,SMLSIZE+muted) end
  local dy=min(20,floor((by-91)/7))
  for i=1,#sensors do local s=w.stats[i];local y=65+(i-1)*dy
   lcd.drawText(8,y,i==7 and "DL LQ" or sensors[i][1],SMLSIZE+white)
   lcd.drawText(8+dx,y,fmt(s.lo),SMLSIZE+white)
   lcd.drawText(8+dx*2,y,fmt(s.n>0 and s.sum/s.n or nil),SMLSIZE+white)
   lcd.drawText(8+dx*3,y,fmt(s.hi),SMLSIZE+white)
  end
  lcd.drawText(8,by-19,"Samples "..w.samples.." / RX gaps "..w.gaps,SMLSIZE+gold)
 else
  lcd.drawText(8,25,"SENSOR STATUS",0+gold)
  local dy=min(20,floor((by-89)/7))
  for i,s in ipairs(sensors) do local y=49+(i-1)*dy; lcd.drawText(8,y,s[3],SMLSIZE+white);lcd.drawText(W-8,y,w.values[i]~=nil and "FRESH" or (w.ids[i] and "NOT FRESH" or "NOT FOUND"),RIGHT+SMLSIZE+(w.values[i]~=nil and green or muted)) end
  local status=w.status
  if w.record then status="REC "..w.samples.." / Low LQ "..w.low end
  lcd.drawText(8,by-19,status:sub(1,43),SMLSIZE+gold)
 end
 if w.record and w.samples>=3595 then lcd.drawText(W-8,by-19,"LIMIT",RIGHT+SMLSIZE+red) end
 for i,s in ipairs({w.record and "Stop / save" or "Record","Graph","View"}) do local x=8+(i-1)*slot;local selected=w.focus==i
  lcd.drawFilledRectangle(x,by,slot-3,36,selected and gold or panel);lcd.drawRectangle(x,by,slot-3,36,gold);lcd.drawText(x+floor((slot-3)/2),by+10,s,CENTER+SMLSIZE+(selected and bg or white))
 end
end
return {name="SQRF",options=options,create=create,update=update,background=background,refresh=refresh}
