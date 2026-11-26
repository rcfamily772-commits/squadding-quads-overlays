#!/usr/bin/env python3
"""SQ Black Label OS Studio v0.1. Development only; never flash output."""
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path, PurePosixPath

BASELINE = "v2.12.5"
KEYS = {"PRIMARY1","PRIMARY2","PRIMARY3","SECONDARY1","SECONDARY2","SECONDARY3","FOCUS","EDIT","ACTIVE","DISABLED","QM_BG","QM_FG"}
HEX = re.compile(r"#[0-9a-fA-F]{6}")
LITERAL = re.compile(r"0[xX][0-9a-fA-F]{6}")
PATH = re.compile(r"radio/src/gui/colorlcd/(?:[A-Za-z0-9_-]+/)*(?:colors?|theme(?:s|_colors|_palette)?|palette)\.(?:cpp|h|hpp)")
def die(msg):
    raise SystemExit("BLOCKED: " + msg)
def run(root, *args):
    return subprocess.check_output(args, cwd=root, text=True).strip()
def sha(data):
    return hashlib.sha256(data).hexdigest()
def load(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))
def valid_profile(p):
    if p.get("schema") != 1 or p.get("baseline") != BASELINE or p.get("status") != "development-only" or p.get("themeLock") is not False:
        die("Wrong profile schema, baseline, or lock state")
    if p.get("target") not in {"tx16s","tx15","tx16smk3","t15"}:
        die("Unknown preview target")
    palette = p.get("palette", {})
    if set(palette) != KEYS | {"WARNING"} or any(not isinstance(v,str) or not HEX.fullmatch(v) for v in palette.values()):
        die("Invalid palette")
    if palette["WARNING"].lower() != "#ff777f":
        die("Warning palette is not editable")
    return palette

def plan(root, profile, review):
    palette = valid_profile(profile)
    if review.get("schema") != 1 or review.get("baseline") != BASELINE or review.get("commit") != run(root,"git","rev-parse","HEAD"):
        die("Review must pin the exact checked-out commit")
    if review.get("reviewed") is not True or not isinstance(review.get("reviewer"),str) or not review["reviewer"].strip():
        die("Independent source review required")
    files = review.get("files")
    if not isinstance(files,list) or not files:
        die("No reviewed palette mappings")
    changes = {}
    keys = set()
    for f in files:
        path = f.get("path","")
        if not PATH.fullmatch(path) or ".." in PurePosixPath(path).parts or path in changes:
            die("File not in narrow candidate palette allowlist: " + path)
        target = root / path
        if not target.is_file() or target.is_symlink() or target.resolve() != target:
            die("Not a regular source file: " + path)
        run(root,"git","ls-files","--error-unmatch",path)
        original = target.read_bytes()
        if sha(original) != f.get("sha256"):
            die("Reviewed file hash mismatch: " + path)
        data = original.decode("utf-8")
        edits = f.get("edits")
        if not isinstance(edits,list) or not edits:
            die("No edits for " + path)
        for e in edits:
            k, before, old = e.get("key"), e.get("exact_line"), e.get("old_literal")
            if k not in KEYS or k in keys:
                die("Duplicate, unknown or warning key")
            if not isinstance(before,str) or "\n" in before or "\r" in before or not isinstance(old,str) or not LITERAL.fullmatch(old):
                die("Only exact single-line 24-bit hexadecimal replacements are accepted")
            # Restrict to a labelled palette assignment, not arbitrary executable code.
            pattern = r"\s*(?:COLOR_THEME_)?"+re.escape(k)+r"\s*[:=]\s*"+re.escape(old)+r"\s*[,;]?\s*(?://[^\r\n]*)?"
            if not re.fullmatch(pattern,before) or data.splitlines().count(before) != 1:
                die("No unique, simple labelled palette assignment for " + k)
            if int(old,16) == int(palette[k][1:],16):
                die("No-op mapping for "+k)
            after = before.replace(old,"0x"+palette[k][1:].upper(),1)
            # Preserve exact line endings and all other source bytes.
            data = re.sub(r"(?m)^"+re.escape(before)+r"(?=\r?$)",lambda _:after,data,count=1)
            keys.add(k)
        output = data.encode("utf-8")
        if output == original:
            die("No changes")
        changes[path] = (original,output)
    return changes,keys

