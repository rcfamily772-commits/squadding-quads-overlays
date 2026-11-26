-- SQ FlightLab v0.1 standalone EdgeTX tool
local loader=loadScript("/SCRIPTS/SQFL/core.lua")
local core=loader and loader()
local state=core and core.new()
local function run(event)
  if event==EVT_VIRTUAL_EXIT then return 2 end
  if not core then lcd.clear();lcd.drawText(2,2,"Missing SQFL/core.lua");return 0 end
  core.frame(state,event)
  return 0
end
return {run=run}
