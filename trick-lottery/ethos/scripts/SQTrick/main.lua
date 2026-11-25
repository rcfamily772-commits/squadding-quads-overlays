-- Squadding Quads | Trick Lottery ETHOS 1.0 preview
-- Read-only training companion. No flight-control or telemetry writes.
local cards={
{"Deck of Wings","Fly one smooth rectangular circuit at steady height and speed.","Fixed Wing","Basic circuit","square"},
{"Mirror circuit","Fly left- and right-hand circuits with ample clearance.","Fixed Wing","Circuit control","square"},
{"Horizon keeper","Hold a straight level leg for ten seconds in clear air.","Fixed Wing","Level flight","line"},
{"The big eight","Fly a wide figure eight at a consistent crossing height.","Fixed Wing","Coordinated turns","eight"},
{"Three gentle banks","Link three broad alternating turns at comfortable airspeed.","Fixed Wing","Bank control","s"},
{"Heading hold","Maintain a steady heading for ten seconds in clear air.","Fixed Wing","Level flight","line"},
{"Parallel lines","Fly two parallel legs with a wide turn between them.","Fixed Wing","Circuit control","line"},
{"Smooth climb","Climb gently, level out and hold heading with ample clearance.","Fixed Wing","Energy management","line"},
{"Descent discipline","Make a gentle descent and level out well above ground.","Fixed Wing","Energy management","line"},
{"Speed step","Change between two comfortable cruise speeds while holding height.","Fixed Wing","Airspeed awareness","line"},
{"Windward circuit","In suitable wind, fly a wide circuit and note ground-track changes.","Fixed Wing","Wind awareness","square"},
{"Wind correction","Hold a straight ground track in light crosswind at safe height.","Fixed Wing","Wind awareness","line"},
{"The long glide","At generous altitude, practise a short reduced-power glide at safe airspeed.","Fixed Wing","Glide practice","line"},
{"Smooth return","Return from a normal circuit to a stable approach heading.","Fixed Wing","Circuit control","land"},
{"Go-around","Practise an early go-around from a stable approach with safe clearance.","Fixed Wing","Approach control","land"},
{"Landing zone","Make a normal landing in a clear designated landing area.","Fixed Wing","Landing practice","land"},
{"Two tidy landings","Complete two controlled landings, stopping for checks between flights.","Fixed Wing","Landing practice","land"},
{"Steady camera pass","Fly a smooth filming pass in open air at safe height, away from people.","Fixed Wing","Level flight","line"},
{"Symmetric arcs","Fly two broad turns of similar size, left then right.","Fixed Wing","Coordinated turns","s"},
{"Energy review","Review DVR or logs after a normal circuit for smooth speed changes.","Fixed Wing","Flight review","line"},
{"Ground rush 50","SIM ONLY: Fly a low-level pass above 50 km/h in a simulator.","Fixed Wing Sim","Simulator control","line"},
{"Axial roll","SIM ONLY: Complete an axial roll and return to level flight.","Fixed Wing Sim","Simulator aerobatics","roll"},
{"Big sky loop","SIM ONLY: Fly one smooth loop and return to the entry heading.","Fixed Wing Sim","Simulator aerobatics","loop"},
{"Cuban practice","SIM ONLY: Practise a half Cuban eight with virtual recovery height.","Fixed Wing Sim","Simulator aerobatics","loop"},
{"Slow flight lab","SIM ONLY: Explore slow flight and recover before losing control.","Fixed Wing Sim","Simulator airspeed","line"}
}
local function create()
  return {sim=false, card=nil, bag={}, focus=1, dealt=0, landed=0, retries=0, done=false, note="Draw a card before take-off.", buttons={}}
