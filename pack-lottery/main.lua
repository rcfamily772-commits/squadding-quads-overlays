-- Squadding Quads | The Pack Lottery | preview 1.7
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

local ink = lcd.RGB(15,16,17)
local panel = lcd.RGB(43,40,34)
local cream = lcd.RGB(245,244,232)
local amber = lcd.RGB(225,190,123)
local ready = {"Draw", "Level"}
local active = {"Landed it", "Try again", "Redraw", "Level"}
local floor = math.floor
local accents = {lcd.RGB(37,108,72),lcd.RGB(26,92,146),lcd.RGB(122,65,155),lcd.RGB(159,97,14),lcd.RGB(92,106,49),lcd.RGB(167,35,47)}
local suits = {"B","I","A","OD","BP","18+"}
local paper = lcd.RGB(248,242,224)
local shadow = lcd.RGB(67,70,76)
local muted = lcd.RGB(78,81,85)
local rarityLabels = {"STD","RARE","LEG","MYTH"}
local foil = {paper,lcd.RGB(212,222,231),lcd.RGB(247,213,130),lcd.RGB(220,205,249)}
local foilEdge = {muted,lcd.RGB(116,143,173),lcd.RGB(171,119,25),lcd.RGB(116,63,174)}

local options = {{"SFX", BOOL, 0}}
local function update(w, opts)
  w.sound = opts and opts.SFX == 1 or false
end
local function tone(w, freq, duration, pause, sweep)
  -- Optional normal-priority sound, never PLAY_NOW; use radio beep volume.
  if w.sound and type(playTone) == "function" then
    pcall(playTone, freq, duration, pause, 0, sweep or 0)
  end
end
local function create(zone, opts)
  return {zone=zone, sound=opts and opts.SFX == 1 or false, level=1, bags={{},{},{},{},{},{}}, last={}, focus=1,
          landed=0, attempts=0, seed=0}
end

