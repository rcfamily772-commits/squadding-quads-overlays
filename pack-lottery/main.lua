-- Squadding Quads | The Pack Lottery | preview 1.8 - Radio Black Label
local levels = {"Beginner", "Intermediate", "Advanced", "OnlyDrones", "Bench Pilot", "Adults Only"}
local decks = {
  {
    {"Figure of eight", "Circle two markers in an eight. Cross the middle at the same height on both passes."},
    {"Park it", "Pick a landing patch before take-off. Touch down inside it three times this pack."},
    {"The slow lap", "Fly a wide lap at walking pace. Keep your height steady through all four turns."},
    {"Both ways round", "Orbit a marker once each way. Keep it in the same part of your picture."},
    {"Hold the horizon", "Fly a straight out-and-back. Aim for the same horizon height on both legs."},
    {"Square deal", "Pick four corners in open space. Fly the square twice and match your turning points."},
    {"Smooth departure", "Lift off, pause at a hover, then ease into forward flight without dipping."},
    {"Throttle steps", "Fly a straight line at three speeds. Keep the same height as you change pace."}
  }, {
    {"Mirror rolls", "At recovery height, roll left, then right. Finish each roll on your original heading."},
    {"Exit on cue", "Choose a distant landmark. Fly a wide orbit and exit pointing straight at it."},
    {"The camera pass", "Frame one marker for half an orbit. Keep its size constant throughout the shot."},
    {"Flat eight", "Fly three figure eights. Match both loops for size and cross at the same point."},
    {"Brake on a mark", "Fly towards an imaginary line. Ease to a hover over it without overshooting."},
    {"Split-S exit", "In open space with recovery height, fly a split-S and exit parallel to your entry line."},
    {"Reverse the reel", "Fly a three-turn line, then fly its mirror image. Compare the rhythms on DVR."},
    {"Clean loop", "Fly a free-space power loop. Pick a reference on the horizon and recover facing it."}
  }, {
    {"The SQ combo", "Link a split-S to a power loop in open sky. Keep the transition free of extra rolls."},
    {"Juicy flick", "Use a horizon reference for one juicy flick. Repeat it and match the exit heading."},
    {"BoyWonder mirror", "Build a three-trick line. Reverse every roll direction on the second run."},
    {"Rolling exit", "Exit a wide orbit into one smooth roll. Finish on the tangent you chose beforehand."},
    {"Same sky twice", "Fly two free-space loops in succession. Match the apex height and exit heading."},
    {"Pause the roll", "At recovery height, fly a four-point roll. Make the pauses equal on your DVR."},
    {"One-take line", "Combine an orbit, a roll and a loop in one shot. Give each move a deliberate exit."},
    {"The other hand", "Choose your strongest freestyle line. Fly its mirror twice with the same timing."}
  },
  {
    {"Just Fly", "Come on, please fly. Pretty please?"},
    {"Just Fly", "Squadding Quads will beat you... in the pack tally if you don't fly!"},
    {"Just Fly", "Does the day end with a Y? Then fly!"},
    {"Just Fly", "Your batteries didn't charge themselves for a day on the sofa."},
    {"Just Fly", "Less scrolling, more rolling."},
    {"Just Fly", "The Angry Karen can wait. If it's safe to fly, get a pack in!"},
    {"Just Fly", "BoyWonder has probably flown three packs already. Just saying."},
    {"Just Fly", "Your drone is not a particularly expensive paperweight."},
    {"Just Fly", "No tricks. No pressure. Just you and the sticks."},
    {"Just Fly", "One... More... Pack...!"},
    {"Just Fly", "We don't fly spreadsheets. Get those props turning!"},
    {"Just Fly", "The only challenge today is to enjoy yourself. Go fly when it's safe."}
  },
  {
    {"Touch Grass & Fly", "Betaflight ain't gonna fly for you. Unplug it and touch grass!"},
    {"Touch Grass & Fly", "I know the bench in the shed is warm, but you're a pilot. Fly the bloody drone!"},
    {"Touch Grass & Fly", "You've tuned it more times than you've flown it. Get outside!"},
    {"Touch Grass & Fly", "Breaking news: grass exists outside your shed."},
    {"Touch Grass & Fly", "Your soldering iron has more hours on it than your goggles."},
    {"Touch Grass & Fly", "Another PID tune? Mate, the problem might be holding the controller."},
    {"Touch Grass & Fly", "Your quad has the latest firmware. Your flying skills are still on factory settings."},
    {"Touch Grass & Fly", "Blackbox analysis requires you to actually fly the drone first."},
    {"Touch Grass & Fly", "That USB cable isn't a flight accessory. Unplug it!"},
    {"Touch Grass & Fly", "The Angry Karen has reported you missing. Apparently you're still in the shed."},
    {"Touch Grass & Fly", "You've built a flying machine, not a bloody museum exhibit."},
    {"Touch Grass & Fly", "Less bench testing. More field testing. We don't fly spreadsheets!"}
  },
  {
    {"Fucking Fly It", "You paid for it. Fucking fly it!"},
    {"Fucking Fly It", "Stop pissing about and get the bastard airborne."},
    {"Fucking Fly It", "All the gear and fuck all flight time. Sort it out!"},
    {"Fucking Fly It", "Your thumbs aren't ornamental, you absolute weapon."},
    {"Fucking Fly It", "That drone cost £400. It's doing a magnificent impression of a fucking paperweight."},
    {"Fucking Fly It", "Nobody gives a shit about your PID tune if you never fly."},
    {"Fucking Fly It", "Another fucking firmware update? Have you considered flying?"},
    {"Fucking Fly It", "Get off your arse. Those batteries aren't going to discharge themselves."},
    {"Fucking Fly It", "You call yourself a pilot? Prove it, you magnificent bastard."},
    {"Fucking Fly It", "Stop watching Squadding Quads and go fly your own fucking drone!"},
    {"Fucking Fly It", "You've spent more time arguing about radios than using the bloody things."},
    {"Fucking Fly It", "Fuck perfection. Fuck the excuses. Enjoy yourself and fly the bastard!"}
  }
}

