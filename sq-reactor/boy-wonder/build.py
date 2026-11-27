"""Rebuild the offline demo and v1.8.7 SD-card download with the standard library."""
import base64
import io
import json
import re
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

edition = Path(__file__).resolve().parent
dash = edition.parent
version = "1.8.7"
zip_name = f"SQ-Pilot-Dash-v{version}-Boy-Wonder.zip"
site = "https://rcfamily772-commits.github.io/squadding-quads-overlays/"
lua = dash / "WIDGETS/SQDash/main.lua"
sprite = lua.with_name("pilot.png")


def url_data(mime, content):
    return "data:" + mime + ";base64," + base64.b64encode(content).decode("ascii")


def archive(files):
    dest = io.BytesIO()
    with ZipFile(dest, "w") as out:
        for name, data in files.items():
            info = ZipInfo(name, (2026, 11, 27, 0, 0, 0))
            info.external_attr = 0o100644 << 16
            out.writestr(info, data, compress_type=ZIP_DEFLATED, compresslevel=9)
    return dest.getvalue()


def main():
    radio = {p.relative_to(dash).as_posix(): p.read_bytes() for p in (lua, sprite)}
    html = (edition / "index.html").read_text()
    css = (dash / "style.css").read_text() + "\n" + (edition / "comic.css").read_text()
    html = re.sub(r'<link rel="stylesheet".*?>(?:<link rel="stylesheet".*?>)?', lambda _: "<style>" + css + "</style>", html)
    html = html.replace('data-dashboard-root="../"', 'data-pilot="' + url_data("image/png", sprite.read_bytes()) + '"')
    for name, mime in (("pilot.webp", "image/webp"), ("flight.png", "image/png")):
        html = html.replace(f'src="{name}"', 'src="' + url_data(mime, (edition / name).read_bytes()) + '"')
    html = html.replace('href="../"', f'href="{site}sq-reactor/"').replace('href="../../tools/"', f'href="{site}tools/"')
    html = html.replace(f'href="../{zip_name}" download', f'href="{url_data("application/zip", archive(radio))}" download="{zip_name}"')
    html = html.replace('<a href="Boy-Wonder-Offline.html" download>Offline demo</a> · ', '')
    html = html.replace('href="report.png"', f'href="{site}sq-reactor/boy-wonder/report.png"')
    html = html.replace('href="../SQ-Pilot-Dash-v1.8.5', f'href="{site}sq-reactor/SQ-Pilot-Dash-v1.8.5')
    worker = (dash / "preview-worker.js").read_text().replace("importScripts('vendor/fengari.js');", (dash / "vendor/fengari.js").read_text())
    js = (dash / "pilot-dash.js").read_text()
    start = js.index("  [source,adapter]=await")
    end = js.index("  worker.onerror", start)
    js = (js[:start] + "  source=" + json.dumps(lua.read_text()) + ";\n  adapter=" +
          json.dumps((dash / "preview-runtime.lua").read_text()) +
          ";\n  worker=new Worker(URL.createObjectURL(new Blob([" + json.dumps(worker) +
          "],{type:'application/javascript'})));\n" + js[end:])
    html = re.sub(r'<script src="[^"]*pilot-dash.js[^"]*"></script>', lambda _: "<script>" + js.replace("</script", "<\\/script") + "</script>", html)
    offline = edition / "Boy-Wonder-Offline.html"
    offline.write_text(html)
    (dash / zip_name).write_bytes(archive({**radio, "README.md": (dash / "README.md").read_bytes(), offline.name: offline.read_bytes()}))


if __name__ == "__main__":
    main()
