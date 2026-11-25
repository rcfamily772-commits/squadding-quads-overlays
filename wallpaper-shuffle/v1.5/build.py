#!/usr/bin/env python3
"""Repackage the original SQWall v1.1 release into self-contained widget ZIPs."""
import argparse, hashlib, re, struct, zipfile
from pathlib import Path, PurePosixPath
SIZES = [(320,240),(480,272),(480,320),(800,480),(320,480)]
EXPECTED = ['karen','dealer','manc','workshop'] + [f'sq{i:03d}' for i in range(4,31)] + ['intro']
CHECKSUM = '67239073e280509822fe1b84eea235b621057218a8f532ef463523ffe6eb6d97'
def dimensions(data):
    if data.startswith(b'\x89PNG\r\n\x1a\n') and len(data)>=24:
        return struct.unpack('>II',data[16:24])
    if data.startswith(b'BM') and len(data)>=26:
        dib=struct.unpack_from('<I',data,14)[0]
        if dib==12:
            return struct.unpack_from('<HH',data,18)
        w,h=struct.unpack_from('<ii',data,18)
        return w,abs(h)
    return None
def build(source, lua, out, verify=True):
    if verify and hashlib.sha256(source.read_bytes()).hexdigest()!=CHECKSUM:
        raise SystemExit('Original release checksum mismatch; refusing to publish.')
    out.mkdir(parents=True,exist_ok=True)
    code=lua.read_bytes()
    assert b'v1.5 | Complete Gallery' in code
    with zipfile.ZipFile(source) as z:
        assert z.testzip() is None
        assets={}
        for item in z.infolist():
            p=PurePosixPath(item.filename.replace('\\','/'))
            if item.is_dir() or p.suffix.lower() not in ('.png','.bmp'): continue
            name=p.stem.lower()
            if name not in EXPECTED: continue
            data=z.read(item)
            size=dimensions(data)
            if size not in SIZES: continue
            path=str(p).lower()
            # Prefer actual installed widget art, then the SD gallery, then exact-sized originals.
            priority=(3 if '/widgets/sqwall/art/' in '/'+path else
                      2 if '/images/sqwall/' in '/'+path else 1)
            key=(size,name)
            if key not in assets or priority>assets[key][0]:
                assets[key]=(priority,p.suffix.lower(),data)
        packs={}
        for w,h in SIZES:
            size=(w,h)
            missing=[n for n in EXPECTED if (size,n) not in assets]
            if missing:
                raise SystemExit(f'{w}x{h}: missing original artwork: {missing}')
            manifest=[]
            files={'WIDGETS/SQWall/main.lua':code}
            for name in EXPECTED:
                _,ext,data=assets[size,name]
                actual=name+ext
                files['WIDGETS/SQWall/art/'+actual]=data
                manifest.append(name+'.png='+actual)
            files['WIDGETS/SQWall/art/gallery.txt']=('\n'.join(manifest)+'\n').encode()
            files['INSTALL.txt']=(f'SQWall v1.5 | {w}x{h}\n'
                '32 built-in gallery images. Back up the SD card and merge WIDGETS into its root.\n'
                'Replace main.lua; remove stale main.luac. Keep last.txt and existing custom artwork.\n'
                'Restart and add SQWall to a large colour widget zone. Full screen: Prev, Lucky, Next, Clean.\n'
                'No separate artwork installation. Existing boot splash and theme are unchanged.\n'
                'Physical radio validation pending.\n').encode()
            packs[f'{w}x{h}']=files
            path=out/f'SQWall-v1.5-{w}x{h}.zip'
            with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as dst:
                for n,data in files.items(): dst.writestr(n,data)
            with zipfile.ZipFile(path) as dst:
                assert dst.testzip() is None
                assert len([n for n in dst.namelist() if n.endswith(('.png','.bmp'))])==32
            print(f'Validated {path}: 32 images')
        with zipfile.ZipFile(out/'SQWall-v1.5-All-Radios.zip','w',zipfile.ZIP_DEFLATED,compresslevel=6) as dst:
            for size,files in packs.items():
                for n,data in files.items(): dst.writestr(size+'/'+n,data)
            dst.writestr('INSTALL.txt','Choose ONE resolution folder. Merge its WIDGETS folder into the SD root. Colour EdgeTX only.\n')
        with zipfile.ZipFile(out/'SQWall-v1.5-All-Radios.zip') as dst:
            assert dst.testzip() is None
            assert len([n for n in dst.namelist() if n.endswith(('.png','.bmp'))])==160
        (out/'SHA256SUMS.txt').write_text(''.join(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}\n' for p in sorted(out.glob('*.zip'))))
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('source',type=Path);p.add_argument('lua',type=Path);p.add_argument('out',type=Path)
    a=p.parse_args();build(a.source,a.lua,a.out)
