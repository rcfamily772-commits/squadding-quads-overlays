"""Render recordings from apex.lua. LCD typography is approximate, geometry is actual Lua."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

SCALE=3
frames=json.loads(Path('/tmp/sq-apex-frames.json').read_text())
def font(f):
    size=64 if f&0x10000000 else 32 if f&0x08000000 else 22 if f&0x04000000 else 12
    path='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf' if size>=22 else '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    return ImageFont.truetype(path,size*SCALE)
def colour(f):return '#%06x'%(f&0xffffff)
def render(commands):
    im=Image.new('RGB',(480*SCALE,272*SCALE),'#080c10');d=ImageDraw.Draw(im)
    for op,*v in commands:
        if op=='drawText':
            x,y,t,f=v;ft=font(f);tw=d.textlength(t,font=ft);x*=SCALE;y*=SCALE
            if f&0x40000000:x-=tw/2
            elif f&0x20000000:x-=tw
            d.text((x,y),t,font=ft,fill=colour(f),anchor='lt')
        elif op in ('drawFilledRectangle','drawRectangle'):
            x,y,w,h,c=v;box=(x*SCALE,y*SCALE,(x+w)*SCALE-1,(y+h)*SCALE-1)
            d.rectangle(box,fill=colour(c) if op=='drawFilledRectangle' else None,outline=None if op=='drawFilledRectangle' else colour(c),width=SCALE)
        elif op=='drawLine':
            x,y,X,Y,p,c=v;d.line((x*SCALE,y*SCALE,X*SCALE,Y*SCALE),fill=colour(c),width=SCALE)
        elif op=='drawFilledTriangle':
            x,y,X,Y,xx,yy,c=v;d.polygon([(x*SCALE,y*SCALE),(X*SCALE,Y*SCALE),(xx*SCALE,yy*SCALE)],fill=colour(c))
        elif op=='drawCircle':
            x,y,r,c=v;d.ellipse(((x-r)*SCALE,(y-r)*SCALE,(x+r)*SCALE,(y+r)*SCALE),outline=colour(c),width=SCALE)
    return im
out=Path('sq-reactor/design');out.mkdir(exist_ok=True)
names=['performance','essentials','battery','logbook','report']
for n,cmd in zip(names,frames):render(cmd).save(out/(n+'.png'))
board=Image.new('RGB',(1600,1280),'#080c10');d=ImageDraw.Draw(board)
regular='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
d.text((60,42),'SQ / PILOT DASH',font=ImageFont.truetype(bold,21),fill='#62dae7')
d.text((60,78),'APEX',font=ImageFont.truetype(bold,68),fill='#f1f4ef')
d.text((360,109),'V1.8  /  EDGETX',font=ImageFont.truetype(regular,23),fill='#95a5af')
d.text((60,164),'Actual Lua layout. Simulated telemetry. Browser and radio fonts may differ.',font=ImageFont.truetype(regular,19),fill='#95a5af')
main=render(frames[0]).resize((960,544),Image.Resampling.LANCZOS);board.paste(main,(60,220))
d.text((60,782),'PERFORMANCE / LIVE',font=ImageFont.truetype(bold,16),fill='#62dae7')
report=render(frames[4]).resize((480,272),Image.Resampling.LANCZOS);board.paste(report,(1060,220))
d.text((1060,510),'LAST FLIGHT / FROZEN',font=ImageFont.truetype(bold,16),fill='#f4be5b')
d.text((1060,570),'Speed. Time. Perspective.',font=ImageFont.truetype(bold,23),fill='#f1f4ef')
for y,t in enumerate(['A clear instrument hierarchy.','Measured colour. Quiet surfaces.','The flight stays in focus.']):d.text((1060,615+y*34),t,font=ImageFont.truetype(regular,19),fill='#95a5af')
for i,(n,idx) in enumerate([('ESSENTIALS',1),('BATTERY',2),('LOGBOOK',3)]):
    x=60+i*500;board.paste(render(frames[idx]).resize((480,272),Image.Resampling.LANCZOS),(x,850));d.text((x,1140),n,font=ImageFont.truetype(bold,16),fill='#95a5af')
d.line((60,1202,1540,1202),fill='#29343d',width=1)
d.text((60,1224),'SQUADDING QUADS  /  RADIO INSTRUMENTS',font=ImageFont.truetype(regular,15),fill='#95a5af')
d.text((1190,1224),'PHYSICAL TESTING PENDING',font=ImageFont.truetype(regular,15),fill='#95a5af')
board.save(out/'apex-overview.png')
print('Rendered five actual-Lua design proofs and overview')