local function draw(w)
  local bag, deck = w.bags[w.level], decks[w.level]
  if #bag == 0 then
    tone(w, 740, 65, 25, -3)
    -- Mix in the time of the draw. Keep RNG state private to this instance.
    w.seed = (w.seed + getTime()) % 65536
    for i=1,#deck do bag[i]=i end
    for i=#deck,2,-1 do
      w.seed = (25173*w.seed + 13849) % 65536
      local j = 1 + floor(w.seed*i/65536)
      bag[i],bag[j] = bag[j],bag[i]
    end
    if bag[#bag] == w.last[w.level] then
      bag[1],bag[#bag] = bag[#bag],bag[1]
    end
  end
  w.card = table.remove(bag)
  w.seed = (25173*w.seed + 13849) % 65536
  local roll = w.seed / 65536
  w.rarity = roll < .01 and 4 or roll < .10 and 3 or roll < .30 and 2 or 1
  w.last[w.level] = w.card
  w.attempts = 1
  w.focus = 1
  w.message = nil
  w.dealAt = getTime()
  tone(w, 980, 70, 0, -5)
  if w.rarity >= 3 then tone(w, 1320, 70, 15, 0) end
  if w.rarity == 4 then tone(w, 1760, 85, 0, 0) end
end

local function choose(w, action)
  if action == "Level" then
    w.level = w.level % #levels + 1
    w.card,w.message,w.focus,w.dealAt = nil,nil,2,nil
    tone(w, 650, 45, 0, 0)
  elseif action == "Try again" then
    w.attempts = w.attempts + 1
    tone(w, 450, 80, 0, -2)
  elseif action == "Landed it" then
    w.landed = w.landed + 1
    w.message = decks[w.level][w.card][1] .. " complete."
    w.card,w.focus,w.dealAt = nil,1,nil
    tone(w, 660, 70, 20, 0)
    tone(w, 880, 100, 0, 0)
  else
    draw(w)
  end
end

local function tile(w)
  local z = w.zone
  lcd.drawFilledRectangle(0,0,z.w,z.h,ink)
  if z.w < 36 or z.h < 16 then return end
  lcd.drawText(4,0,z.w >= 125 and "SQ / PACK LOTTERY" or "SQ",SMLSIZE+amber)
  local title = w.card and (w.level == 6 and "Adults Only" or decks[w.level][w.card][1]) or "Open full screen"
  if z.h >= 42 and lcd.sizeText(title,SMLSIZE) <= z.w-8 then
    lcd.drawText(4,21,title,SMLSIZE+cream)
  end
end

local function refresh(w,event,touch)
  if event == nil then tile(w) return end
  local width,height = LCD_W,LCD_H
  local pad = 10
  local bh = math.min(50,floor(height/5))
  local by = height-bh-pad
  local actions = w.card and active or ready
  local slot = floor((width-2*pad)/#actions)
  local dealing = w.dealAt and getTime()-w.dealAt < 24 and getTime()-w.dealAt >= 0
  if not dealing then w.dealAt = nil end
  if dealing then
    -- A short non-blocking deal animation; ignore repeated button presses.
  elseif event == EVT_VIRTUAL_NEXT then
    w.focus = w.focus % #actions + 1
  elseif event == EVT_VIRTUAL_PREV then
    w.focus = (w.focus-2) % #actions + 1
  elseif event == EVT_VIRTUAL_ENTER then
    choose(w,actions[w.focus])
  elseif event == EVT_TOUCH_TAP and touch and touch.y >= by and touch.y < by+bh then
    local dx = touch.x-pad
    if dx >= 0 and dx < slot*#actions and dx%slot < slot-3 then
      w.focus = 1+floor(dx/slot)
      choose(w,actions[w.focus])
    end
  end
  actions = w.card and active or ready
  slot = floor((width-2*pad)/#actions)
  lcd.drawFilledRectangle(0,0,width,height,ink)
  lcd.drawText(pad,3,"SQ / BLACK LABEL",SMLSIZE+amber)
  lcd.drawText(width-pad,3,"LANDED "..w.landed,RIGHT+SMLSIZE+cream)
  local x,y,cw,ch = 14,28,width-32,by-38
  local accent = accents[w.level]
  -- Offset card backs, with a contrasting inset like a real deck.
  lcd.drawFilledRectangle(x+8,y+6,cw,ch,shadow)
  lcd.drawFilledRectangle(x+5,y+3,cw,ch,accent)
  lcd.drawRectangle(x+9,y+7,cw-8,ch-8,cream)
  local elapsed = w.dealAt and getTime()-w.dealAt or 24
  local moving = elapsed >= 0 and elapsed < 24
  if moving then
    local shift = floor((24-elapsed)*math.min(38,floor(width/9))/24)
    x = x + shift
    lcd.drawFilledRectangle(x,y,cw,ch,paper)
    lcd.drawFilledRectangle(x+4,y+4,cw-8,ch-8,accent)
    lcd.drawRectangle(x+9,y+9,cw-18,ch-18,cream)
    lcd.drawText(x+floor(cw/2),y+floor(ch/2)-14,"SQ",CENTER+MIDSIZE+cream)
    lcd.drawText(x+floor(cw/2),y+floor(ch/2)+14,"DEALING...",CENTER+SMLSIZE+cream)
  else
    local tier = w.card and w.rarity or 1
    lcd.drawFilledRectangle(x,y,cw,ch,foil[tier])
    lcd.drawRectangle(x,y,cw,ch,amber)
    lcd.drawRectangle(x+3,y+3,cw-6,ch-6,tier > 1 and foilEdge[tier] or accent)
    local card = w.card and decks[w.level][w.card]
    local label = levels[w.level]
    lcd.drawText(x+10,y+7,suits[w.level].."  "..label,SMLSIZE+accent)
    if card then lcd.drawText(x+cw-10,y+7,rarityLabels[tier].." / "..w.attempts,RIGHT+SMLSIZE+foilEdge[tier]) end
    lcd.drawFilledRectangle(x+10,y+27,cw-20,1,accent)
    local title = card and card[1] or (w.message and "Landed it!" or "Draw a card")
    local titleFont = MIDSIZE
    if lcd.sizeText(title,titleFont) > cw-20 then titleFont = 0 end
    lcd.drawText(x+10,y+34,title,titleFont+ink)
    local body = card and card[2] or w.message or (w.level == 4 and "One challenge. No tricks. Just fly when it is safe." or w.level == 5 and "Finish your checks, leave the bench and fly when safe." or w.level == 6 and "ADULTS ONLY: strong language. Draw to reveal. Fly only when safe." or "Choose your level, then draw a challenge for this pack.")
    local bodyY = y+68
    lcd.drawTextLines(x+10,bodyY,cw-20,ch-74,body,SMLSIZE+ink)
  end
  for i,action in ipairs(actions) do
    local x = pad+(i-1)*slot
    local selected = i==w.focus
    lcd.drawFilledRectangle(x,by,slot-3,bh,selected and amber or panel)
    lcd.drawText(x+floor((slot-3)/2),by+floor((bh-18)/2),action,
                 CENTER+SMLSIZE+(selected and ink or cream))
  end
end

return {name="SQLotto", options=options, create=create, update=update, refresh=refresh}
