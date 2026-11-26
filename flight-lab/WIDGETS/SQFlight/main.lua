-- SQ FlightLab v0.1 colour widget, full-screen only.
local loader=loadScript("/SCRIPTS/SQFL/core.lua")
local core=loader and loader()
local function create(zone,options) return {zone=zone,state=core and core.new(),full=false} end
local function refresh(w,event,touchState)
  if event==nil then
    if w.full and w.state then w.state.active=false;w.state.last=nil end
    w.full=false
    lcd.drawText(w.zone.x+3,w.zone.y+2,"SQ FlightLab / DEV",SMLSIZE)
    return
  end
  if not core then lcd.drawText(2,2,"Missing SQFL/core.lua");return end
  if not w.full then w.state=core.new();w.full=true end
  if event==EVT_VIRTUAL_EXIT then w.state.active=false;w.full=false;lcd.exitFullScreen();return end
  core.frame(w.state,event)
end
return {name="SQFlight",options={},create=create,refresh=refresh}