def main():
    a=argparse.ArgumentParser(description=__doc__)
    a.add_argument("--source",required=True,type=Path)
    a.add_argument("--profile",required=True,type=Path)
    a.add_argument("--review",type=Path)
    a.add_argument("--apply",action="store_true")
    a.add_argument("--build",choices=["simulator","firmware"])
    a.add_argument("--report",type=Path,default=Path("sq-os-audit.json"))
    args=a.parse_args()
    root=args.source.resolve()
    if args.report.resolve().is_relative_to(root):
        die("Write report outside upstream checkout")
    p=load(args.profile)
    valid_profile(p)
    if run(root,"git","rev-parse","--show-toplevel") != str(root):
        die("Select checkout root")
    if run(root,"git","status","--porcelain","--untracked-files=all"):
        die("Checkout must be clean (including submodules)")
    head=run(root,"git","rev-parse","HEAD")
    if head != run(root,"git","rev-parse",BASELINE+"^{commit}"):
        die("Checkout must be exactly "+BASELINE)
    report={"status":"DEVELOPMENT ONLY / DO NOT FLASH","baseline":BASELINE,"commit":head,"target":p["target"],"themeLock":False,"patches":[],"build":"not requested"}
    if args.build and not args.apply:
        die("Build requires --apply and reviewed mappings")
    if args.apply and not args.review:
        die("Apply requires independent review manifest")
    if args.build and p["target"]!="tx16s":
        die("Only TX16S is a candidate for build in v0.1; other targets are preview-only")
    if args.review:
        changes,keys=plan(root,p,load(args.review))
        report["palette_keys"]=sorted(keys)
        report["patches"]=[{"path":k,"before_sha256":sha(v[0]),"after_sha256":sha(v[1])} for k,v in changes.items()]
        report["unmapped_keys"]=sorted(KEYS-keys)
        report["review"]="exact labelled literals only; no runtime equivalence guarantee"
        if args.apply:
            try:
                for path,(old,new) in changes.items():
                    (root/path).write_bytes(new)
                actual=set(run(root,"git","diff","--name-only").splitlines())
                if actual!=set(changes) or run(root,"git","diff","--cached","--name-only"):
                    die("Tracked diff does not match reviewed file list")
                for path,(_,new) in changes.items():
                    if (root/path).read_bytes()!=new:
                        die("Post-write hash mismatch")
                report["diff"]=run(root,"git","diff","--","radio/src/gui/colorlcd")
                report["applied"]=True
            except BaseException:
                for path,(old,_) in changes.items():
                    (root/path).write_bytes(old)
                raise
    else:
        report["review"]="BLOCKED: no confirmed upstream palette mapping; audit only"
    args.report.write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    if args.build:
        # Verify the pinned checkout actually supports these presets; do not guess an older CMake target.
        preset="simu" if args.build=="simulator" else "tx16s"
        available=run(root,"cmake","--list-presets")
        if not re.search(r'"'+preset+r'"',available):
            die("Pinned source lacks documented preset; no fallback guessed")
        config=["cmake","--preset",preset]
        if preset=="simu":
            config+=["-DPCB=X10","-DPCBREV=TX16S"]
        target="simu" if preset=="simu" else "firmware"
        report["build"]="started / unvalidated"
        args.report.write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
        subprocess.run(config,cwd=root,check=True)
        subprocess.run(["cmake","--build","build/"+preset,"--target",target],cwd=root,check=True)
        report["build"]="compiled locally / NOT VALIDATED / DO NOT FLASH"
        args.report.write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    print("Audit:",args.report.resolve())
    print(report["review"])
if __name__=="__main__":
    main()
