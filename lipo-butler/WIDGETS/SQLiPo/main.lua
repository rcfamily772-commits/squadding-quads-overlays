-- SQ LiPo Butler v1.1 | read-only telemetry, manual battery inventory
local floor,min,max=math.floor,math.min,math.max
local rgb=lcd.RGB
local bg,panel,gold,white,muted=rgb(14,17,18),rgb(30,36,37),rgb(223,191,126),rgb(247,243,231),rgb(158,174,170)
local names={"Unassigned","Charged","Flown","Storage","Inspect"}
local colors={muted,rgb(107,211,149),rgb(241,174,85),rgb(126,178,237),rgb(245,117,107)}
local options={{"Packs",VALUE,12,1,24},{"Cells",VALUE,6,1,12},{"Capacity",VALUE,1300,100,30000},{"VoltSrc",STRING,"VFAS"},{"SFX",BOOL,0}}
local paths={"/WIDGETS/SQLiPo/packs-a.txt","/WIDGETS/SQLiPo/packs-b.txt"}
local function clamp(v,lo,hi,d) if type(v)~="number" then return d end return max(lo,min(hi,floor(v))) end
local function checksum(s) local c=0;for i=1,#s do c=(c*31+s:byte(i))%65521 end;return c end
local function defaults(c,m) local d={seq=0,slot=2,packs={}};for i=1,24 do d.packs[i]={state=1,cells=c,mah=m,flights=0,charges=0,volts=0} end;return d end
local function encode(d)
 local a={"SQLP1|"..d.seq}
 for _,p in ipairs(d.packs) do a[#a+1]=table.concat({p.state,p.cells,p.mah,p.flights,p.charges,p.volts},",") end
 local body=table.concat(a,"|");return body.."\n"..checksum(body).."\n"
end
local function decode(s,slot)
 if type(s)~="string" then return end
 local body,c=s:match("^(SQLP1|[^\n]+)\n(%d+)\n$")
 if not body or checksum(body)~=tonumber(c) then return end
 local seq=body:match("^SQLP1|(%d+)|");if not seq or tonumber(seq)>999999999 then return end
 local d={seq=tonumber(seq),slot=slot,packs={}}
 local rest=body:match("^SQLP1|%d+|(.+)$")
 for row in rest:gmatch("[^|]+") do
  local st,ce,ma,fl,ch,vo=row:match("^(%d+),(%d+),(%d+),(%d+),(%d+),(%d+)$")
  if not st then return end
  st,ce,ma,fl,ch,vo=tonumber(st),tonumber(ce),tonumber(ma),tonumber(fl),tonumber(ch),tonumber(vo)
  if st<1 or st>5 or ce<1 or ce>12 or ma<100 or ma>30000 or fl>999999999 or ch>999999999 or vo>6500 then return end
  d.packs[#d.packs+1]={state=st,cells=ce,mah=ma,flights=fl,charges=ch,volts=vo}
 end
 if #d.packs~=24 then return end;return d
end
local function readSlot(slot)
 if not io or not io.open then return end
 local ok,s=pcall(function() local f=io.open(paths[slot],"r");if not f then return end;local a=io.read(f,2048);io.close(f);return a end)
 if ok then return decode(s,slot) end
end
local function newest() local a,b=readSlot(1),readSlot(2);if a and b then return a.seq>=b.seq and a or b end;return a or b end
local function save(w)
 local d=w.data;local slot=3-d.slot;local blob=encode(d)
 local ok,good=pcall(function() local f=io.open(paths[slot],"w");if not f then return false end;io.write(f,blob);io.close(f);local check=readSlot(slot);return check and encode(check)==blob end)
 w.unsaved=not(ok and good);if not w.unsaved then d.slot=slot end
end
local function sync(w) local d=newest();if d and d.seq>w.data.seq then w.data=d end end
local function change(w,fn)
 sync(w);if w.data.seq>=999999999 then w.notice="Save limit reached";return end
 local p=w.data.packs[w.selected];local before=table.concat({p.state,p.cells,p.mah,p.flights,p.charges,p.volts},",");fn(p)
 if before==table.concat({p.state,p.cells,p.mah,p.flights,p.charges,p.volts},",") then return end
 w.data.seq=w.data.seq+1;save(w)
 if not w.unsaved then w.flash=getTime();if w.sound and type(playTone)=="function" then pcall(playTone,880,55,0,0) end end
end
local function update(w,o)
 w.limit=clamp(o and o.Packs,1,24,12);w.selected=min(w.selected or 1,w.limit)
 w.sound=o and (o.SFX==1 or o.SFX==true) or false;w.source=o and o.VoltSrc or "VFAS";if type(w.source)~="string" then w.source="VFAS" end
end
local function create(zone,o)
 local w={zone=zone,selected=1,focus=1,page=1,draft=1,field=1,volts=nil,notice="",filter=0,gridFocus=1}
 w.data=newest() or defaults(clamp(o and o.Cells,1,12,6),clamp(o and o.Capacity,100,30000,1300))
 update(w,o);return w
end
local function voltage(w)
 if type(getSourceValue)~="function" or w.source=="" then w.volts=nil;return end
 local source=w.source
 if type(getFieldInfo)=="function" then local ok,f=pcall(getFieldInfo,source);if ok and f and f.id then source=f.id end end
 local ok,v,current,fresh=pcall(getSourceValue,source)
 if ok and type(v)=="number" and v==v and v>0 and v<=65 and current and fresh then w.volts=v else w.volts=nil end
end
local function counts(w)
 local a={0,0,0,0,0};local flights=0
 for i=1,w.limit do local p=w.data.packs[i];a[p.state]=a[p.state]+1;flights=flights+p.flights end
 return a,flights
end
local function filtered(w)
 local ids={};for i=1,w.limit do if w.filter==0 or w.data.packs[i].state==w.filter then ids[#ids+1]=i end end
 return ids
end
local function buttons(w)
 if w.page==1 then return {"Fleet","State","Setup","Summary"} end
 if w.page==2 then return {"Prev","Next","Apply","Back"} end
 if w.page==3 then return {"Field","-","+","Capture","Back"} end
 if w.page==5 then return {"Prev","Next","Open","Filter","Back"} end
 return {"Back","Fleet"}
end
local function choose(w,a)
 w.notice=""
 if w.page==1 then
  if a=="Fleet" then sync(w);w.page=5;w.gridFocus=1;w.focus=1
  elseif a=="State" then sync(w);w.draft=w.data.packs[w.selected].state;w.page=2;w.focus=1
  elseif a=="Setup" then w.page=3;w.field=1;w.focus=1
  elseif a=="Summary" then sync(w);w.page=4;w.focus=1 end
 elseif w.page==2 then
  if a=="Prev" then w.draft=(w.draft-2)%5+1
  elseif a=="Next" then w.draft=w.draft%5+1
  elseif a=="Apply" then
   change(w,function(p) if p.state~=w.draft then
    if w.draft==2 then p.charges=min(999999999,p.charges+1) elseif w.draft==3 then p.flights=min(999999999,p.flights+1) end
    p.state=w.draft end end)
   w.page=1;w.focus=2
  elseif a=="Back" then w.page=1;w.focus=2 end
 elseif w.page==3 then
  if a=="Field" then w.field=w.field%2+1
  elseif a=="-" or a=="+" then local delta=a=="+" and 1 or -1;change(w,function(p) if w.field==1 then p.cells=clamp(p.cells+delta,1,12,6) else p.mah=clamp(p.mah+delta*50,100,30000,1300) end end)
  elseif a=="Capture" then voltage(w);if w.volts then change(w,function(p)p.volts=floor(w.volts*100+.5) end);w.notice=w.unsaved and "Snapshot not saved" or "Snapshot saved" else w.notice="No fresh voltage" end
  elseif a=="Back" then w.page=1;w.focus=3 end
 elseif w.page==5 then
  local ids=filtered(w)
  if a=="Filter" then w.filter=(w.filter+1)%6;w.gridFocus=1
  elseif a=="Prev" and #ids>0 then w.gridFocus=(w.gridFocus-2)%#ids+1
  elseif a=="Next" and #ids>0 then w.gridFocus=w.gridFocus%#ids+1
  elseif a=="Open" and ids[w.gridFocus] then w.selected=ids[w.gridFocus];w.page=1;w.focus=1
  elseif a=="Back" then w.page=1;w.focus=1 end
 elseif w.page==4 then if a=="Fleet" then w.page=5;w.gridFocus=1;w.focus=1 else w.page=1;w.focus=4 end end
end
local function fit(x,y,s,f,col,width) if lcd.sizeText(s,f)>width then f=SMLSIZE end;lcd.drawText(x,y,s,f+col) end
local function box(x,y,w,h,col) lcd.drawFilledRectangle(x,y,w,h,panel);lcd.drawRectangle(x,y,w,h,col) end
local function battery(x,y,W,H,col)
 lcd.drawRectangle(x,y,W-5,H,col);lcd.drawFilledRectangle(x+W-5,y+floor(H/3),5,max(2,floor(H/3)),col)
 -- Decorative cell outlines, not a measured charge percentage.
 for i=0,2 do lcd.drawRectangle(x+3+i*floor((W-10)/3),y+3,max(2,floor((W-10)/3)-2),H-6,col) end
end
local function tile(w)
 local W,H=w.zone.w,w.zone.h;lcd.drawFilledRectangle(0,0,W,H,bg)
 if W<40 or H<18 then return end
 local a=counts(w);lcd.drawFilledRectangle(0,0,3,H,gold);lcd.drawText(7,3,"SQ / LIPO",SMLSIZE+gold)
 if H>=39 then fit(7,20,a[2].." charged",MIDSIZE,colors[2],W-12) end
 if H>=65 then fit(7,45,a[3].." flown / "..a[5].." inspect",SMLSIZE,white,W-12) end
 if H>=90 then local x=7;local ww=W-14;for i=1,5 do local seg=floor(ww*a[i]/w.limit);if seg>0 then lcd.drawFilledRectangle(x,H-9,seg,4,colors[i]);x=x+seg end end end
end
local function gridDims(W,by) local cols=W>=600 and 6 or 4;return cols,floor((W-16)/cols),floor((by-51)/3) end
local function refresh(w,event,touch)
 if event==nil then tile(w);return end
 local W,H=LCD_W,LCD_H
 lcd.drawFilledRectangle(0,0,W,H,bg)
 if W<300 or H<230 then lcd.drawText(5,5,"Colour screen 320x240+",SMLSIZE+white);return end
 if not w.lastVolt or getTime()-w.lastVolt>=50 or getTime()<w.lastVolt then voltage(w);w.lastVolt=getTime() end
 local by=H-43;local acts=buttons(w);local slot=floor((W-16)/#acts)
 if event==EVT_VIRTUAL_NEXT then w.focus=w.focus%#acts+1
 elseif event==EVT_VIRTUAL_PREV then w.focus=(w.focus-2)%#acts+1
 elseif event==EVT_VIRTUAL_ENTER then choose(w,acts[w.focus])
 elseif event==EVT_TOUCH_TAP and touch then
  if touch.y>=by and touch.y<H and touch.x>=8 and touch.x<8+slot*#acts then w.focus=1+floor((touch.x-8)/slot);choose(w,acts[w.focus])
  elseif w.page==5 and touch.y>=48 and touch.y<by-3 and touch.x>=8 then
   local ids=filtered(w);local cols,cw,ch=gridDims(W,by);local first=floor((w.gridFocus-1)/(cols*3))*cols*3+1
   local col=floor((touch.x-8)/cw);local row=floor((touch.y-48)/ch);local idx=first+row*cols+col
   if col<cols and row<3 and ids[idx] then w.gridFocus=idx;w.selected=ids[idx];w.page=1;w.focus=1 end
  end
 end
 acts=buttons(w);slot=floor((W-16)/#acts)
 local p=w.data.packs[w.selected];local a,total=counts(w)
 lcd.drawText(8,3,"SQ / LIPO BUTLER",SMLSIZE+gold)
 local recent=w.flash and getTime()-w.flash>=0 and getTime()-w.flash<100
 lcd.drawText(W-8,3,w.unsaved and "NOT SAVED" or recent and "SAVED" or "BLACK LABEL",RIGHT+SMLSIZE+(w.unsaved and colors[5] or recent and colors[2] or muted))
 if w.page==1 then
  local cw=floor((W-24)/3)
  for i,v in ipairs({a[2],a[3],a[5]}) do local x=8+(i-1)*(cw+4);box(x,24,cw,38,colors[({2,3,5})[i]]);lcd.drawText(x+5,26,({"CHARGED","FLOWN","INSPECT"})[i],SMLSIZE+muted);lcd.drawText(x+5,42,tostring(v),0+white) end
  box(8,69,W-16,by-76,colors[p.state]);lcd.drawFilledRectangle(8,69,3,by-76,colors[p.state])
  fit(16,74,string.format("PACK %02d / %02d",w.selected,w.limit),MIDSIZE,gold,W-92);battery(W-65,78,46,21,colors[p.state])
  lcd.drawText(16,103,names[p.state],0+colors[p.state]);lcd.drawText(W-16,103,p.cells.."S / "..p.mah.." mAh",RIGHT+SMLSIZE+white)
  fit(16,125,"Flights "..p.flights.." / Charges "..p.charges,SMLSIZE,white,W-32)
  lcd.drawText(16,145,w.volts and string.format("Live %.2f V (unassigned)",w.volts) or "Live voltage unavailable",SMLSIZE+muted)
  lcd.drawText(16,165,p.volts>0 and string.format("Snapshot %.2f V",p.volts/100) or "No saved snapshot",SMLSIZE+muted)
 elseif w.page==2 then
  lcd.drawText(8,25,"CONFIRM PACK STATE",0+gold)
  lcd.drawText(8,49,string.format("Pack %02d / %s",w.selected,names[p.state]),SMLSIZE+white)
  box(8,72,W-16,55,colors[w.draft]);lcd.drawText(floor(W/2),80,names[w.draft],CENTER+MIDSIZE+colors[w.draft])
  lcd.drawText(floor(W/2),108,w.draft==p.state and "No change" or "Apply to confirm",CENTER+SMLSIZE+muted)
  lcd.drawTextLines(8,137,W-16,max(1,by-141),"Check actual pack first. Charged/Flown transitions log one event.",SMLSIZE+white)
 elseif w.page==3 then
  lcd.drawText(8,25,"PACK PROFILE / "..w.selected,0+gold)
  box(8,49,W-16,28,w.field==1 and gold or muted);lcd.drawText(15,54,"Cells: "..p.cells.."S",0+white)
  box(8,81,W-16,28,w.field==2 and gold or muted);lcd.drawText(15,86,"Capacity: "..p.mah.." mAh",0+white)
  lcd.drawText(8,115,w.volts and string.format("Live source: %.2f V",w.volts) or "Live source: unavailable",SMLSIZE+muted)
  lcd.drawText(8,135,p.volts>0 and string.format("Saved: %.2f V",p.volts/100) or "Saved: --",SMLSIZE+white)
  lcd.drawText(8,155,w.notice~="" and w.notice or "Capture only the connected pack.",SMLSIZE+gold)
 elseif w.page==5 then
  local ids=filtered(w);w.gridFocus=max(1,min(w.gridFocus,#ids));local cols,cw,ch=gridDims(W,by);local first=floor((w.gridFocus-1)/(cols*3))*cols*3+1
  lcd.drawText(8,26,"FLEET / "..(w.filter==0 and "ALL" or names[w.filter]),0+gold)
  lcd.drawText(W-8,27,#ids.." packs",RIGHT+SMLSIZE+muted)
  if #ids==0 then lcd.drawText(8,65,"No matching packs",0+white) end
  for k=0,cols*3-1 do local idx=first+k;local id=ids[idx];if id then
   local q=w.data.packs[id];local x=8+(k%cols)*cw;local y=48+floor(k/cols)*ch
   box(x,y,cw-4,ch-4,idx==w.gridFocus and gold or colors[q.state]);lcd.drawFilledRectangle(x+2,y+2,3,ch-8,colors[q.state])
   lcd.drawText(x+8,y+3,string.format("%02d / %dS",id,q.cells),SMLSIZE+white)
   local labels={"NEW","CHG","FLOWN","STOR","CHECK"};lcd.drawText(x+8,y+19,labels[q.state],SMLSIZE+colors[q.state])
   if ch>=56 then lcd.drawText(x+8,y+34,q.mah.." mAh",SMLSIZE+muted) end
  end end
 else
  lcd.drawText(8,25,"SESSION REVIEW",0+gold)
  lcd.drawText(W-8,27,"Flights "..total,RIGHT+SMLSIZE+white)
  local x=8;for i=1,5 do local seg=floor((W-16)*a[i]/w.limit);if seg>0 then lcd.drawFilledRectangle(x,49,seg,9,colors[i]);x=x+seg end end
  for i=1,5 do lcd.drawText(8,64+(i-1)*17,names[i].."  "..a[i],SMLSIZE+colors[i]) end
  lcd.drawTextLines(8,151,W-16,max(1,by-155),a[3]>0 and "Flown packs: inspect and follow storage guidance." or "Verify actual pack condition before storage.",SMLSIZE+gold)
 end
 for i,s in ipairs(acts) do local x=8+(i-1)*slot;local sel=i==w.focus;lcd.drawFilledRectangle(x,by,slot-2,35,sel and gold or panel);lcd.drawRectangle(x,by,slot-2,35,gold);lcd.drawText(x+floor((slot-2)/2),by+9,s,CENTER+SMLSIZE+(sel and bg or white)) end
end
return {name="SQLiPo",options=options,create=create,update=update,refresh=refresh}
