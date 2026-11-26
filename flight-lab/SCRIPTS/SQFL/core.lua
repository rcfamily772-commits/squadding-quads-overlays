-- SQ FlightLab v0.1 / original experimental renderer
-- No RF, model, storage or firmware writes. Spare radio only.
local M={}
local sin,cos,sqrt,abs,floor,min,max=math.sin,math.cos,math.sqrt,math.abs,math.floor,math.min,math.max
local pi=math.pi
local function clamp(v,a,b) return max(a,min(b,v)) end
local function stick(name)
  local v=getValue(name)
  if type(v)~="number" then return nil end
  return clamp(v/1024,-1,1)
end
local world={}
local function line(x,y,z,X,Y,Z,level,gate) world[#world+1]={x,y,z,X,Y,Z,level,gate} end
for i=-40,80,10 do
  line(-40,0,i,40,0,i,0,false)
  if i<=40 then line(i,0,-40,i,0,80,0,false) end
end
for z=12,72,15 do
  local x=sin(z*.15)*5
  line(x-2,0,z,x-2,4,z,0,true)
  line(x-2,4,z,x+2,4,z,0,true)
  line(x+2,4,z,x+2,0,z,0,true)
  line(x+2,0,z,x-2,0,z,0,true)
end
for i=1,8 do
  local x=(i%2==0 and 1 or -1)*(8+i%3*3)
  local z=8+i*8
  local h=4+i%3
  local level=i<=3 and 1 or 2
  line(x,0,z,x,h,z,level,false)
  line(x,h,z,x+5,h,z,level,false)
  line(x+5,h,z,x+5,0,z,level,false)
  line(x+5,0,z,x,0,z,level,false)
  line(x,h,z,x,h,z+5,level,false)
  line(x+5,h,z,x+5,h,z+5,level,false)
  line(x,h,z+5,x+5,h,z+5,level,false)
  line(x,h,z+5,x,0,z+5,level,false)
  line(x+5,h,z+5,x+5,0,z+5,level,false)
  line(x,0,z+5,x+5,0,z+5,level,false)
  line(x,0,z,x,0,z+5,level,false)
  line(x+5,0,z,x+5,0,z+5,level,false)
end
function M.new()
  return {x=0,y=2,z=0,vx=0,vy=0,vz=0,a=1,b=0,c=0,d=0,quality=0,rate=600,tilt=20,last=nil,acc=0,count=0,ticks=0,maxgap=0,fps=0,gap=0,hz=0,steps=0,lines=0,active=false,ack=false,err=false}
end
function M.reset(s)
  s.x,s.y,s.z,s.vx,s.vy,s.vz=0,2,0,0,0,0
  s.a,s.b,s.c,s.d=1,0,0,0
  s.last=nil;s.acc=0;s.count=0;s.ticks=0;s.maxgap=0;s.steps=0;s.fps=0;s.hz=0;s.gap=0
end
local function step(s,dt,r,p,t,y)
  local k=s.rate*pi/180
  local X,Y,Z=p*k,y*k*.7,-r*k
  local mag=sqrt(X*X+Y*Y+Z*Z)
  if mag>0.00001 then
    local f=sin(mag*dt/2)/mag
    local a,b,c,d=s.a,s.b,s.c,s.d
    local A,B,C,D=cos(mag*dt/2),X*f,Y*f,Z*f
    a,b,c,d=a*A-b*B-c*C-d*D,a*B+b*A+c*D-d*C,a*C-b*D+c*A+d*B,a*D+b*C-c*B+d*A
    local n=sqrt(a*a+b*b+c*c+d*d)
    s.a,s.b,s.c,s.d=a/n,b/n,c/n,d/n
  end
  local a,b,c,d=s.a,s.b,s.c,s.d
  local thrust=(t+1)*11.5
  local ax=2*(b*c-a*d)*thrust
  local ay=(1-2*(b*b+d*d))*thrust-9.81
  local az=2*(c*d+a*b)*thrust
  s.vx=s.vx+(ax-s.vx*.45)*dt;s.vy=s.vy+(ay-s.vy*.45)*dt;s.vz=s.vz+(az-s.vz*.45)*dt
  s.x=clamp(s.x+s.vx*dt,-100,100);s.y=max(.3,s.y+s.vy*dt);s.z=clamp(s.z+s.vz*dt,-100,100)
  if s.y<=.3 then s.vy=max(0,s.vy);s.vx=s.vx*.98;s.vz=s.vz*.98 end
end
-- Clip 2-D segment to screen before calling firmware LCD functions.
local function clip(x,y,X,Y,w,h)
  local dx,dy=X-x,Y-y
  local lo,hi=0,1
  local function bound(p,q)
    if p==0 then return q>=0 end
    local t=q/p
    if p<0 then if t>hi then return false end;lo=max(lo,t)
    else if t<lo then return false end;hi=min(hi,t) end
    return true
  end
  if not bound(-dx,x) or not bound(dx,w-1-x) or not bound(-dy,y) or not bound(dy,h-1-y) then return nil end
  return floor(x+lo*dx+.5),floor(y+lo*dy+.5),floor(x+hi*dx+.5),floor(y+hi*dy+.5)
end
local color=type(lcd.RGB)=="function" and (LCD_W or 0)>212
local function paint(r,g,b) if color then return lcd.RGB(r,g,b) end return 0 end
local bg=paint(16,28,26)
local ink=paint(220,238,222)
local grid=paint(80,125,110)
local gate=paint(194,241,126)
local function text(x,y,t) lcd.drawText(x,y,t,(SMLSIZE or 0)+ink) end
function M.frame(s,event)
  local w,h=LCD_W,LCD_H
  lcd.clear(bg)
  if not s.ack then
    text(3,2,"SQ FlightLab v0.1")
    text(3,15,"EXPERIMENTAL - DO NOT USE")
    text(3,28,"Spare radio / RF OFF")
    text(3,41,"No powered aircraft")
    text(3,54,"ENTER: confirm / inspect")
    if event==EVT_VIRTUAL_ENTER then s.ack=true end
    return
  end
  if event==EVT_VIRTUAL_ENTER then s.active=not s.active;M.reset(s)
  elseif event==EVT_VIRTUAL_NEXT then s.quality=(s.quality+1)%3
  elseif event==EVT_VIRTUAL_PREV then s.rate=s.rate+100;if s.rate>1000 then s.rate=200 end end
  local now=getTime()
  local elapsed=s.last and max(0,now-s.last) or 0
  s.last=now
  if s.active then
    local r,p,t,y=stick("ail"),stick("ele"),stick("thr"),stick("rud")
    s.err=not (r and p and t and y)
    if s.err then s.active=false else
      s.acc=s.acc+min(.10,elapsed/100)
      while s.acc>=.01 do step(s,.01,r,p,t,y);s.acc=s.acc-.01;s.steps=s.steps+1 end
    end
  end
  if elapsed>0 then
    s.count=s.count+1;s.ticks=s.ticks+elapsed;s.maxgap=max(s.maxgap,elapsed)
    if s.ticks>=100 then
      s.fps=s.count*100/s.ticks;s.gap=s.maxgap*10;s.hz=s.steps*100/s.ticks
      s.count=0;s.ticks=0;s.maxgap=0;s.steps=0
    end
  end
  -- camera = body orientation followed by fixed upward camera angle
  local a,b,c,d=s.a,s.b,s.c,s.d
  local v=-s.tilt*pi/360
  local A,B=cos(v),sin(v)
  a,b,c,d=a*A-b*B,a*B+b*A,c*A+d*B,d*A-c*B
  -- inverse rotation matrix, precomputed once per draw
  local m11,m12,m13=1-2*(c*c+d*d),2*(b*c+a*d),2*(b*d-a*c)
  local m21,m22,m23=2*(b*c-a*d),1-2*(b*b+d*d),2*(c*d+a*b)
  local m31,m32,m33=2*(b*d+a*c),2*(c*d-a*b),1-2*(b*b+c*c)
  local function cam(x,y,z)
    x,y,z=x-s.x,y-s.y,z-s.z
    return m11*x+m12*y+m13*z,m21*x+m22*y+m23*z,m31*x+m32*y+m33*z
  end
  local f=w*.65
  local far=({35,60,110})[s.quality+1]
  s.lines=0
  for i=1,#world do
    local l=world[i]
    if l[7]<=s.quality then
      local x,y,z=cam(l[1],l[2],l[3])
      local X,Y,Z=cam(l[4],l[5],l[6])
      if (z>=.25 or Z>=.25) and (z<=far or Z<=far) then
        if z<.25 then local t=(.25-z)/(Z-z);x=x+(X-x)*t;y=y+(Y-y)*t;z=.25
        elseif Z<.25 then local t=(.25-Z)/(z-Z);X=X+(x-X)*t;Y=Y+(y-Y)*t;Z=.25 end
        local u,v,U,V=clip(w/2+x*f/z,h/2-y*f/z,w/2+X*f/Z,h/2-Y*f/Z,w,h)
        if u then lcd.drawLine(u,v,U,V,SOLID or 0,l[8] and gate or grid);s.lines=s.lines+1 end
      end
    end
  end
  lcd.drawLine(floor(w/2)-4,floor(h/2),floor(w/2)+4,floor(h/2),SOLID or 0,ink)
  lcd.drawLine(floor(w/2),floor(h/2)-4,floor(w/2),floor(h/2)+4,SOLID or 0,ink)
  text(2,1,string.format("SQ v0.1 | %.1f FPS | %dms",s.fps,s.gap))
  text(2,13,string.format("Q%d R%d | L%d | HZ%d",s.quality,s.rate,s.lines,floor(s.hz)))
  if h>=80 then text(2,h-26,string.format("%.0fkm/h %.1fm",sqrt(s.vx*s.vx+s.vy*s.vy+s.vz*s.vz)*3.6,s.y)) end
  text(2,h-13,s.err and "Stick source error" or (s.active and "ENTER stop | NEXT Q" or "ENTER start | NEXT Q"))
end
return M
