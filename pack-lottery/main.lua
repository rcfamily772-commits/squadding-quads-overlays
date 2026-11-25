-- Squadding Quads | The Trick Lottery | preview 2.5
local levels={"Beginner","Intermediate","Advanced","OnlyDrones","Bench Pilot","Adults Only","Fixed Wing"}
local decks={
{
{"Figure of eight","Circle two markers in an eight. Cross the middle at the same height on both passes.","Cinematic","Basic control","eight"},
{"Park it","Pick a landing patch before take-off. Touch down inside it three times this pack.","TinyWhoop","Basic control","s"},
{"The slow lap","Fly a wide lap at walking pace. Keep your height steady through all four turns.","Cinematic","Basic control","s"},
{"Both ways round","Orbit a marker once each way. Keep it in the same part of your picture.","Cinematic","Basic control","s"},
{"Hold the horizon","Fly a straight out-and-back. Aim for the same horizon height on both legs.","Cinematic","Basic control","s"},
{"Square deal","Pick four corners in open space. Fly the square twice and match your turning points.","TinyWhoop","Basic control","s"},
{"Smooth departure","Lift off, pause at a hover, then ease into forward flight without dipping.","TinyWhoop","Basic control","s"},
{"Throttle steps","Fly a straight line at three speeds. Keep the same height as you change pace.","Cinematic","Basic control","s"},
{"Gentle S-turn","Make three wide alternating turns at constant height.","Cinematic","Steady turns","s"},
{"Precision hover","Hold a hover for five seconds, then move away smoothly.","TinyWhoop","Stable hover","hover"},
{"Soft landing","Make two gentle touchdowns on a clear patch.","TinyWhoop","Controlled descent","land"},
{"Wide rectangle","Fly four straight sides with matching corners.","Cinematic","Level flight","square"},
{"Yaw practice","At safe height turn smoothly through 180 degrees and settle.","TinyWhoop","Hover","orbit"},
{"Slow reveal","Ease sideways to reveal a distant landmark in open space.","Cinematic","Sideways flight","s"},
{"Stop and go","Alternate smooth forward flight and controlled stops.","TinyWhoop","Throttle control","line"},
{"Altitude ladder","Climb, hold and descend gently in open space.","Cinematic","Throttle control","line"},
{"Equal arcs","Fly two broad arcs of equal size.","Cinematic","Coordinated turns","s"},
{"Heading hold","Fly straight past two distant reference points.","Cinematic","Level flight","line"},
{"Clean approach","Approach a clear landing area slowly and steadily.","TinyWhoop","Landing","land"},
{"Box hover","Pause at each corner of a large imaginary square.","TinyWhoop","Hover","square"},
{"Long lens line","Hold a smooth camera line without sudden yaw.","Cinematic","Level flight","line"},
{"Gentle slalom","Weave around imaginary points with generous clearance.","TinyWhoop","Steady turns","s"}
},
{
{"Mirror rolls","At recovery height, roll left, then right. Finish each roll on your original heading.","Freestyle","Beginner skills","roll"},
{"Exit on cue","Choose a distant landmark. Fly a wide orbit and exit pointing straight at it.","Cinematic","Beginner skills","s"},
{"The camera pass","Frame one marker for half an orbit. Keep its size constant throughout the shot.","Cinematic","Beginner skills","s"},
{"Flat eight","Fly three figure eights. Match both loops for size and cross at the same point.","TinyWhoop","Beginner skills","eight"},
{"Brake on a mark","Fly towards an imaginary line. Ease to a hover over it without overshooting.","TinyWhoop","Beginner skills","s"},
{"Split-S exit","In open space with recovery height, fly a split-S and exit parallel to your entry line.","Freestyle","Beginner skills","s"},
{"Reverse the reel","Fly a three-turn line, then fly its mirror image. Compare the rhythms on DVR.","Freestyle","Beginner skills","s"},
{"Clean loop","Fly a free-space power loop. Pick a reference on the horizon and recover facing it.","Freestyle","Beginner skills","loop"},
{"Single roll","Perform one axial roll at ample recovery height.","Freestyle","Mirror rolls","roll"},
{"Front flip","Perform one front flip in open sky at recovery height.","Freestyle","Throttle control","loop"},
{"Backflip","Perform one backflip in open sky and recover level.","Freestyle","Front flip","loop"},
{"Half Cuban","Practise a half Cuban eight in a simulator.","Simulator","Clean loop","loop"},
{"Orbit switch","Reverse orbit direction smoothly around a distant reference.","Cinematic","Both ways round","orbit"},
{"Roll on exit","Exit a wide turn with one roll at safe height.","Freestyle","Single roll","roll"},
{"Banked S","Link two broad banked turns with matching exits.","Cinematic","Gentle S-turn","s"},
{"Precision eight","Match two figure-eight crossings at safe height.","TinyWhoop","Figure of eight","eight"},
{"Loop and hold","Fly a free-space loop, then settle into level flight.","Freestyle","Clean loop","loop"},
{"Rewind practice","In a simulator, reverse a short freestyle sequence.","Simulator","Reverse the reel","s"},
{"Smooth dive recovery","In a simulator, practise a shallow descent and smooth recovery.","Simulator","Throttle steps","land"},
{"Orbit reveal","Make a wide orbit and smoothly reveal a distant landmark.","Cinematic","The camera pass","orbit"},
{"Roll symmetry","Match the duration of left and right rolls at recovery height.","Freestyle","Mirror rolls","roll"}
},
{
{"The SQ combo","Link a split-S to a power loop in open sky. Keep the transition free of extra rolls.","Freestyle","Intermediate skills","s"},
{"Juicy flick","Use a horizon reference for one juicy flick. Repeat it and match the exit heading.","Freestyle","Intermediate skills","s"},
{"BoyWonder mirror","Build a three-trick line. Reverse every roll direction on the second run.","Freestyle","Intermediate skills","s"},
{"Rolling exit","Exit a wide orbit into one smooth roll. Finish on the tangent you chose beforehand.","Freestyle","Intermediate skills","roll"},
{"Same sky twice","Fly two free-space loops in succession. Match the apex height and exit heading.","Freestyle","Intermediate skills","s"},
{"Pause the roll","At recovery height, fly a four-point roll. Make the pauses equal on your DVR.","Freestyle","Intermediate skills","roll"},
{"One-take line","Combine an orbit, a roll and a loop in one shot. Give each move a deliberate exit.","Freestyle","Intermediate skills","s"},
{"The other hand","Choose your strongest freestyle line. Fly its mirror twice with the same timing.","Freestyle","Intermediate skills","s"},
{"Matty flip","Practise a Matty flip in a simulator with generous recovery space.","Simulator","Clean loop and backflip","loop"},
{"Trippy spin","Practise a trippy spin around a virtual reference in a simulator.","Simulator","Orbit and inverted control","orbit"},
{"Inverted yaw","Practise inverted yaw and recovery in a simulator.","Simulator","Inverted recovery","roll"},
{"Rewind combo","Reverse a two-move freestyle line in a simulator.","Simulator","Rewind practice","s"},
{"Double juicy","Link two juicy flicks in open sky with recovery height.","Freestyle","Juicy flick","s"},
{"Roll-loop combo","Link an axial roll and free-space loop with a stable exit.","Freestyle","Single roll and clean loop","loop"},
{"Rubik practice","Practise a Rubik-style rotation in a simulator.","Simulator","Multi-axis control","roll"},
{"Yaw spin","Practise a controlled yaw spin and stable exit in a simulator.","Simulator","Yaw control","orbit"},
{"Three-axis flow","Build a three-axis sequence in a simulator; prioritise clean recovery.","Simulator","Multi-axis control","s"},
{"Mirrored juicy","Repeat a juicy flick with mirrored roll direction in open sky.","Freestyle","Juicy flick","s"},
{"One-shot reveal","Combine a broad orbit and gentle reveal without abrupt movement.","Cinematic","Orbit reveal","orbit"},
{"Micro precision","Fly a repeatable imaginary-gate line in clear space.","TinyWhoop","Precision eight","eight"},
{"SQ master line","Link three mastered tricks in a simulator, then review DVR.","Simulator","One-take line","s"}
},
{
{"Just Fly","Come on, please fly. Pretty please?","Any","Pre-flight checks","s"},
{"Just Fly","Squadding Quads will beat you... in the pack tally if you don't fly!","Any","Pre-flight checks","s"},
{"Just Fly","Does the day end with a Y? Then fly!","Any","Pre-flight checks","s"},
{"Just Fly","Your batteries didn't charge themselves for a day on the sofa.","Any","Pre-flight checks","s"},
{"Just Fly","Less scrolling, more rolling.","Any","Pre-flight checks","s"},
{"Just Fly","The Angry Karen can wait. If it's safe to fly, get a pack in!","Any","Pre-flight checks","s"},
{"Just Fly","BoyWonder has probably flown three packs already. Just saying.","Any","Pre-flight checks","s"},
{"Just Fly","Your drone is not a particularly expensive paperweight.","Any","Pre-flight checks","s"},
{"Just Fly","No tricks. No pressure. Just you and the sticks.","Any","Pre-flight checks","s"},
{"Just Fly","One... More... Pack...!","Any","Pre-flight checks","s"},
{"Just Fly","We don't fly spreadsheets. Get those props turning!","Any","Pre-flight checks","s"},
{"Just Fly","The only challenge today is to enjoy yourself. Go fly when it's safe.","Any","Pre-flight checks","s"}
},
{
{"Touch Grass & Fly","Betaflight ain't gonna fly for you. Unplug it and touch grass!","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","I know the bench in the shed is warm, but you're a pilot. Fly the bloody drone!","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","You've tuned it more times than you've flown it. Get outside!","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","Breaking news: grass exists outside your shed.","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","Your soldering iron has more hours on it than your goggles.","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","Another PID tune? Mate, the problem might be holding the controller.","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","Your quad has the latest firmware. Your flying skills are still on factory settings.","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","Blackbox analysis requires you to actually fly the drone first.","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","That USB cable isn't a flight accessory. Unplug it!","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","The Angry Karen has reported you missing. Apparently you're still in the shed.","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","You've built a flying machine, not a bloody museum exhibit.","Any","Pre-flight checks","s"},
{"Touch Grass & Fly","Less bench testing. More field testing. We don't fly spreadsheets!","Any","Pre-flight checks","s"}
},
{
{"Fucking Fly It","You paid for it. Fucking fly it!","Any","Pre-flight checks","s"},
{"Fucking Fly It","Stop pissing about and get the bastard airborne.","Any","Pre-flight checks","s"},
{"Fucking Fly It","All the gear and fuck all flight time. Sort it out!","Any","Pre-flight checks","s"},
{"Fucking Fly It","Your thumbs aren't ornamental, you absolute weapon.","Any","Pre-flight checks","s"},
{"Fucking Fly It","That drone cost £400. It's doing a magnificent impression of a fucking paperweight.","Any","Pre-flight checks","s"},
{"Fucking Fly It","Nobody gives a shit about your PID tune if you never fly.","Any","Pre-flight checks","s"},
{"Fucking Fly It","Another fucking firmware update? Have you considered flying?","Any","Pre-flight checks","s"},
{"Fucking Fly It","Get off your arse. Those batteries aren't going to discharge themselves.","Any","Pre-flight checks","s"},
{"Fucking Fly It","You call yourself a pilot? Prove it, you magnificent bastard.","Any","Pre-flight checks","s"},
{"Fucking Fly It","Stop watching Squadding Quads and go fly your own fucking drone!","Any","Pre-flight checks","s"},
{"Fucking Fly It","You've spent more time arguing about radios than using the bloody things.","Any","Pre-flight checks","s"},
{"Fucking Fly It","Fuck perfection. Fuck the excuses. Enjoy yourself and fly the bastard!","Any","Pre-flight checks","s"}
},
{
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
}

local rgb=lcd.RGB
local ink,panel,gold,paper,white,muted=rgb(13,15,17),rgb(30,31,32),rgb(224,191,124),rgb(248,242,225),rgb(247,244,232),rgb(120,125,128)
local accents={rgb(37,108,72),rgb(26,92,146),rgb(122,65,155),rgb(160,50,110),rgb(113,94,48),rgb(167,35,47),rgb(35,115,130)}
local foil={paper,rgb(218,229,239),rgb(248,217,140),rgb(225,211,250),rgb(255,226,125)}
local edge={gold,rgb(129,158,185),rgb(160,112,25),rgb(126,70,181),rgb(211,147,20)}
local rarity={"STD","RARE","LEG","MYTH","GOLD"}
local codes={"BG","IN","AD","OD","BP","18","FW"}
local floor,min,max=math.floor,math.min,math.max
local modes={"Real World","Simulator","TinyWhoop","Freestyle","Cinematic","Fixed Wing"}
local options={{"SFX",BOOL,0},{"Motion",BOOL,1},{"Haptic",BOOL,0},{"Mode",VALUE,1,1,6},{"Theme",VALUE,1,1,6}}
local function on(o,k,default) if not o or o[k]==nil then return default end return o[k]==1 or o[k]==true end
local function update(w,o) local m=max(1,min(6,tonumber(o and o.Mode) or 1));if w.mode and w.mode~=m then w.bags={{},{},{},{},{},{},{}};w.card=nil;w.view=0;w.focus=1;w.dealAt=nil;w.message=nil;w.unbox=true end;w.mode=m;w.theme=max(1,min(6,tonumber(o and o.Theme) or 1));w.sound=on(o,"SFX",false);w.motion=on(o,"Motion",true);w.haptic=on(o,"Haptic",false) end
local function signal(w,t)
  if w.sound and type(playTone)=="function" then pcall(playTone,t,65,0,0) end
  if w.haptic and type(playHaptic)=="function" then pcall(playHaptic,30,0,0) end
end
-- Compact two-slot collection. Each slot is validated before use; interrupted
-- writes leave the other slot intact. Only explicit draws and completions write.
local paths={"/WIDGETS/SQLotto/trick-a.txt","/WIDGETS/SQLotto/trick-b.txt"}
local legacy={"/WIDGETS/SQLotto/album-a.txt","/WIDGETS/SQLotto/album-b.txt"}
local function checksum(s)
  local c=0
  for i=1,#s do c=(c*31+string.byte(s,i))%65521 end
  return c
end
local function empty()
  return {seq=0,marks=string.rep("0",125),wins={0,0,0,0,0,0,0},draws=0,slot=2}
end
local function decode(s,slot)
  if type(s)~="string" then return end
  local body,check=string.match(s,"^(SQ[12][058]|[^\n]+)\n(%d+)\n$")
  if not body or checksum(body)~=tonumber(check) then return end
  local ver,seq,marks,counts,draws=string.match(body,"^(SQ[12][058])|(%d+)|([0-5]+)|([%d,]+)|(%d+)$")
  if not seq then return end
  local wins={};for n in string.gmatch(counts,"%d+") do wins[#wins+1]=tonumber(n) end
  if table.concat(wins,",")~=counts then return end
  if ver=="SQ25" then if #marks~=125 or #wins~=7 then return end
  else if (#marks~=60 and #marks~=100) or #wins~=6 then return end;marks=marks..string.rep("0",125-#marks);wins[7]=0 end
  local v={seq=tonumber(seq),marks=marks,wins=wins,draws=tonumber(draws),slot=slot}
  if v.seq>999999999 or v.draws>999999999 then return end
  for _,x in ipairs(v.wins) do if x>999999999 then return end end
  return v
end
local function readSlot(slot,old)
  if not io or not io.open then return end
  local ok,s=pcall(function()
    local f=io.open((old and legacy or paths)[slot],"r");if not f then return end
    local r=io.read(f,350);io.close(f);return r
  end)
  if ok then return decode(s,slot) end
end
local function newest()
  local a,b=readSlot(1),readSlot(2)
  if a and b then return a.seq>=b.seq and a or b end
  if a or b then return a or b end
  a,b=readSlot(1,true),readSlot(2,true)
  if a and b then return a.seq>=b.seq and a or b end
  return a or b
end
local function save(w)
  local d=w.album
  local slot=3-d.slot
  local body="SQ25|"..d.seq.."|"..d.marks.."|"..table.concat(d.wins,",").."|"..d.draws
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
  if l==7 then return 100+c end
  if l<=3 and c>8 then return 60+({0,14,27})[l]+c-8 end
  return ({0,8,16,24,36,48})[l]+c
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
    local old=tonumber(string.sub(d.marks,i,i)) or 0
    if w.rarity>old then d.marks=string.sub(d.marks,1,i-1)..w.rarity..string.sub(d.marks,i+1) end
  end
  save(w)
end
local function summary(d)
  local total,found=0,0
  for _,x in ipairs(d.wins) do total=total+x end
  for i=1,125 do if string.sub(d.marks,i,i)~="0" then found=found+1 end end
  local originals=true;for i=1,60 do if string.sub(d.marks,i,i)=="0" then originals=false end end
  local awards={d.wins[5]>=1,d.wins[3]>=10,d.wins[6]>=10,total>=25,total>=50,total>=100,originals,total>=500,total>=1000}
  local a=0;for _,x in ipairs(awards) do if x then a=a+1 end end
  local xp=total*25
  local rank=xp>=3000 and "FPV LEGEND" or xp>=1500 and "ELITE PILOT" or xp>=750 and "BANDO SPECIALIST" or xp>=250 and "FREESTYLER" or "ROOKIE"
  return total,found,a,rank,awards
end
local function create(zone,o)
  local w={zone=zone,level=1,bags={{},{},{},{},{},{},{}},last={},focus=1,seed=getTime()%65536,attempts=0,session=0,album=newest() or empty(),view=0,unbox=true}
  update(w,o);return w
end
local function rng(w)
  w.seed=(25173*w.seed+13849)%65536
  return w.seed/65536
end
local function eligible(w,l,c)
  local tag=decks[l][c][3]
  if l==7 then return w.mode==2 or (tag=="Fixed Wing" and (w.mode==1 or w.mode==6)) end
  return w.mode==2 or tag=="Any" or (w.mode==1 and tag~="Simulator") or tag==modes[w.mode]
end
local function draw(w)
  local bag=w.bags[w.level]
  if #bag==0 then
    w.seed=(w.seed+getTime())%65536
    for i=1,#decks[w.level] do if eligible(w,w.level,i) then bag[#bag+1]=i end end
    if #bag==0 then w.message="No cards in this mode. Choose another deck.";return end
    for i=#bag,2,-1 do local j=1+floor(rng(w)*i);bag[i],bag[j]=bag[j],bag[i] end
    if bag[#bag]==w.last[w.level] then bag[1],bag[#bag]=bag[#bag],bag[1] end
  end
  w.card=table.remove(bag);w.last[w.level]=w.card
  local r=rng(w);w.rarity=r<.002 and 5 or r<.01 and 4 or r<.10 and 3 or r<.30 and 2 or 1
  w.attempts=1;w.message=nil
  record(w,false)
  w.duration=w.unbox and 42 or 24;w.unbox=false
  w.dealAt=w.motion and getTime() or nil
  signal(w,w.rarity>=3 and 1320 or 880)
end
local function actions(w)
  if w.view==5 then return {"Back","Daily","Weekly","Battle"} end
  if w.view==4 then return {"Back"} end
  if w.view>0 then return {"Back","Next"} end
  if w.card then return {"Landed","Retry","Deal","Deck","Stats","Info"} end
  return {"Draw","Deck","Stats","Play","Mode","Theme"}
end
local function choose(w,a)
  if a=="Mode" then
    update(w,{Mode=w.mode%6+1,Theme=w.theme,SFX=w.sound,Motion=w.motion,Haptic=w.haptic});w.focus=1
  elseif a=="Theme" then w.theme=w.theme%6+1;w.focus=1
  elseif a=="Info" then w.view=4;w.focus=1
  elseif a=="Play" then w.view=5;w.focus=1
  elseif a=="Back" then w.view=0;w.focus=1
  elseif a=="Battle" then w.battle=not w.battle;w.pilot=1;w.scores={0,0};w.view=0;w.focus=1
  elseif a=="Daily" or a=="Weekly" then
    local dt=type(getDateTime)=="function" and getDateTime() or nil
    if not dt or not dt.year or not dt.mon or not dt.day then w.message="Radio clock unavailable";w.view=0;w.focus=1;return end
    local y,m,d=dt.year,dt.mon,dt.day;if m<3 then y=y-1;m=m+12 end
    local day=365*y+floor(y/4)-floor(y/100)+floor(y/400)+floor((153*(m-3)+2)/5)+d-719469
    local seed=a=="Weekly" and floor((day+3)/7) or day
    local pool={};if w.mode==6 then for c=1,#decks[7] do if eligible(w,7,c) then pool[#pool+1]={7,c} end end else for l=1,2 do for c=1,#decks[l] do if decks[l][c][3]~="Simulator" then pool[#pool+1]={l,c} end end end end
    local v=pool[(seed*7919+17)%#pool+1];if not eligible(w,v[1],v[2]) then w.message="Choose Real World or Simulator mode";w.view=0;w.focus=1;return end
    w.level=v[1];w.card=v[2];w.rarity=1;w.attempts=1;w.view=0;w.focus=1;w.message=nil;record(w,false)
  elseif a=="Next" then w.view=w.view%3+1;w.focus=2
  elseif a=="Stats" then local d=newest();if d and d.seq>w.album.seq then w.album=d end;w.view=1;w.focus=1
  elseif a=="Deck" then w.level=w.level%7+1;w.card=nil;w.message=nil;w.focus=1;w.unbox=true;signal(w,660)
  elseif a=="Retry" and w.card then w.attempts=w.attempts+1;signal(w,450)
  elseif a=="Landed" and w.card then record(w,true);if w.battle then w.scores[w.pilot]=w.scores[w.pilot]+1;w.pilot=3-w.pilot end;w.session=w.session+1;w.card=nil;w.message="Challenge completed.";w.focus=1;signal(w,1050)
  elseif a=="Draw" or a=="Deal" then draw(w) end
end
-- Preserve the action identity across changing button rows, not the index.
local function perform(w,a)
  if not a then return end
  local previousView=w.view
  if previousView==0 and (a=="Stats" or a=="Info" or a=="Play") then
    w.returnAction=a
  end
  choose(w,a)
  local target=a
  if a=="Draw" or a=="Deal" then target=w.card and "Deal" or "Draw"
  elseif a=="Landed" then target="Draw"
  elseif a=="Back" then target=w.returnAction or "Draw";w.returnAction=nil
  elseif previousView==0 and w.view>0 then
    target="Back"
  elseif a=="Daily" or a=="Weekly" or a=="Battle" then
    target=w.card and "Deal" or "Play"
  end
  local row=actions(w)
  for i,name in ipairs(row) do if name==target then w.focus=i;return end end
  -- Never default to Landed when a card is active.
  for i,name in ipairs(row) do if name=="Deal" or name=="Draw" or name=="Back" then w.focus=i;return end end
  w.focus=1
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
  local W,H=w.zone.w,w.zone.h
  if W<1 or H<1 then return end
  lcd.drawFilledRectangle(0,0,W,H,ink)
  if W<40 or H<18 then return end
  local total,found,a,rank=summary(w.album)
  lcd.drawFilledRectangle(0,0,3,H,gold)
  if W<230 or H<145 then
    textFit(8,3,W>=130 and "SQ / TRICK LOTTERY" or "SQ TRICK",SMLSIZE,W-12)
    if H>=40 then textFit(8,22,"PRESS & HOLD",SMLSIZE,W-14) end
    if H>=66 then textFit(8,42,"Choose Full screen",SMLSIZE,W-14) end
    if H>=90 then textFit(8,62,found.."/125 | "..a.."/9 awards",SMLSIZE,W-14) end
    return
  end
  local cx=floor(W/2)
  lcd.drawRectangle(5,3,W-10,H-6,gold)
  lcd.drawText(12,8,"SQ / BLACK LABEL",SMLSIZE+gold)
  lcd.drawText(W-12,8,"V2.5",RIGHT+SMLSIZE+gold)
  local top=27
  local bottom=H-55
  local ph=bottom-top
  lcd.drawFilledRectangle(11,top,W-22,ph,panel)
  lcd.drawRectangle(11,top,W-22,ph,gold)
  if ph>=125 then
    emblem(cx,top+23,15,gold)
    lcd.drawText(cx,top+44,"THE TRICK LOTTERY",CENTER+MIDSIZE+white)
    lcd.drawText(cx,top+72,"DRAW IT. FLY IT. OWN IT.",CENTER+SMLSIZE+muted)
    lcd.drawFilledRectangle(20,bottom-40,W-40,30,gold)
    lcd.drawText(cx,bottom-34,"PRESS & HOLD TO PLAY",CENTER+SMLSIZE+ink)
  else
    lcd.drawText(cx,top+6,"THE TRICK LOTTERY",CENTER+SMLSIZE+white)
    lcd.drawText(cx,top+26,"PRESS & HOLD TO PLAY",CENTER+SMLSIZE+gold)
  end
  lcd.drawText(cx,bottom+3,"Choose Full screen",CENTER+SMLSIZE+gold)
  local fy=H-32
  local status=rank.." | "..found.."/125 | "..a.."/9 awards"
  if lcd.sizeText(status,SMLSIZE)>W-24 then status=found.."/125 cards | "..a.."/9 awards" end
  lcd.drawText(cx,fy,status,CENTER+SMLSIZE+white)
  lcd.drawFilledRectangle(13,H-10,W-26,3,muted)
  if found>0 then lcd.drawFilledRectangle(13,H-10,floor((W-26)*found/125),3,gold) end
end
local awardNames={"Shed Escapee","BoyWonder Approved","Absolutely Unhinged","Angry Karen Survivor","Touch Grass Pro","One More Pack","The Collector","No Spreadsheets","Forever Humble"}
local function stats(w,W,H,by)
  local total,found,a,rank,awards=summary(w.album)
  panelBox(10,25,W-20,by-33,panel)
  lcd.drawText(20,32,w.view==1 and "PILOT PASSPORT" or w.view==2 and "COLLECTOR'S VAULT" or w.view==3 and "ACHIEVEMENTS" or "",0+gold)
  if w.view==4 then
    local card=decks[w.level][w.card];lcd.drawText(20,55,"TRICK ACADEMY",MIDSIZE+gold);lcd.drawTextLines(20,86,W-40,by-94,"Prerequisite: "..card[4].."\n"..card[2],SMLSIZE+white)
  elseif w.view==5 then
    lcd.drawText(20,55,"COMMUNITY / BATTLE",MIDSIZE+gold);lcd.drawTextLines(20,88,W-40,by-95,"Daily and weekly use the radio calendar. Battle: take turns; landed = 1 point. Skip unsafe tasks.",SMLSIZE+white)
  elseif w.view==1 then
    lcd.drawText(20,55,rank,MIDSIZE+white)
    lcd.drawText(20,89,"XP "..(total*25).."  |  Landed "..total,SMLSIZE+white)
    lcd.drawText(20,110,"Collection "..found.."/125   |   Awards "..a.."/9",SMLSIZE+white)
    lcd.drawFilledRectangle(20,137,W-40,8,ink);lcd.drawFilledRectangle(20,137,floor((W-40)*found/125),8,gold)
    if by>180 then lcd.drawText(20,153,w.unsaved and "SD save unavailable" or "Collection saved locally",SMLSIZE+muted) end
  elseif w.view==2 then
    local dx=floor((W-72)/25);local dy=min(24,floor((by-67)/7))
    for l=1,7 do
      local y=56+(l-1)*dy
      lcd.drawText(20,y,codes[l],SMLSIZE+white)
      for c=1,#decks[l] do
        local r=tonumber(string.sub(w.album.marks,cardIndex(l,c),cardIndex(l,c))) or 0
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
      if lcd.sizeText(label,SMLSIZE)>cw-3 then label=string.sub(label,1,17) end
      lcd.drawText(x,y,label,SMLSIZE+(awards[i] and gold or muted))
    end
  end
end
local function refresh(w,event,touch)
  -- Only the one-time script may safely normalize nil to an idle event.
  if event==nil and not w.tool then tile(w);return end
  if event==nil then event=0 end
  local W,H=LCD_W,LCD_H
  if W<300 or H<230 then lcd.drawFilledRectangle(0,0,W,H,ink);lcd.drawText(5,5,"Use a colour screen 320x240+",SMLSIZE+white);return end
  local pad=8;local bh=min(43,floor(H/6));local by=H-bh-pad
  local acts=actions(w);w.focus=max(1,min(#acts,w.focus or 1));local slot=floor((W-2*pad)/#acts)
  local elapsed=w.dealAt and getTime()-w.dealAt or 999
  local moving=elapsed>=0 and elapsed<(w.duration or 24)
  if not moving then
    w.dealAt=nil
    if event~=0 and (event==EVT_VIRTUAL_NEXT or event==EVT_ROT_RIGHT or event==EVT_VIRTUAL_INC) then w.focus=w.focus%#acts+1
    elseif event~=0 and (event==EVT_VIRTUAL_PREV or event==EVT_ROT_LEFT or event==EVT_VIRTUAL_DEC) then w.focus=(w.focus-2)%#acts+1
    elseif event~=0 and (event==EVT_VIRTUAL_ENTER or event==EVT_ENTER_BREAK or event==EVT_ROT_BREAK) then perform(w,acts[w.focus])
    elseif event~=0 and event==EVT_TOUCH_TAP and type(touch)=="table" and type(touch.x)=="number" and type(touch.y)=="number" and touch.y>=by and touch.y<by+bh then
      local dx=touch.x-pad;if dx>=0 and dx<slot*#acts and dx%slot<slot-2 then w.focus=1+floor(dx/slot);perform(w,acts[w.focus]) end
    end
  end
  acts=actions(w);slot=floor((W-2*pad)/#acts)
  lcd.drawFilledRectangle(0,0,W,H,ink)
  lcd.drawText(9,3,w.tool and "SQ / TRICK 2.5 / TOOL" or "SQ / TRICK 2.5 / LIVE",SMLSIZE+gold)
  lcd.drawText(W-9,3,w.battle and ("P"..w.pilot.." "..w.scores[1]..":"..w.scores[2]) or ("WINS "..w.session),RIGHT+SMLSIZE+white)
  if w.view>0 then stats(w,W,H,by) else
    local x,y,cw,ch=12,27,W-30,by-37
    local themes={nil,rgb(80,100,62),rgb(40,160,180),rgb(168,86,49),rgb(77,82,88),rgb(27,118,150)};local ac=themes[w.theme] or accents[w.level];local tier=w.card and w.rarity or 1
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
      local title=card and card[1] or (w.message=="Challenge completed." and "Landed it!" or "Draw a card")
      local tf=MIDSIZE;if lcd.sizeText(title,tf)>cw-20 then tf=0 end
      lcd.drawText(x+10,y+30,title,tf+ink)
      local body=card and card[2] or w.message or (w.level==6 and "ADULTS ONLY: strong language. Draw to reveal." or w.level==7 and "Fixed Wing or Real World: 20 field cards. Simulator: all 25. Use on ground." or "Tap Draw or press ENTER. Deck changes the pack; Mode and Theme change settings. Fly when safe.")
      local footer=y+ch-18
      lcd.drawTextLines(x+10,y+57,cw-20,max(1,footer-y-59),body,SMLSIZE+ink)
      lcd.drawFilledRectangle(x+9,footer,cw-18,1,edge[tier])
      lcd.drawText(x+10,footer+2,w.card and ("SQ-"..codes[w.level].."-"..string.format("%02d",w.card)) or modes[w.mode],SMLSIZE+ink)
      lcd.drawText(x+cw-10,footer+2,w.unsaved and "NOT SAVED" or (#w.bags[w.level]>0 and ("LEFT "..#w.bags[w.level]) or "READY"),RIGHT+SMLSIZE+ink)
    end
  end
  for i,a in ipairs(acts) do local x=pad+(i-1)*slot;local selected=i==w.focus
    lcd.drawFilledRectangle(x,by,slot-2,bh,selected and gold or panel)
    lcd.drawRectangle(x,by,slot-2,bh,gold)
    lcd.drawText(x+floor((slot-2)/2),by+floor((bh-16)/2),a,CENTER+SMLSIZE+(selected and ink or white))
  end
end
return {name="SQLotto",options=options,create=create,update=update,refresh=refresh}
