-- SQ LiPo Butler v1.0 | read-only telemetry, manual battery inventory
local floor,min,max=math.floor,math.min,math.max
local rgb=lcd.RGB
local bg,panel,gold,white,muted=rgb(14,17,18),rgb(30,36,37),rgb(223,191,126),rgb(247,243,231),rgb(158,174,170)
local names={"Unassigned","Charged","Flown","Storage","Inspect"}
local colors={muted,rgb(107,211,149),rgb(241,174,85),rgb(126,178,237),rgb(245,117,107)}
local options={{"Packs",VALUE,12,1,24},{"Cells",VALUE,6,1,12},{"Capacity",VALUE,1300,100,30000},{"VoltSrc",STRING,"VFAS"}}
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
 fn(w.data.packs[w.selected]);w.data.seq=w.data.seq+1;save(w)
end
local function update(w,o)
 w.limit=clamp(o and o.Packs,1,24,12);w.selected=min(w.selected or 1,w.limit)
 w.source=o and o.VoltSrc or "VFAS";if type(w.source)~="string" then w.source="VFAS" end
end
local function create(zone,o)
 local w={zone=zone,selected=1,focus=1,page=1,draft=1,field=1,volts=nil,notice=""}
 w.data=newest() or defaults(clamp(o and o.Cells,1,12,6),clamp(o and o.Capacity,100,30000,1300))
 update(w,o);return w
end
local function voltage(w)
 if type(getSourceValue)~="function" or w.source=="" then w.volts=nil;return end
 local ok,v,current,fresh=pcall(getSourceValue,w.source)
 if ok and type(v)=="number" and v==v and v>0 and v<=65 and current and fresh then w.volts=v else w.volts=nil end
end
local function counts(w)
 local a={0,0,0,0,0};local flights=0
 for i=1,w.limit do local p=w.data.packs[i];a[p.state]=a[p.state]+1;flights=flights+p.flights end
 return a,flights
end
local function buttons(w)
 if w.page==1 then return {"Prev","Next","State","Setup","Summary"} end
 if w.page==2 then return {"Prev","Next","Apply","Back"} end
 if w.page==3 then return {"Field","-","+","Capture","Back"} end
 return {"Back"}
end
local function choose(w,a)
 w.notice=""
 if w.page==1 then
  if a=="Prev" then w.selected=(w.selected-2)%w.limit+1
  elseif a=="Next" then w.selected=w.selected%w.limit+1
  elseif a=="State" then sync(w);w.draft=w.data.packs[w.selected].state;w.page=2;w.focus=1
  elseif a=="Setup" then w.page=3;w.field=1;w.focus=1
  elseif a=="Summary" then sync(w);w.page=4;w.focus=1 end
 elseif w.page==2 then
  if a=="Prev" then w.draft=(w.draft-2)%5+1
  elseif a=="Next" then w.draft=w.draft%5+1
  elseif a=="Apply" then
   if w.draft~=w.data.packs[w.selected].state then
    change(w,function(p) if p.state~=w.draft then
     if w.draft==2 then p.charges=min(999999999,p.charges+1) elseif w.draft==3 then p.flights=min(999999999,p.flights+1) end
     p.state=w.draft end end)
   end
   w.page=1;w.focus=3
  elseif a=="Back" then w.page=1;w.focus=3 end
 elseif w.page==3 then
  if a=="Field" then w.field=w.field%2+1
  elseif a=="-" or a=="+" then local delta=a=="+" and 1 or -1;change(w,function(p) if w.field==1 then p.cells=clamp(p.cells+delta,1,12,6) else p.mah=clamp(p.mah+delta*50,100,30000,1300) end end)
  elseif a=="Capture" then voltage(w);if w.volts then change(w,function(p)p.volts=floor(w.volts*100+.5) end);w.notice="Snapshot recorded" else w.notice="No fresh voltage" end
  elseif a=="Back" then w.page=1;w.focus=4 end
 elseif w.page==4 then w.page=1;w.focus=5 end
end
local function fit(x,y,s,f,col,width) if lcd.sizeText(s,f)>width then f=SMLSIZE end;lcd.drawText(x,y,s,f+col) end
local function box(x,y,w,h,col) lcd.drawFilledRectangle(x,y,w,h,panel);lcd.drawRectangle(x,y,w,h,col) end
local function tile(w)
 local W,H=w.zone.w,w.zone.h;lcd.drawFilledRectangle(0,0,W,H,bg)
 if W<40 or H<18 then return end
 local a=counts(w);lcd.drawFilledRectangle(0,0,3,H,gold);lcd.drawText(7,3,"SQ LIPO",SMLSIZE+gold)
 if H>=39 then fit(7,20,a[2].." ready",MIDSIZE,colors[2],W-12) end
 if H>=65 then fit(7,45,a[3].." flown / "..a[5].." inspect",SMLSIZE,white,W-12) end
