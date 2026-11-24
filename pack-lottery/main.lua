-- Squadding Quads | The Pack Lottery | preview 1.1
local levels = {"Beginner", "Intermediate", "Advanced", "OnlyDrones"}
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
  }
}

local ink = lcd.RGB(18,23,31)
local panel = lcd.RGB(39,49,63)
local cream = lcd.RGB(245,244,232)
local amber = lcd.RGB(255,193,72)
local ready = {"Draw", "Level"}
local active = {"Landed it", "Try again", "Redraw", "Level"}
local floor = math.floor

local function create(zone)
  return {zone=zone, level=1, bags={{},{},{},{}}, last={}, focus=1,
          landed=0, attempts=0, seed=0}
end

local function draw(w)
  local bag, deck = w.bags[w.level], decks[w.level]
  if #bag == 0 then
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
  w.last[w.level] = w.card
  w.attempts = 1
  w.focus = 1
  w.message = nil
end

local function choose(w, action)
  if action == "Level" then
    w.level = w.level % #levels + 1
    w.card,w.message,w.focus = nil,nil,2
  elseif action == "Try again" then
    w.attempts = w.attempts + 1
  elseif action == "Landed it" then
    w.landed = w.landed + 1
    w.message = decks[w.level][w.card][1] .. " complete."
    w.card,w.focus = nil,1
  else
    draw(w)
  end
end

local function tile(w)
  local z = w.zone
  lcd.drawFilledRectangle(0,0,z.w,z.h,ink)
  if z.w < 36 or z.h < 16 then return end
  lcd.drawText(4,0,z.w >= 125 and "SQ / PACK LOTTERY" or "SQ",SMLSIZE+amber)
  local title = w.card and decks[w.level][w.card][1] or "Open full screen"
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
  if event == EVT_VIRTUAL_NEXT then
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
  lcd.drawText(pad,4,"SQUADDING QUADS",SMLSIZE+amber)
  lcd.drawText(width-pad,4,"LANDED  "..w.landed,RIGHT+SMLSIZE+cream)
  lcd.drawFilledRectangle(pad,28,width-2*pad,2,amber)
  local card = w.card and decks[w.level][w.card]
  local label = levels[w.level]
  if card then label = label.."   /   ATTEMPT "..w.attempts end
  lcd.drawText(pad,35,label,SMLSIZE+amber)
  local title = card and card[1] or "The Pack Lottery"
  local titleFont = width >= 300 and MIDSIZE or 0
  lcd.drawText(pad,57,title,titleFont+cream)
  local body = card and card[2] or w.message or (w.level == 4 and "One challenge. No tricks required. Draw a message and just fly when it is safe." or "Choose your level, then draw a challenge for this pack.")
  local bodyY = width >= 300 and 95 or 86
  lcd.drawTextLines(pad,bodyY,width-2*pad,by-bodyY-4,body,cream)
  for i,action in ipairs(actions) do
    local x = pad+(i-1)*slot
    local selected = i==w.focus
    lcd.drawFilledRectangle(x,by,slot-3,bh,selected and amber or panel)
    lcd.drawText(x+floor((slot-3)/2),by+floor((bh-18)/2),action,
                 CENTER+SMLSIZE+(selected and ink or cream))
  end
end

return {name="SQLotto", create=create, refresh=refresh}
