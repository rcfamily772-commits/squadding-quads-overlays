-- SQ Wallpaper Shuffle | colour EdgeTX
local folder = "/IMAGES/SQWALL/"
local statePath = "/WIDGETS/SQWall/last.txt"
local floor, ceil = math.floor, math.ceil
local current, boot
local function startup()
  return getRtcTime() - floor(getTime()/100)
end
local function readLast()
  local f = io.open(statePath,"r")
  if not f then return end
  local s = io.read(f,300) or ""
  io.close(f)
  local stamp,name = s:match("^(%d+)\n([^\r\n]+)\n$")
  return tonumber(stamp),name
end
local function remember(name)
  local f = io.open(statePath,"w")
  if not f then return false end
  io.write(f,string.format("%d\n%s\n",boot,name))
  io.close(f)
  return true
end
local function catalogue()
  local names = {}
  for name in dir(folder:sub(1,-2)) do
    if type(name)=="string" and name:lower():match("%.png$") and not name:match("[/\r\n]") then
      names[#names+1]=name
    end
  end
  table.sort(names)
  return names
end
local function plan(w, preferred, avoid)
  local choices={}
  for _,name in ipairs(w.names) do
    if name~=preferred and name~=avoid then choices[#choices+1]=name end
  end
  w.seed=(w.seed*25173+13849)%65536
  local start=1+floor(w.seed*#choices/65536)
  w.queue={}
  if preferred then w.queue[1]=preferred end
  for n=1,#choices do w.queue[#w.queue+1]=choices[1+(start+n-2)%#choices] end
  if avoid and avoid~=preferred then w.queue[#w.queue+1]=avoid end
  w.next=1
end
local function create(zone)
  local ok,names=pcall(catalogue)
  local w={zone=zone,names=ok and names or {},seed=(getRtcTime()+getTime())%65536}
  local stamp,last=readLast()
  local epoch=startup()
  if not boot or math.abs(boot-epoch)>1 then
    boot=epoch
    current=nil
  end
  local same=current or (stamp and math.abs(stamp-boot)<=1 and last)
  local known={}
  for _,name in ipairs(w.names) do known[name]=true end
  plan(w,known[same] and same or nil,known[last] and last or nil)
  if #w.names==0 then w.error="Add PNGs to /IMAGES/SQWALL" end
  return w
end
local function advance(w)
  local name=w.queue[w.next]
  if not name then
    w.queue=nil
    if not w.bitmap then w.error="No readable PNGs in SQWALL" end
    return
  end
  w.next=w.next+1
  if name==w.name and w.bitmap then w.queue=nil return end
  local ok,bmp=pcall(Bitmap.open,folder..name)
  if not ok or not bmp then return end
  local width,height=Bitmap.getSize(bmp)
  if not width or not height or width<1 or height<1 then return end
  w.bitmap,w.bw,w.bh,w.name,w.queue=bmp,width,height,name,nil
  local stamp,last=readLast()
  if not stamp or math.abs(stamp-boot)>1 or last~=name then
    w.unsaved=not remember(name)
  end
  current=name
end
local function refresh(w,event,touch)
  local full=event~=nil
  local width=full and LCD_W or w.zone.w
  local height=full and LCD_H or w.zone.h
  local buttonW=math.min(180,width-8)
  local x=floor((width-buttonW)/2)
  local y=height-42
  if full and not w.queue and (event==EVT_VIRTUAL_ENTER or
      (event==EVT_TOUCH_TAP and touch and touch.x>=x and touch.x<x+buttonW and touch.y>=y and touch.y<height-4)) then
    plan(w,nil,w.name)
  elseif not w.queue and current and current~=w.name then
    plan(w,current,w.name)
  end
  if w.queue then advance(w) end
  lcd.drawFilledRectangle(0,0,width,height,BLACK)
  if w.bitmap then
    local scale=ceil(math.max(width/w.bw,height/w.bh)*100)
    lcd.drawBitmap(w.bitmap,floor((width-w.bw*scale/100)/2),floor((height-w.bh*scale/100)/2),scale)
  else
    lcd.drawText(3,2,w.error or "Loading wallpaper...",WHITE+SMLSIZE)
  end
  if full and w.bitmap then
    lcd.drawFilledRectangle(x,y,buttonW,38,BLACK)
    lcd.drawText(floor(width/2),y+8,"I'm Feeling Lucky",CENTER+WHITE)
    if w.unsaved then lcd.drawText(3,2,"SD state could not be saved",WHITE+SMLSIZE) end
  end
end
return {name="SQWall",create=create,refresh=refresh}
