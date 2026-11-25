-- SQ Wallpaper Shuffle v1.3 | FPV Dads & Sons | upgrade for v1.1 assets
local folder,art,statePath="/IMAGES/SQWALL/","/WIDGETS/SQWall/art/","/WIDGETS/SQWall/last.txt"
local floor,ceil,min,max=math.floor,math.ceil,math.min,math.max
local current,boot,introShown
local gold,ink,white=lcd.RGB(225,190,123),lcd.RGB(15,16,17),lcd.RGB(246,242,228)
local starters={"karen","dealer","manc","workshop","sq004","sq005","sq006","sq007","sq008","sq009","sq010","sq011","sq012","sq013","sq014","sq015","sq016","sq017","sq018","sq019","sq020","sq021","sq022","sq023","sq024","sq025","sq026","sq027","sq028","sq029","sq030","intro"}
local options={{"Intro",BOOL,1},{"Motion",BOOL,1},{"SFX",BOOL,0}}
local function on(o,k,d) if not o or o[k]==nil then return d end return o[k]==1 or o[k]==true end
local function update(w,o) w.showIntro=on(o,"Intro",true);w.motion=on(o,"Motion",true);w.sound=on(o,"SFX",false) end
local function startup() return getRtcTime()-floor(getTime()/100) end
local function readLast()
 local f=io.open(statePath,"r");if not f then return end
 local s=io.read(f,300) or "";io.close(f)
 local stamp,name=s:match("^(%d+)\n([^\r\n]+)\n$");return tonumber(stamp),name
end
local function remember(name)
 local ok,done=pcall(function() local f=io.open(statePath,"w");if not f then return false end;io.write(f,string.format("%d\n%s\n",boot,name));io.close(f);return true end)
 return ok and done
end
local function catalogue()
 local names,seen={},{}
 local function add(name)
  if type(name)=="string" and #name<=100 and name:lower():match("%.png$") and not name:match("[/\r\n]") and not seen[name:lower()] then names[#names+1]=name;seen[name:lower()]=true end
 end
 pcall(function() for name in dir("/IMAGES/SQWALL") do add(name) end end)
 for _,base in ipairs(starters) do add(base..".png") end
 -- Explicit fallback for the v1.3 art if directory enumeration is unavailable.
 for _,name in ipairs({"dads_sons.png","dads_sons_bw.png"}) do
  pcall(function() local f=io.open(folder..name,"r");if f then io.close(f);add(name) end end)
 end
 table.sort(names);return names
end
local function openImage(path)
 local bmp=Bitmap.open(path);if not bmp then return end
 local bw,bh=Bitmap.getSize(bmp);if bw and bh and bw>0 and bh>0 then return bmp,bw,bh end
