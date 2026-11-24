-- Adapter for single-file colour widgets. Each start gets a new worker and Lua VM.
return function(_, source, width, height, tile, emit, ticks, assets)
  local env = {assert=assert,error=error,ipairs=ipairs,pairs=pairs,next=next,
    pcall=pcall,select=select,type=type,tonumber=tonumber,tostring=tostring,
    math=math,string=string,table=table,utf8=utf8,unpack=table.unpack,
    LCD_W=width,LCD_H=height, SMLSIZE=0x02000000,MIDSIZE=0x04000000,
    DBLSIZE=0x08000000, XXLsize=0x10000000,LEFT=0,RIGHT=0x20000000,
    CENTER=0x40000000,SOLID=0,PREC1=1,PREC2=2,
    EVT_VIRTUAL_NEXT=1,EVT_VIRTUAL_PREV=2,EVT_VIRTUAL_ENTER=3,EVT_TOUCH_TAP=4,
    VALUE=1,BOOL=2,COLOR=3,SOURCE=4,STRING=5, getTime=function() return ticks(nil) end}
  env.XXLSIZE=env.XXLsize
  env.STDSIZE=0
  local lcd={}
  env.lcd=lcd
  function lcd.RGB(r,g,b) return 0x01000000 + r*65536 + g*256 + b end
  env.WHITE=lcd.RGB(255,255,255)
  env.BLACK=lcd.RGB(0,0,0)
  env.RED=lcd.RGB(255,0,0)
  env.GREEN=lcd.RGB(0,255,0)
  env.BLUE=lcd.RGB(0,0,255)
  env.YELLOW=lcd.RGB(255,255,0)
  env.ORANGE=lcd.RGB(255,165,0)
  local function send(kind,...)
    for i=1,select('#',...) do
      local v=select(i,...)
      assert(v==nil or type(v)=='string' or type(v)=='number','Expected a drawing value')
    end
    emit(nil,kind,...)
  end
  for _,name in ipairs({'drawFilledRectangle','drawRectangle','drawText','drawLine','drawTextLines','drawCircle','drawFilledCircle','clear'}) do
    lcd[name]=function(...) send(name,...) end
  end
  function lcd.drawNumber(x,y,n,flags) lcd.drawText(x,y,tostring(n),flags) end
  function lcd.sizeText(s,f)
    local size=16
    if f and f & env.SMLSIZE ~= 0 then size=13
    elseif f and f & env.MIDSIZE ~= 0 then size=22
    elseif f and f & env.DBLSIZE ~= 0 then size=32
    elseif f and f & env.XXLSIZE ~= 0 then size=44 end
    return math.ceil(#s*size*.55),size
  end
  local albumFiles={}
  if assets then
    env.getRtcTime=function() return assets(nil,'clock') end
    env.dir=function(path)
      local i=0
      return function() i=i+1; return assets(nil,'name',path,i) end
    end
    env.Bitmap={}
    function env.Bitmap.open(path)
      if assets(nil,'width',path) then return path end
    end
    function env.Bitmap.getSize(path)
      return assets(nil,'width',path),assets(nil,'height',path)
    end
    function lcd.drawBitmap(path,x,y,scale)
      send('drawBitmap',x,y,path,scale or 100)
    end
    env.io={}
    function env.io.open(path,mode)
      local album=path=='/WIDGETS/SQLotto/album-a.txt' or path=='/WIDGETS/SQLotto/album-b.txt'
      if not album and path~='/WIDGETS/SQWall/last.txt' then return end
      local body=album and albumFiles[path] or (not album and assets(nil,'state'))
      if mode=='w' or (mode=='r' and body) then return {mode=mode,body=mode=='w' and '' or body,path=path,album=album} end
    end
    function env.io.read(f,n) return string.sub(f.body,1,n) end
    function env.io.write(f,s) f.body=string.sub(f.body..s,1,300) end
    function env.io.close(f) if f.mode=='w' then if f.album then albumFiles[f.path]=f.body else assets(nil,'save',f.body) end end end
  end
  local chunk=assert(load(source,'@main.lua','t',env))
  local api=chunk()
  assert(type(api)=='table' and type(api.create)=='function' and type(api.refresh)=='function','Expected a widget returning create and refresh functions')
  local zone={x=0,y=0,w=width,h=height}
  if tile then zone.w=math.floor(width/2) zone.h=math.floor(height/2) end
  local options={}
  for _,o in ipairs(api.options or {}) do options[o[1]]=o[3] end
  local widget=api.create(zone,options)
  return function(_,event,x,y)
    if tile then api.refresh(widget,nil,nil)
    elseif event==4 then api.refresh(widget,event,{x=x,y=y,startX=x,startY=y,tapCount=1})
    else api.refresh(widget,event or 0,nil) end
  end
end
