-- Squadding Quads | Trick Lottery ETHOS 1.2 preview
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
local diagrams={{view="PLAN VIEW",label="Rectangular circuit",tracks={{{42,108},{34,106},{30,98},{30,38},{34,30},{42,28},{198,28},{206,30},{210,38},{210,98},{206,106},{198,108},{42,108}}}},{view="PLAN VIEW",label="Opposite-direction circuits",tracks={{{30,108},{22,106},{18,98},{18,40},{22,32},{30,30},{93,30},{101,32},{105,40},{105,98},{101,106},{93,108},{30,108}},{{147,108},{210,108},{218,106},{222,98},{222,40},{218,32},{210,30},{147,30},{139,32},{135,40},{135,98},{139,106},{147,108}}}},{view="SIDE VIEW",label="Ten seconds at constant height",tracks={{{22,66},{218,66}}},reference="horizon",note="10 SEC"},{view="PLAN VIEW",label="Matching figure-eight lobes",tracks={{{120,68},{132,79},{144,89},{155,97},{166,104},{175,108},{184,109},{192,108},{199,104},{204,97},{208,89},{210,79},{211,68},{210,57},{208,48},{204,39},{199,32},{192,28},{184,27},{175,28},{166,32},{155,39},{144,47},{132,57},{120,68},{108,79},{96,88},{85,97},{75,104},{65,108},{56,109},{48,108},{41,104},{36,97},{32,88},{30,79},{29,68},{30,57},{32,48},{36,39},{41,32},{48,28},{56,27},{65,28},{74,32},{85,39},{96,48},{108,57},{120,68}}}},{view="PLAN VIEW",label="Three alternating banks",tracks={{{20,68},{25,56},{30,46},{35,38},{40,32},{45,29},{50,28},{54,29},{59,32},{64,38},{69,46},{74,56},{79,68},{84,80},{89,91},{94,98},{99,104},{104,107},{109,109},{113,107},{118,104},{123,98},{128,91},{133,80},{138,68},{143,56},{148,46},{153,38},{158,32},{163,29},{168,28},{172,29},{177,32},{182,38},{187,46},{192,56},{197,68},{219,68}}}},{view="PLAN VIEW",label="Hold one heading",tracks={{{22,68},{218,68}}},note="10 SEC",reference="heading"},{view="PLAN VIEW",label="Parallel outbound and return legs",tracks={{{25,40},{176,40},{189,41},{199,44},{208,49},{213,55},{217,62},{218,69},{217,76},{213,83},{208,89},{199,94},{189,97},{176,98},{25,98}}}},{view="SIDE VIEW",label="Gentle climb, then level",tracks={{{20,100},{55,100},{64,99},{72,96},{79,91},{87,85},{94,78},{102,71},{109,64},{117,57},{124,51},{133,46},{141,43},{150,42},{220,42}}},reference="horizon"},{view="SIDE VIEW",label="Gentle descent, then level",tracks={{{20,36},{55,36},{64,37},{72,40},{80,44},{88,49},{96,55},{104,62},{112,68},{120,74},{129,79},{137,83},{146,86},{155,87},{220,87}}},reference="ground"},{view="SIDE VIEW",label="Change speed, not altitude",tracks={{{20,66},{220,66}}},reference="horizon",note="SLOWER / FASTER",speed=true},{view="PLAN VIEW",label="Circuit in suitable wind",tracks={{{42,108},{34,106},{30,98},{30,40},{34,32},{42,30},{198,30},{206,32},{210,40},{210,98},{206,106},{198,108},{42,108}}},wind=true},{view="PLAN VIEW",label="Straight track in crosswind",tracks={{{22,72},{218,72}}},wind=true,crab=true},{view="SIDE VIEW",label="Reduced-power glide",tracks={{{20,35},{35,39},{50,43},{66,48},{83,52},{100,58},{117,63},{134,68},{152,73},{169,78},{187,83},{203,88},{220,92}}},reference="ground"},{view="PLAN VIEW",label="Circuit to approach heading",tracks={{{35,95},{35,39},{36,34},{40,29},{46,26},{53,24},{61,22},{69,22},{77,22},{85,24},{92,26},{98,29},{102,34},{103,39},{103,65},{104,72},{105,78},{107,82},{110,86},{114,89},{118,91},{123,93},{128,94},{133,95},{139,95},{144,95},{150,95},{220,95}}},runway=true},{view="SIDE VIEW",label="Approach, then climb away",tracks={{{20,36},{27,40},{35,45},{42,50},{50,55},{57,61},{65,66},{72,71},{80,76},{87,80},{95,83},{102,85},{110,86},{119,85},{128,83},{136,79},{145,74},{153,68},{162,62},{171,55},{180,48},{189,42},{199,35},{209,30},{220,25}}},reference="ground"},{view="SIDE VIEW",label="Approach and touchdown",tracks={{{20,30},{33,35},{46,41},{58,48},{70,56},{82,64},{94,72},{106,80},{118,87},{130,94},{143,99},{156,102},{170,103},{220,103}}},reference="ground",runway=true},{view="SIDE VIEW",label="Two separate landing passes",tracks={{{18,31},{24,35},{30,39},{35,43},{40,47},{46,50},{51,54},{57,58},{63,61},{69,63},{76,65},{84,67},{93,67},{111,67}},{{129,31},{135,35},{141,39},{146,43},{151,47},{157,50},{162,54},{168,58},{174,61},{180,63},{187,65},{195,67},{204,67},{222,67}}},reference="ground",runway=true,note="1 / 2"},{view="PLAN VIEW",label="Steady filming pass",tracks={{{22,62},{218,62}}},reference="camera"},{view="PLAN VIEW",label="Equal left and right turns",tracks={{{22,68},{28,57},{34,48},{40,41},{47,36},{55,33},{63,32},{71,33},{80,36},{89,41},{99,48},{109,57},{120,68},{131,79},{141,88},{151,95},{160,100},{169,103},{177,104},{185,103},{193,100},{200,95},{206,88},{212,79},{218,68}}}},{view="REVIEW VIEW",label="Review speed changes after landing",tracks={{{22,90},{53,90},{82,66},{112,66},{144,46},{176,46},{218,58}}},chart=true,note="SPEED TRACE / EXAMPLE"},{view="SIDE VIEW",label="Simulator low-level speed pass",tracks={{{22,92},{218,92}}},reference="ground",note="> 50 KM/H"},{view="ATTITUDE VIEW",label="Axial roll about a straight flight line",tracks={{{22,68},{218,68}}},roll=true},{view="SIDE VIEW",label="Full vertical loop",tracks={{{18,108},{120,108},{127,107},{133,106},{139,103},{145,100},{150,96},{154,91},{157,85},{160,79},{161,73},{162,66},{161,59},{160,53},{157,47},{154,41},{150,36},{145,32},{139,29},{133,26},{127,25},{120,24},{113,25},{107,26},{101,29},{95,32},{90,36},{86,41},{83,47},{80,53},{79,59},{78,66},{79,73},{80,79},{83,85},{86,91},{90,96},{95,100},{101,103},{107,106},{113,107},{120,108},{222,108}}},reference="horizon"},{view="SIDE VIEW",label="Half Cuban eight: loop and diagonal exit",tracks={{{18,108},{105,108},{111,108},{116,107},{122,105},{127,102},{132,99},{136,95},{140,91},{143,86},{146,81},{148,75},{149,70},{149,64},{149,58},{148,53},{146,47},{143,42},{140,37},{136,33},{132,29},{127,26},{122,23},{116,21},{111,20},{105,20},{99,20},{94,21},{88,23},{83,26},{78,29},{74,33},{22,85}}},halfroll=true},{view="REVIEW VIEW",label="Slow-flight speed envelope",tracks={{{20,40},{65,47},{110,69},{145,88},{175,61},{220,45}}},chart=true,note="RECOVER / EXAMPLE"}}
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
local function flightPlate(id,x,y,W,H)
  if W<82 or H<48 or not lcd.drawLine then return end
  local d=diagrams[id or 1]
  local scale=math.min((W-8)/240,(H-8)/145)
  local ox=x+math.floor((W-240*scale)/2)
  local oy=y+math.floor((H-145*scale)/2)
  local function pt(a,b) return math.floor(ox+a*scale+0.5),math.floor(oy+b*scale+0.5) end
  local function seg(a,b,c,e)
    local ax,ay=pt(a,b); local bx,by=pt(c,e)
    lcd.drawLine(ax,ay,bx,by)
  end
  rect(x,y,W,H,16,28,35)
  rgb(44,62,70)
  for j=25,105,20 do seg(15,j,225,j) end
  for j=40,200,40 do seg(j,12,j,125) end
  rgb(102,125,131)
  if d.reference=="ground" or d.reference=="horizon" then seg(14,116,226,116) end
  if d.chart then seg(15,16,15,111);seg(15,111,225,111) end
  if d.runway then
    local yy=d.view=="SIDE VIEW" and 108 or 93
    seg(153,yy,225,yy);seg(153,yy+4,225,yy+4)
  end
  if d.wind then
    for _,xx in ipairs({50,120,190}) do seg(xx,10,xx,25);seg(xx-4,20,xx,25);seg(xx+4,20,xx,25) end
  end
  if id and id>20 then rgb(232,199,128) else rgb(139,216,227) end
  for _,track in ipairs(d.tracks) do
    for j=2,#track do
      local a,b=track[j-1],track[j];seg(a[1],a[2],b[1],b[2])
    end
    local k=math.max(2,math.floor(#track*0.55));local a,b=track[k-1],track[k]
    local dx,dy=b[1]-a[1],b[2]-a[2];local len=math.sqrt(dx*dx+dy*dy)
    if len>0 then
      dx,dy=dx/len,dy/len
      local xx,yy=(a[1]+b[1])/2,(a[2]+b[2])/2
      seg(xx,yy,xx-dx*9-dy*5,yy-dy*9+dx*5)
      seg(xx,yy,xx-dx*9+dy*5,yy-dy*9-dx*5)
    end
  end
  rgb(230,239,241)
  if d.roll then
    for j=0,3 do
      local xx=47+j*49
      if j%2==0 then seg(xx-13,68,xx+13,68);seg(xx,63,xx,73)
      else seg(xx,55,xx,81);seg(xx-5,68,xx+5,68) end
    end
  elseif not d.chart then
    local track=d.tracks[1];local k=math.max(2,math.floor(#track*0.72));local a,b=track[k-1],track[k]
    local dx,dy=b[1]-a[1],b[2]-a[2];local len=math.sqrt(dx*dx+dy*dy)
    if len>0 then
      dx,dy=dx/len,dy/len
      if d.crab then local u,v=dx,dy;dx=u*0.94+v*0.342;dy=v*0.94-u*0.342 end
      local xx,yy=(a[1]+b[1])/2,(a[2]+b[2])/2
      local outline=d.view=="SIDE VIEW" and {{-14,0},{-10,-3},{-3,-3},{2,-7},{6,-6},{8,-3},{14,-1},{15,1},{12,3},{-8,3},{-13,5},{-14,0}} or {{16,0},{9,-3},{4,-3},{-2,-15},{-5,-15},{-3,-3},{-11,-2},{-14,-7},{-16,-7},{-14,0},{-16,7},{-14,7},{-11,2},{-3,3},{-5,15},{-2,15},{4,3},{9,3},{16,0}}
      local function localpt(p) return xx+dx*p[1]-dy*p[2],yy+dy*p[1]+dx*p[2] end
      for j=2,#outline do local ax,ay=localpt(outline[j-1]);local bx,by=localpt(outline[j]);seg(ax,ay,bx,by) end
      local ax,ay=localpt({-10,0});local bx,by=localpt({9,0});seg(ax,ay,bx,by)
    end
  end
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
  text(p,5,"SQUADDING QUADS  /  ETHOS 1.2",small,232,199,128)
  text(p,23,w.sim and "FIXED WING  |  SIMULATOR" or "FIXED WING  |  FIELD",normal,245,245,241)
  rect(p,cardY,W-2*p,cardH,30,39,45)
  if w.card and w.card>20 then rect(p,cardY,4,cardH,232,199,128) else rect(p,cardY,4,cardH,139,216,227) end
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
  local bottom=footerY-7
  local fullW=W-2*p-24
  local usePlate=W>=420 and bottom-bodyY>=55 and lcd.drawLine
  local plateW=usePlate and math.floor(fullW*0.43) or 0
  local bodyW=usePlate and fullW-plateW-10 or fullW
  local font=normal
  local lines=wrap(desc,bodyW,font)
  lcd.font(font);local _,lh=lcd.getTextSize("Ag");lh=(lh or 17)+2
  if bodyY+#lines*lh>bottom then
    font=small;lines=wrap(desc,bodyW,font)
    lcd.font(font);local _,sh=lcd.getTextSize("Ag");lh=(sh or 14)+1
  end
  if usePlate and bodyY+#lines*lh>bottom then
    usePlate=false;bodyW=fullW;lines=wrap(desc,bodyW,font)
  end
  for i,line in ipairs(lines) do text(p+12,bodyY+(i-1)*lh,line,font,224,228,228) end
  local py=bodyY+#lines*lh+3
  if usePlate then
    flightPlate(w.card,p+12+bodyW+10,bodyY,plateW,bottom-bodyY)
  elseif bottom-py>=57 and lcd.drawLine then
    local pw=math.min(fullW,math.floor((bottom-py)*1.65))
    flightPlate(w.card,p+12,py,pw,bottom-py)
    py=bottom
  end
  if c and py+17<bottom then text(p+12,py,"Skill: "..c[4],small,180,190,194) end
  if w.done and py+36<bottom then text(p+12,py+18,"COMPLETED",small,128,227,169) end
  text(p,footerY,string.format("Dealt %d  |  Landed %d  |  Retry %d",w.dealt,w.landed,w.retries),small,232,199,128)
  local bw=math.floor((W-2*p-3*5)/4)
  local labels={w.card and "Deal" or "Draw","Retry",w.done and "Done" or "Landed",w.sim and "Sim" or "Field"}
  for i=1,4 do
    local x=p+(i-1)*(bw+5)
    w.buttons[i]={x=x,y=by,w=bw,h=bh}
    local active=i==w.focus
    local disabled=(i==2 or i==3) and (not w.card or w.done)
    if active then rect(x,by,bw,bh,139,216,227)
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