end
local function plan(w,preferred,avoid)
 local choices={}
 for _,name in ipairs(w.names) do if name~=preferred and name~=avoid then choices[#choices+1]=name end end
 w.seed=(w.seed*25173+13849)%65536
 local start=1+floor(w.seed*#choices/65536)
 w.queue={};if preferred then w.queue[1]=preferred end
 for n=1,#choices do w.queue[#w.queue+1]=choices[1+(start+n-2)%#choices] end
 if avoid and avoid~=preferred then w.queue[#w.queue+1]=avoid end
 w.next=1
end
local function create(zone,o)
 local w={zone=zone,names=catalogue(),seed=(getRtcTime()+getTime())%65536,focus=1,clean=false}
 update(w,o)
 local stamp,last=readLast();local epoch=startup()
 if not boot or math.abs(boot-epoch)>1 then boot=epoch;current=nil end
 local same=current or (stamp and math.abs(stamp-boot)<=1 and last)
 local known={};for _,name in ipairs(w.names) do known[name]=true end
 plan(w,known[same] and same or nil,known[last] and last or nil)
 return w
end
local function advance(w)
 local name=w.queue[w.next]
 if not name then w.queue=nil;if not w.bitmap then w.error="Check /IMAGES/SQWALL" end;return end
 w.next=w.next+1
 if name==w.name and w.bitmap then w.queue=nil;return end
 -- Free the former bitmap before opening another to minimise peak RAM.
 w.bitmap=nil
 local ok,bmp,bw,bh=pcall(openImage,folder..name)
 if not ok or not bmp then
  for _,base in ipairs(starters) do if name:lower()==base..".png" then
   local legacy=base=="karen" or base=="workshop" or base=="dealer" or base=="manc"
   ok,bmp,bw,bh=pcall(openImage,art..base..(legacy and ".bmp" or ".png"));break
  end end
 end
 if not ok or not bmp then return end
 local old=w.name
 w.bitmap,w.bw,w.bh,w.name,w.queue=bmp,bw,bh,name,nil
 local stamp,last=readLast()
 if not stamp or math.abs(stamp-boot)>1 or last~=name then w.unsaved=not remember(name) end
 current=name;w.error=nil
 if old and old~=name and w.motion then w.reveal=getTime() end
 if old and old~=name and w.sound and type(playTone)=="function" then pcall(playTone,840,60,0,0) end
end
local function drawImage(bmp,bw,bh,W,H,cover)
 local scale=max(1,(cover and ceil or floor)((cover and max or min)(W/bw,H/bh)*100))
 lcd.drawBitmap(bmp,floor((W-bw*scale/100)/2),floor((H-bh*scale/100)/2),scale)
end
local function navigate(w,direction)
 if #w.names==0 then return end
 local i=1;for j,name in ipairs(w.names) do if name==w.name then i=j;break end end
 local q={}
 for j=1,#w.names do q[j]=w.names[1+(i-1+j*direction)%#w.names] end
 w.queue=q;w.next=1
end
local function refresh(w,event,touch)
 local full=event~=nil
 local W,H=full and LCD_W or w.zone.w,full and LCD_H or w.zone.h
 if not full then w.clean=false end
 if w.showIntro and not introShown then
  introShown=true;local ok,b,bw,bh=pcall(openImage,art.."intro.png")
  if ok and b then w.intro,w.iw,w.ih,w.introEnd=b,bw,bh,getTime()+90 end
 end
 if w.intro then
  if getTime()<w.introEnd then lcd.drawFilledRectangle(0,0,W,H,ink);drawImage(w.intro,w.iw,w.ih,W,H,false);return end
  w.intro=nil
 end
 local labels={"Prev","Lucky","Next","Clean"}
 local bar=H-min(42,floor(H/5));local slot=floor((W-12)/4)
 if full and w.clean then
  if event==EVT_VIRTUAL_ENTER or event==EVT_TOUCH_TAP then w.clean=false end
 elseif full and not w.queue then
  local action
  if event==EVT_VIRTUAL_NEXT then w.focus=w.focus%4+1
  elseif event==EVT_VIRTUAL_PREV then w.focus=(w.focus-2)%4+1
  elseif event==EVT_VIRTUAL_ENTER then action=w.focus
  elseif event==EVT_TOUCH_TAP and touch and touch.y>=bar and touch.x>=6 and touch.x<6+slot*4 then action=1+floor((touch.x-6)/slot);w.focus=action end
  if action==1 then navigate(w,-1) elseif action==2 then plan(w,nil,w.name) elseif action==3 then navigate(w,1) elseif action==4 then w.clean=true end
 end
 if not w.queue and current and current~=w.name then plan(w,current,w.name) end
 if w.queue then advance(w) end
 lcd.drawFilledRectangle(0,0,W,H,ink)
 if w.bitmap then drawImage(w.bitmap,w.bw,w.bh,W,H,true)
 else lcd.drawText(4,4,w.error or "Loading gallery...",SMLSIZE+white) end
 if full and not w.clean and W>=300 and H>=230 then
  lcd.drawFilledRectangle(0,0,W,26,ink)
  lcd.drawText(7,4,"SQ / BLACK LABEL",SMLSIZE+gold)
  local index=0;for i,name in ipairs(w.names) do if name==w.name then index=i;break end end
  lcd.drawText(W-7,4,index.."/"..#w.names,RIGHT+SMLSIZE+white)
  lcd.drawFilledRectangle(0,bar-22,W,H-bar+22,ink)
  local name=(w.name or "Loading"):gsub("%.png$",""):gsub("_"," ")
  if name=="dads sons" then name="FPV Dads & Sons" elseif name=="dads sons bw" then name="FPV Dads & Sons B&W" end
  if #name>24 then name=name:sub(1,21).."..." end
  lcd.drawText(7,bar-20,name,SMLSIZE+white)
  if w.unsaved then lcd.drawText(W-7,bar-20,"NOT SAVED",RIGHT+SMLSIZE+gold) end
  lcd.drawFilledRectangle(0,bar-3,W,1,gold)
  for i,label in ipairs(labels) do local x=6+(i-1)*slot;local sel=w.focus==i
   lcd.drawFilledRectangle(x,bar+2,slot-3,H-bar-6,sel and gold or ink)
   lcd.drawRectangle(x,bar+2,slot-3,H-bar-6,gold)
   lcd.drawText(x+floor((slot-3)/2),bar+floor((H-bar-14)/2),label,CENTER+SMLSIZE+(sel and ink or white))
  end
 end
 if full and not w.clean and w.reveal then
  local dt=getTime()-w.reveal
  if dt>=0 and dt<18 then local inset=floor(dt*min(W,H)/36);lcd.drawRectangle(inset,inset,W-2*inset,H-2*inset,gold)
  else w.reveal=nil end
 end
end
return {name="SQWall",options=options,update=update,create=create,refresh=refresh}