end
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
 elseif event==EVT_TOUCH_TAP and touch and touch.y>=by and touch.y<H and touch.x>=8 and touch.x<8+slot*#acts then w.focus=1+floor((touch.x-8)/slot);choose(w,acts[w.focus]) end
 acts=buttons(w);slot=floor((W-16)/#acts)
 local p=w.data.packs[w.selected];local a,total=counts(w)
 lcd.drawText(8,3,"SQ / LIPO BUTLER",SMLSIZE+gold)
 lcd.drawText(W-8,3,w.unsaved and "NOT SAVED" or "BLACK LABEL",RIGHT+SMLSIZE+(w.unsaved and colors[5] or muted))
 if w.page==1 then
  local cw=floor((W-24)/3)
  for i,v in ipairs({a[2],a[3],a[5]}) do local x=8+(i-1)*(cw+4);box(x,24,cw,39,colors[({2,3,5})[i]]);lcd.drawText(x+5,26,({"READY","FLOWN","INSPECT"})[i],SMLSIZE+muted);lcd.drawText(x+5,43,tostring(v),0+white) end
  box(8,70,W-16,by-77,colors[p.state])
  fit(16,76,string.format("PACK %02d / %02d",w.selected,w.limit),MIDSIZE,gold,W-32)
  lcd.drawText(16,106,names[p.state],0+colors[p.state])
  lcd.drawText(W-16,106,p.cells.."S / "..p.mah.." mAh",RIGHT+SMLSIZE+white)
  lcd.drawText(16,130,"Flights "..p.flights.." / Charges "..p.charges,SMLSIZE+white)
  local v=w.volts and string.format("%.2f V",w.volts) or "-- V"
  lcd.drawText(16,153,"Live "..v.." (unassigned)",SMLSIZE+muted)
  if by>=220 then lcd.drawText(16,177,p.volts>0 and string.format("Saved snapshot %.2f V",p.volts/100) or "No voltage snapshot",SMLSIZE+muted) end
 elseif w.page==2 then
  lcd.drawText(8,26,"CONFIRM PACK STATE",0+gold)
  lcd.drawText(8,50,string.format("Pack %02d  /  Current: %s",w.selected,names[p.state]),SMLSIZE+white)
  box(8,75,W-16,58,colors[w.draft]);lcd.drawText(floor(W/2),88,names[w.draft],CENTER+MIDSIZE+colors[w.draft])
  lcd.drawTextLines(8,140,W-16,max(1,by-145),"Apply only after checking the actual pack. Charged/Flown transitions log one event.",SMLSIZE+white)
 elseif w.page==3 then
  lcd.drawText(8,26,"PACK PROFILE / "..w.selected,0+gold)
  lcd.drawText(8,54,(w.field==1 and "> " or "  ").."Cells: "..p.cells.."S",0+white)
  lcd.drawText(8,80,(w.field==2 and "> " or "  ").."Capacity: "..p.mah.." mAh",0+white)
  lcd.drawText(8,112,w.volts and string.format("Live source: %.2f V",w.volts) or "Live source: unavailable",SMLSIZE+muted)
  lcd.drawText(8,133,p.volts>0 and string.format("Saved: %.2f V",p.volts/100) or "Saved: --",SMLSIZE+white)
  lcd.drawText(8,155,w.notice~="" and w.notice or "Capture only the connected pack.",SMLSIZE+gold)
 else
  lcd.drawText(8,26,"SESSION CHECK / INVENTORY",0+gold)
  for i=1,5 do lcd.drawText(8,48+(i-1)*19,names[i].."  "..a[i],SMLSIZE+colors[i]) end
  lcd.drawText(W-8,49,"Logged flights "..total,RIGHT+SMLSIZE+white)
  lcd.drawTextLines(8,148,W-16,max(1,by-151),a[3]>0 and "Flown packs: inspect and follow storage guidance." or "Check packs before transport and storage.",SMLSIZE+gold)
 end
 for i,s in ipairs(acts) do local x=8+(i-1)*slot;local sel=i==w.focus;lcd.drawFilledRectangle(x,by,slot-2,35,sel and gold or panel);lcd.drawRectangle(x,by,slot-2,35,gold);lcd.drawText(x+floor((slot-2)/2),by+9,s,CENTER+SMLSIZE+(sel and bg or white)) end
end
return {name="SQLiPo",options=options,create=create,update=update,refresh=refresh}
