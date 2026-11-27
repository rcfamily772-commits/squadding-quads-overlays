"""Rebuild the dashboard offline demo and SD-card download with the standard library."""
import base64
import io
import json
import re
from pathlib import Path
from urllib.parse import urljoin
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

dash = Path(__file__).resolve().parent
version = "1.8.8"
zip_name = f"Squadding-Quads-FPV-Dashboard-v{version}.zip"
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
    html = (dash / "index.html").read_text()
    def embed_style(match):
        path = match[1].split("?")[0]
        return "<style>" + (dash / path).read_text() + "</style>"
    html = re.sub(r'<link rel="stylesheet" href="([^"]+)">', embed_style, html)
    html = html.replace('data-dashboard-root="./"', 'data-pilot="' + url_data("image/png", sprite.read_bytes()) + '"')
    for path, mime in (("grand-prix-92/garage.webp", "image/webp"), ("grand-prix-92/performance.png", "image/png")):
        html = html.replace(f'src="{path}"', 'src="' + url_data(mime, (dash / path).read_bytes()) + '"')

    # The offline file carries its own SD installer. Theme page navigation
    # opens the published site; the local radio simulator works disconnected.
    html = html.replace(f'class="zip-link" href="./{zip_name}" download', 'class="zip-link" href="#download-area"')
    html = html.replace(f'href="./{zip_name}" download', f'href="{url_data("application/zip", archive(radio))}" download="{zip_name}"')
    html = re.sub(r'<a class="offline-link"[^>]*>[^<]*</a>', '', html)
    html = re.sub(r'href="(\./[^"]*)"', lambda m: 'href="' + urljoin(site+"sq-reactor/", m[1]) + '"', html)
    worker = (dash / "preview-worker.js").read_text().replace("importScripts('vendor/fengari.js');", (dash / "vendor/fengari.js").read_text())
    js = (dash / "pilot-dash.js").read_text()
    start = js.index("  [source,adapter]=await")
    end = js.index("  worker.onerror", start)
    js = (js[:start] + "  source=" + json.dumps(lua.read_text()) + ";\n  adapter=" +
          json.dumps((dash / "preview-runtime.lua").read_text()) +
          ";\n  worker=new Worker(URL.createObjectURL(new Blob([" + json.dumps(worker) +
          "],{type:'application/javascript'})));\n" + js[end:])
    html = re.sub(r'<script src="[^"]*pilot-dash.js[^"]*"></script>', lambda _: "<script>" + js.replace("</script", "<\\/script") + "</script>", html)
    offline = dash / "Squadding-Quads-FPV-Dashboard-Offline.html"
    offline.write_text(html)
    (dash / zip_name).write_bytes(archive({**radio, "README.md": (dash / "README.md").read_bytes(), offline.name: offline.read_bytes()}))


if __name__ == "__main__":
    main()