local rgb=lcd.RGB
local ink,panel,gold,paper,white,muted=rgb(13,15,17),rgb(30,31,32),rgb(224,191,124),rgb(248,242,225),rgb(247,244,232),rgb(120,125,128)
local accents={rgb(37,108,72),rgb(26,92,146),rgb(122,65,155),rgb(160,50,110),rgb(113,94,48),rgb(167,35,47)}
local foil={paper,rgb(218,229,239),rgb(248,217,140),rgb(225,211,250)}
local edge={gold,rgb(129,158,185),rgb(160,112,25),rgb(126,70,181)}
local rarity={"STD","RARE","LEG","MYTH"}
local codes={"BG","IN","AD","OD","BP","18"}
local floor,min,max=math.floor,math.min,math.max
local options={{"SFX",BOOL,0},{"Motion",BOOL,1},{"Haptic",BOOL,0}}
local function on(o,k,default) if not o or o[k]==nil then return default end return o[k]==1 or o[k]==true end
local function update(w,o) w.sound=on(o,"SFX",false);w.motion=on(o,"Motion",true);w.haptic=on(o,"Haptic",false) end
local function signal(w,t)
  if w.sound and type(playTone)=="function" then pcall(playTone,t,65,0,0) end
  if w.haptic and type(playHaptic)=="function" then pcall(playHaptic,30,0,0) end
end
-- Compact two-slot collection. Each slot is validated before use; interrupted
-- writes leave the other slot intact. Only explicit draws and completions write.
local paths={"/WIDGETS/SQLotto/album-a.txt","/WIDGETS/SQLotto/album-b.txt"}
local function checksum(s)
  local c=0
  for i=1,#s do c=(c*31+s:byte(i))%65521 end
  return c
end
local function empty()
  return {seq=0,marks=string.rep("0",60),wins={0,0,0,0,0,0},draws=0,slot=2}
end
local function decode(s,slot)
  if type(s)~="string" then return end
  local body,check=s:match("^(SQ18|[^\n]+)\n(%d+)\n$")
  if not body or checksum(body)~=tonumber(check) then return end
  local seq,marks,a,b,c,d,e,f,draws=body:match("^SQ18|(%d+)|([0-4]+)|(%d+),(%d+),(%d+),(%d+),(%d+),(%d+)|(%d+)$")
  if not seq or #marks~=60 then return end
  local v={seq=tonumber(seq),marks=marks,wins={tonumber(a),tonumber(b),tonumber(c),tonumber(d),tonumber(e),tonumber(f)},draws=tonumber(draws),slot=slot}
  if v.seq>999999999 or v.draws>999999999 then return end
  for _,x in ipairs(v.wins) do if x>999999999 then return end end
  return v
end
local function readSlot(slot)
  if not io or not io.open then return end
  local ok,s=pcall(function()
    local f=io.open(paths[slot],"r");if not f then return end
    local r=io.read(f,240);io.close(f);return r
  end)
  if ok then return decode(s,slot) end
