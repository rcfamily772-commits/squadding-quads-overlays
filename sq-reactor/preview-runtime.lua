-- Browser drawing adapter. Real SQDash renderer; synthetic state, fonts and LCD.
-- No radio connection, filesystem or model writes are provided.
return function(_,source,emit,get,measure)
 local env={assert=assert,error=error,ipairs=ipairs,pairs=pairs,next=next,pcall=pcall,
  select=select,type=type,tonumber=tonumber,tostring=tostring,math=math,string=string,table=table,
  LCD_W=480,LCD_H=272,SMLSIZE=0x02000000,MIDSIZE=0x04000000,DBLSIZE=0x08000000,
  XXLSIZE=0x10000000,CENTER=0x40000000,RIGHT=0x20000000,SOLID=0,SOURCE=1,BOOL=2,VALUE=3,
  getTime=function() return math.floor(get(nil,"clock") or 0) end,model={getInfo=function() return {name="Demo aircraft",filename="demo.yml"} end}}
 local lcd={};env.lcd=lcd
 lcd.RGB=function(r,g,b) return 0x01000000+r*65536+g*256+b end
 lcd.sizeText=function(s,f) return measure(nil,s,f),f==env.XXLSIZE and 64 or f==env.DBLSIZE and 32 or f==env.MIDSIZE and 22 or 12 end
 for _,op in ipairs({"drawFilledRectangle","drawRectangle","drawText","drawLine","drawCircle","drawFilledCircle","drawFilledTriangle","drawBitmap"}) do lcd[op]=function(...) emit(nil,op,...) end end
 local api=assert(load(source,"@SQDash/main.lua","t",env))()
 local w=api.create({w=480,h=272},{ArmSrc=1,ArmHigh=1,Theme=6})
 return function()
  local function value(k) return get(nil,k) end
  env.LCD_W,env.LCD_H=value("width"),value("height")
  w.zone={w=env.LCD_W,h=env.LCD_H};w.last=env.getTime()
  for _,k in ipairs({"theme","mph","feet","page","aircraft","state","elapsed","flights","newBest","bestSpeed","bestTime","bestAmp","firstVolt","endVolt","total","totalTime","allSpeed","allPower","allTime","logStatus","gap","speedMissing","armUnknown","seenSafe","safeInput"}) do w[k]=value(k) end
  for _,k in ipairs({"theme","page","flights","total"}) do w[k]=math.floor(w[k]) end
  w.accent=lcd.RGB(value("r"),value("g"),value("b"));w.dim=lcd.RGB(29,57,64)
  w.cells=6;w.armSrc=1;w.logOn=true;w.loaded=true;w.pending={}
  w.data={};w.stats={}
  for _,k in ipairs({"speed","volt","amp","mah","lq","rssi","alt","watts","avg"}) do w.data[k]=value("live."..k);w.stats[k]=value("stats."..k) end
  w.hist={};for i=1,value("history.length") do w.hist[i]=value("history."..(i-1)) or false end
  w.recent={};for i=1,value("recent.length") do
   local r={};for _,k in ipairs({"date","duration","speed","alt","lq","rssi","partial"}) do r[k]=value("recent."..(i-1).."."..k) end
   w.recent[i]=r
  end
  w.comicPilot="pilot";w.landedAt=value("landedAt");w.previewStill=value("still")
  w.showSummary=value("showSummary");w.report=w.showSummary and w.recent[1] or nil
  local entry=value("entry");w.entry=entry and entry>0 and math.floor(entry) or nil
  return api.refresh(w,0)
 end
end