end
local function refill(w)
  w.bag={}
  for i=1,(w.sim and #cards or 20) do w.bag[#w.bag+1]=i end
  for i=#w.bag,2,-1 do
    local j=math.random(i)
    w.bag[i],w.bag[j]=w.bag[j],w.bag[i]
  end
  if #w.bag>1 and w.bag[#w.bag]==w.card then
    w.bag[1],w.bag[#w.bag]=w.bag[#w.bag],w.bag[1]
  end
end
local function act(w,n)
  w.focus=n
  if n==1 then
    if #w.bag==0 then refill(w) end
    w.card=table.remove(w.bag)
    w.dealt=w.dealt+1
    w.done=false
    w.note="Use on ground only."
  elseif n==2 then
    if w.card and not w.done then
      w.retries=w.retries+1
      w.note="Same card. Try again when safe."
    end
  elseif n==3 then
    if w.card and not w.done then
      w.done=true
      w.landed=w.landed+1
      w.note="Challenge complete!"
    end
  elseif n==4 then
    w.sim=not w.sim
    w.card=nil
    w.bag={}
    w.done=false
    w.note="Mode changed. Draw a new card."
  end
  lcd.invalidate()
end
local function rgb(r,g,b) lcd.color(lcd.RGB(r,g,b)) end
local function rect(x,y,w,h,r,g,b)
  if w>0 and h>0 then rgb(r,g,b); lcd.drawFilledRectangle(x,y,w,h) end
end
local function text(x,y,s,font,r,g,b)
  lcd.font(font); rgb(r,g,b); lcd.drawText(x,y,s)
end
local function center(x,y,w,s,font,r,g,b)
  lcd.font(font)
  local tw=lcd.getTextSize(s)
  text(x+math.floor((w-tw)/2),y,s,font,r,g,b)
end
local function wrap(s,maxw,font)
  lcd.font(font)
  local lines,line={},""
  for word in s:gmatch("%S+") do
    local candidate=line=="" and word or line.." "..word
    if line~="" and lcd.getTextSize(candidate)>maxw then
      lines[#lines+1]=line; line=word
    else line=candidate end
  end
  if line~="" then lines[#lines+1]=line end
  return lines
end
local function paint(w)
  local W,H=lcd.getWindowSize()
  w.buttons={}
  rect(0,0,W,H,13,19,23)
  local small=FONT_S or FONT_STD
  local normal=FONT_STD or small
  local big=FONT_L or normal
  if W<320 or H<230 then
    center(0,3,W,"SQ TRICK LOTTERY",small,232,199,128)
    center(0,25,W,"Use a full-screen layout",small,238,238,238)
    return
  end
  local p=math.max(8,math.floor(W*0.025))
  local bh=math.max(36,math.floor(H*0.14))
  local by=H-bh-p
  local footerY=by-24
  local cardY=52
  local cardH=footerY-cardY-5
  text(p,5,"SQUADDING QUADS  /  ETHOS 1.0",small,232,199,128)
  text(p,23,w.sim and "FIXED WING  |  SIMULATOR" or "FIXED WING  |  FIELD",normal,245,245,241)
  rect(p,cardY,W-2*p,cardH,30,39,45)
  rect(p,cardY,4,cardH,232,199,128)
  local c=w.card and cards[w.card]
  local label=c and ("CARD "..w.card.." / 25  |  "..(w.card>20 and "SIM ONLY" or "FIELD")) or "25 COLLECTIBLE CHALLENGES"
  text(p+12,cardY+6,label,small,232,199,128)
  local title=c and c[1] or "DRAW IT. FLY IT. OWN IT."
  lcd.font(big)
  local titleFont=lcd.getTextSize(title)>W-2*p-24 and normal or big
  lcd.font(titleFont)
  local _,th=lcd.getTextSize(title)
  th=th or 22
  text(p+12,cardY+25,title,titleFont,245,245,241)
  local desc=c and c[2] or "Draw a fixed-wing challenge. Select simulator mode to unlock five additional exercises."
  local bodyY=cardY+25+th+4
  local lines=wrap(desc,W-2*p-24,normal)
  lcd.font(normal)
  local _,lh=lcd.getTextSize("Ag")
  lh=(lh or 17)+2
  if bodyY+#lines*lh>footerY-10 then
    lines=wrap(desc,W-2*p-24,small)
    lcd.font(small); local _,sh=lcd.getTextSize("Ag"); lh=(sh or 14)+1
    for i,line in ipairs(lines) do text(p+12,bodyY+(i-1)*lh,line,small,224,228,228) end
  else
    for i,line in ipairs(lines) do text(p+12,bodyY+(i-1)*lh,line,normal,224,228,228) end
  end
  local py=bodyY+#lines*lh+3
  if c and py+17<footerY-5 then
    text(p+12,py,"Skill: "..c[4],small,180,190,194)
  end
  if w.done and py+36<footerY-5 then
    text(p+12,py+18,"COMPLETED",small,128,227,169)
  end
  text(p,footerY,string.format("Dealt %d  |  Landed %d  |  Retry %d",w.dealt,w.landed,w.retries),small,232,199,128)
  local bw=math.floor((W-2*p-3*5)/4)
  local labels={w.card and "Deal" or "Draw","Retry",w.done and "Done" or "Landed",w.sim and "Sim" or "Field"}
  for i=1,4 do
    local x=p+(i-1)*(bw+5)
    w.buttons[i]={x=x,y=by,w=bw,h=bh}
    local active=i==w.focus
    local disabled=(i==2 or i==3) and (not w.card or w.done)
    if active then rect(x,by,bw,bh,232,199,128)
    else rect(x,by,bw,bh,50,62,69) end
    if disabled then
      center(x,by+math.floor((bh-16)/2),bw,labels[i],small,112,120,125)
    elseif active then
      center(x,by+math.floor((bh-16)/2),bw,labels[i],normal,13,19,23)
    else
      center(x,by+math.floor((bh-16)/2),bw,labels[i],normal,245,245,241)
    end
  end
end
local function event(w,category,value,x,y)
  if #w.buttons==0 then return false end
  if category==EVT_TOUCH and value==TOUCH_END and x and y then
    for i,b in ipairs(w.buttons) do
      if x>=b.x and x<b.x+b.w and y>=b.y and y<b.y+b.h then
        act(w,i); return true
      end
    end
  elseif category==EVT_KEY then
    if value==KEY_ROTARY_RIGHT or (KEY_RIGHT_BREAK and value==KEY_RIGHT_BREAK) then
      w.focus=w.focus%4+1; lcd.invalidate(); return true
    elseif value==KEY_ROTARY_LEFT or (KEY_LEFT_BREAK and value==KEY_LEFT_BREAK) then
      w.focus=(w.focus+2)%4+1; lcd.invalidate(); return true
    elseif value==KEY_ENTER_BREAK then
      act(w,w.focus); return true
    end
  end
  return false
end
local function menu(w)
  return {
    {"Draw / Deal",function() act(w,1) end},
    {"Retry",function() act(w,2) end},
    {"Landed",function() act(w,3) end},
    {w.sim and "Switch to Field" or "Switch to Simulator",function() act(w,4) end}
  }
end
local function init()
  system.registerWidget({key="SQWing",name="SQ Trick Lottery",create=create,paint=paint,event=event,menu=menu,title=false})
end
return {init=init}