end
local function newest()
  local a,b=readSlot(1),readSlot(2)
  if a and b then return a.seq>=b.seq and a or b end
  return a or b
end
local function save(w)
  local d=w.album
  local slot=3-d.slot
  local body="SQ18|"..d.seq.."|"..d.marks.."|"..table.concat(d.wins,",").."|"..d.draws
  local ok,done=pcall(function()
    if not io or not io.open then return false end
    local f=io.open(paths[slot],"w");if not f then return false end
    io.write(f,body.."\n"..checksum(body).."\n");io.close(f)
    local check=readSlot(slot);return check and check.seq==d.seq and check.marks==d.marks
  end)
  w.unsaved=not(ok and done)
  if not w.unsaved then d.slot=slot end
end
local function cardIndex(l,c)
  local index=c
  for i=1,l-1 do index=index+#decks[i] end
  return index
end
local function record(w,win)
  local latest=newest()
  if latest and latest.seq>w.album.seq then w.album=latest end
  local d=w.album
  d.seq=min(999999999,d.seq+1)
  if win then d.wins[w.level]=min(999999999,d.wins[w.level]+1)
  else
    d.draws=min(999999999,d.draws+1)
    local i=cardIndex(w.level,w.card)
    local old=tonumber(d.marks:sub(i,i)) or 0
    if w.rarity>old then d.marks=d.marks:sub(1,i-1)..w.rarity..d.marks:sub(i+1) end
  end
  save(w)
end
local function summary(d)
  local total,found=0,0
  for _,x in ipairs(d.wins) do total=total+x end
  for i=1,60 do if d.marks:sub(i,i)~="0" then found=found+1 end end
  local awards={d.wins[5]>=1,d.wins[3]>=10,d.wins[6]>=10,total>=25,total>=50,total>=100,found==60,total>=500,total>=1000}
  local a=0;for _,x in ipairs(awards) do if x then a=a+1 end end
  local rank=total>=1000 and "FOREVER HUMBLE" or total>=500 and "SQ LEGEND" or total>=100 and "ELITE PILOT" or total>=25 and "FIELD VETERAN" or total>=1 and "FIELD PILOT" or "CADET"
  return total,found,a,rank,awards
end
local function create(zone,o)
  local w={zone=zone,level=1,bags={{},{},{},{},{},{}},last={},focus=1,seed=getTime()%65536,attempts=0,session=0,album=newest() or empty(),view=0,unbox=true}
  update(w,o);return w
end
local function rng(w)
  w.seed=(25173*w.seed+13849)%65536
  return w.seed/65536
end
local function draw(w)
  local bag=w.bags[w.level]
  if #bag==0 then
    w.seed=(w.seed+getTime())%65536
    for i=1,#decks[w.level] do bag[i]=i end
    for i=#bag,2,-1 do local j=1+floor(rng(w)*i);bag[i],bag[j]=bag[j],bag[i] end
    if bag[#bag]==w.last[w.level] then bag[1],bag[#bag]=bag[#bag],bag[1] end
  end
  w.card=table.remove(bag);w.last[w.level]=w.card
  local r=rng(w);w.rarity=r<.01 and 4 or r<.10 and 3 or r<.30 and 2 or 1
  w.attempts=1;w.message=nil;w.focus=1
  record(w,false)
  w.duration=w.unbox and 42 or 24;w.unbox=false
  w.dealAt=w.motion and getTime() or nil
  signal(w,w.rarity>=3 and 1320 or 880)
end
local function actions(w)
  if w.view>0 then return {"Back","Next"} end
  if w.card then return {"Landed","Retry","Deal","Deck","Stats"} end
  return {"Draw","Deck","Stats"}
end
local function choose(w,a)
  if a=="Back" then w.view=0;w.focus=1
  elseif a=="Next" then w.view=w.view%3+1;w.focus=2
  elseif a=="Stats" then local d=newest();if d and d.seq>w.album.seq then w.album=d end;w.view=1;w.focus=1
  elseif a=="Deck" then w.level=w.level%6+1;w.card=nil;w.message=nil;w.focus=2;w.unbox=true;signal(w,660)
  elseif a=="Retry" and w.card then w.attempts=w.attempts+1;signal(w,450)
  elseif a=="Landed" and w.card then record(w,true);w.session=w.session+1;w.card=nil;w.message="Challenge completed.";w.focus=1;signal(w,1050)
  elseif a=="Draw" or a=="Deal" then draw(w) end
end
local function textFit(x,y,s,flags,available)
  if lcd.sizeText(s,flags)>available then flags=SMLSIZE end
  lcd.drawText(x,y,s,flags+white)
end
local function panelBox(x,y,w,h,col)
  lcd.drawFilledRectangle(x,y,w,h,col)
  lcd.drawRectangle(x,y,w,h,gold)
end
local function emblem(x,y,r,col)
  lcd.drawCircle(x,y,r,col);lcd.drawCircle(x,y,max(1,r-3),col)
  lcd.drawFilledRectangle(x-2,y-2,5,5,col)
  for _,v in ipairs({{-1,-1},{1,-1},{-1,1},{1,1}}) do
    local dx,dy=v[1]*floor(r*.55),v[2]*floor(r*.55)
    lcd.drawLine(x,y,x+dx,y+dy,SOLID,col)
    lcd.drawCircle(x+dx,y+dy,max(2,floor(r*.2)),col)
  end
end
local function tile(w)
  local z=w.zone
  lcd.drawFilledRectangle(0,0,z.w,z.h,ink)
  if z.w<40 or z.h<18 then return end
  lcd.drawFilledRectangle(0,0,3,z.h,gold)
  local total,found=summary(w.album)
  lcd.drawText(8,3,z.w>=130 and "SQ / BLACK LABEL" or "SQ LOTTO",SMLSIZE+gold)
  if z.h>=40 then textFit(8,22,w.card and (w.level==6 and "Adults Only" or decks[w.level][w.card][1]) or (total.." landed"),0,z.w-14) end
  if z.h>=66 then
    lcd.drawText(8,44,found.."/60 collected",SMLSIZE+white)
    lcd.drawFilledRectangle(8,z.h-7,z.w-16,3,panel)
    lcd.drawFilledRectangle(8,z.h-7,floor((z.w-16)*found/60),3,gold)
  end
end
local awardNames={"Shed Escapee","BoyWonder Approved","Absolutely Unhinged","Angry Karen Survivor","Touch Grass Pro","One More Pack","The Collector","No Spreadsheets","Forever Humble"}
local function stats(w,W,H,by)
  local total,found,a,rank,awards=summary(w.album)
  panelBox(10,25,W-20,by-33,panel)
  lcd.drawText(20,32,w.view==1 and "PILOT PASSPORT" or w.view==2 and "COLLECTOR'S VAULT" or "ACHIEVEMENTS",0+gold)
  if w.view==1 then
    lcd.drawText(20,55,rank,MIDSIZE+white)
    lcd.drawText(20,89,"Landed "..total.."   |   Drawn "..w.album.draws,SMLSIZE+white)
    lcd.drawText(20,110,"Collection "..found.."/60   |   Awards "..a.."/9",SMLSIZE+white)
    lcd.drawFilledRectangle(20,137,W-40,8,ink);lcd.drawFilledRectangle(20,137,floor((W-40)*found/60),8,gold)
    if by>180 then lcd.drawText(20,153,w.unsaved and "SD save unavailable" or "Collection saved locally",SMLSIZE+muted) end
  elseif w.view==2 then
    local dx=floor((W-112)/12);local dy=min(24,floor((by-67)/6))
    for l=1,6 do
      local y=56+(l-1)*dy
      lcd.drawText(20,y,codes[l],SMLSIZE+white)
      for c=1,#decks[l] do
        local r=tonumber(w.album.marks:sub(cardIndex(l,c),cardIndex(l,c))) or 0
        lcd.drawFilledRectangle(55+(c-1)*dx,y+2,max(2,dx-3),max(5,dy-5),r==0 and ink or foil[r])
        if r>0 then lcd.drawRectangle(55+(c-1)*dx,y+2,max(2,dx-3),max(5,dy-5),edge[r]) end
      end
    end
  else
    local dy=min(24,floor((by-65)/5))
    local cw=floor((W-34)/2)
    for i=1,9 do
      local x=18+((i-1)%2)*cw;local y=55+floor((i-1)/2)*dy
      local label=(awards[i] and "+ " or "- ")..awardNames[i]
      if lcd.sizeText(label,SMLSIZE)>cw-3 then label=label:sub(1,17) end
      lcd.drawText(x,y,label,SMLSIZE+(awards[i] and gold or muted))
    end
  end
end
local function refresh(w,event,touch)
  if event==nil then tile(w);return end
  local W,H=LCD_W,LCD_H
  if W<300 or H<230 then lcd.drawFilledRectangle(0,0,W,H,ink);lcd.drawText(5,5,"Use a colour screen 320x240+",SMLSIZE+white);return end
  local pad=8;local bh=min(43,floor(H/6));local by=H-bh-pad
  local acts=actions(w);local slot=floor((W-2*pad)/#acts)
  local elapsed=w.dealAt and getTime()-w.dealAt or 999
  local moving=elapsed>=0 and elapsed<(w.duration or 24)
  if not moving then
    w.dealAt=nil
    if event==EVT_VIRTUAL_NEXT then w.focus=w.focus%#acts+1
    elseif event==EVT_VIRTUAL_PREV then w.focus=(w.focus-2)%#acts+1
    elseif event==EVT_VIRTUAL_ENTER then choose(w,acts[w.focus])
    elseif event==EVT_TOUCH_TAP and touch and touch.y>=by and touch.y<by+bh then
      local dx=touch.x-pad;if dx>=0 and dx<slot*#acts and dx%slot<slot-2 then w.focus=1+floor(dx/slot);choose(w,acts[w.focus]) end
    end
  end
  acts=actions(w);slot=floor((W-2*pad)/#acts)
  lcd.drawFilledRectangle(0,0,W,H,ink)
  lcd.drawText(9,3,"SQ / BLACK LABEL",SMLSIZE+gold)
  lcd.drawText(W-9,3,"PACKS "..w.session,RIGHT+SMLSIZE+white)
  if w.view>0 then stats(w,W,H,by) else
    local x,y,cw,ch=12,27,W-30,by-37
    local ac=accents[w.level];local tier=w.card and w.rarity or 1
    lcd.drawFilledRectangle(x+6,y+5,cw,ch,panel);lcd.drawRectangle(x+6,y+5,cw,ch,ac)
    elapsed=w.dealAt and getTime()-w.dealAt or 999
    moving=elapsed>=0 and elapsed<(w.duration or 24)
    if moving then
      local shift=floor((1-elapsed/w.duration)*min(10,floor(W/32)))
      panelBox(x+shift,y,cw,ch,panel)
      lcd.drawRectangle(x+shift+4,y+4,cw-8,ch-8,ac)
      emblem(x+shift+floor(cw/2),y+floor(ch/2)-14,min(22,floor(ch/5)),gold)
      lcd.drawText(x+shift+floor(cw/2),y+floor(ch/2)+17,(w.duration==42 and elapsed<20) and "UNBOXING" or "DEALING",CENTER+SMLSIZE+gold)
    else
      lcd.drawFilledRectangle(x,y,cw,ch,foil[tier]);lcd.drawRectangle(x,y,cw,ch,gold);lcd.drawRectangle(x+3,y+3,cw-6,ch-6,edge[tier])
      lcd.drawFilledRectangle(x+6,y+6,cw-12,19,ac)
      lcd.drawText(x+10,y+7,levels[w.level],SMLSIZE+white)
      if w.card then lcd.drawText(x+cw-10,y+7,rarity[tier].." / "..w.attempts,RIGHT+SMLSIZE+white) end
      local card=w.card and decks[w.level][w.card]
      local title=card and card[1] or (w.message and "Landed it!" or "Draw a card")
      local tf=MIDSIZE;if lcd.sizeText(title,tf)>cw-20 then tf=0 end
      lcd.drawText(x+10,y+30,title,tf+ink)
      local body=card and card[2] or w.message or (w.level==6 and "ADULTS ONLY: strong language. Draw to reveal." or "Choose a deck. Complete safety checks. Fly when safe.")
      local footer=y+ch-18
      lcd.drawTextLines(x+10,y+57,cw-20,max(1,footer-y-59),body,SMLSIZE+ink)
      lcd.drawFilledRectangle(x+9,footer,cw-18,1,edge[tier])
      lcd.drawText(x+10,footer+2,w.card and ("SQ-"..codes[w.level].."-"..string.format("%02d",w.card)) or "FIELD EDITION",SMLSIZE+ink)
      lcd.drawText(x+cw-10,footer+2,w.unsaved and "NOT SAVED" or ("LEFT "..#w.bags[w.level]),RIGHT+SMLSIZE+ink)
    end
  end
  for i,a in ipairs(acts) do local x=pad+(i-1)*slot;local selected=i==w.focus
    lcd.drawFilledRectangle(x,by,slot-2,bh,selected and gold or panel)
    lcd.drawRectangle(x,by,slot-2,bh,gold)
    lcd.drawText(x+floor((slot-2)/2),by+floor((bh-16)/2),a,CENTER+SMLSIZE+(selected and ink or white))
  end
end
return {name="SQLotto",options=options,create=create,update=update,refresh=refresh}
