#!/usr/bin/env python3
"""Frame raw store screenshots with a marketing headline (no device, no re-capture).

Reads per-locale caption files (mobile/store_captions/<platform>/<locale>.toml), composes
each raw screenshot under a large headline on the Trayzero cream/amber background, and writes
RGB PNGs (no alpha, no timestamps) at the configured canvas size into the fastlane folder
the store tooling reads. Same inputs give byte-identical outputs on the same machine.

Usage (from anywhere):
  python3 mobile/tool/caption_screenshots.py                 # every caption file
  python3 mobile/tool/caption_screenshots.py mobile/store_captions/play/en-US.toml
  python3 mobile/tool/caption_screenshots.py --check         # verify outputs are up to date

Requires ImageMagick 7 (`magick`). Fonts are resolved by ImageMagick name or file path.
"""
from __future__ import annotations

import argparse
import hashlib
import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CAPTIONS = REPO / "mobile" / "store_captions"

# Style, shared by every set (matches the approved App Store header artwork).
BG_TOP, BG_BOTTOM = "#fff9f0", "#f5d7c0"
INK = "#462d23"            # headline colour; ~12:1 contrast on the background
FRAME = "#d9b99f"          # thin outline around the UI
SHADOW = "rgba(112,60,33,0.20)"
FONT = "Helvetica-Bold"
CAPTION_BAND = 0.215       # top share of the canvas reserved for the headline
BOTTOM_MARGIN = 0.035      # share of canvas height below the UI
POINTSIZE = 0.083          # headline size as a share of canvas width
TEXT_WIDTH = 0.88          # max headline width as a share of canvas width
MAX_LINES = 2


def magick(*args: str) -> str:
    r = subprocess.run(["magick", *args], capture_output=True, text=True)
    if r.returncode:
        raise SystemExit(f"magick failed: {r.stderr.strip()}\n  args: {args}")
    return r.stdout


def text_arg(s: str) -> str:
    """Escape ImageMagick's caption: specials (% escapes, leading @ reads a file)."""
    s = s.replace("\\", "\\\\").replace("%", "%%")
    return "\\" + s if s.startswith("@") else s


def render(src: Path, out: Path, headline: str, W: int, H: int, font: str, tmp: Path) -> None:
    pt = round(POINTSIZE * W)
    cap_png = tmp / "caption.png"
    magick("-background", "none", "-fill", INK, "-font", font, "-pointsize", str(pt),
           "-interline-spacing", str(round(-0.06 * pt)), "-gravity", "center",
           "-size", f"{round(TEXT_WIDTH * W)}x", f"caption:{text_arg(headline)}", "-trim", "+repage",
           str(cap_png))
    cw, ch = map(int, magick("identify", "-format", "%w %h", str(cap_png)).split())
    band = round(CAPTION_BAND * H)
    if ch > pt * (MAX_LINES + 0.4) or ch > band * 0.9:
        raise SystemExit(f"{out.name}: headline wraps past {MAX_LINES} lines: {headline!r}")

    sw0, sh0 = map(int, magick("identify", "-format", "%w %h", str(src)).split())
    sh = H - band - round(BOTTOM_MARGIN * H)
    sw = round(sh * sw0 / sh0)
    if sw > W * 0.92:
        raise SystemExit(f"{src.name}: source aspect too wide for a {W}x{H} canvas")
    x0, y0 = (W - sw) // 2, band
    x1, y1 = x0 + sw - 1, y0 + sh - 1
    r = round(0.045 * sw)
    off = round(0.006 * H)
    cy = max(round(0.03 * H), (band - ch) // 2 + round(0.006 * H))

    magick(
        "-size", f"{W}x{H}", f"gradient:{BG_TOP}-{BG_BOTTOM}",
        # headline
        str(cap_png), "-gravity", "north", "-geometry", f"+0+{cy}", "-compose", "over", "-composite",
        # soft drop shadow
        "(", "-size", f"{W}x{H}", "xc:none", "-fill", SHADOW,
        "-draw", f"roundrectangle {x0},{y0 + off},{x1},{y1 + off},{r},{r}", "-blur", f"0x{round(0.01 * H)}", ")",
        "-gravity", "northwest", "-geometry", "+0+0", "-compose", "over", "-composite",
        # raw UI with rounded corners, scaled without changing aspect
        "(", str(src), "-resize", f"{sw}x{sh}!", "-alpha", "set",
        "(", "-size", f"{sw}x{sh}", "xc:none", "-fill", "white",
        "-draw", f"roundrectangle 0,0,{sw - 1},{sh - 1},{r},{r}", ")",
        "-compose", "DstIn", "-composite", ")",
        "-gravity", "northwest", "-geometry", f"+{x0}+{y0}", "-compose", "over", "-composite",
        # hairline frame
        "-fill", "none", "-stroke", FRAME, "-strokewidth", str(max(2, round(W / 440))),
        "-draw", f"roundrectangle {x0},{y0},{x1},{y1},{r},{r}",
        "-background", BG_BOTTOM, "-alpha", "remove", "-alpha", "off", "-strip",
        "-define", "png:exclude-chunks=date,time", "-define", "png:color-type=2",
        f"PNG24:{out}",
    )


def load(cfg_path: Path) -> dict:
    cfg = tomllib.loads(cfg_path.read_text(encoding="utf-8"))
    for key in ("source_dir", "output_dir", "canvas", "screens"):
        if key not in cfg:
            raise SystemExit(f"{cfg_path}: missing {key}")
    return cfg


def build(cfg_path: Path, check: bool) -> list[str]:
    cfg = load(cfg_path)
    W, H = cfg["canvas"]
    src_dir, out_dir = REPO / cfg["source_dir"], REPO / cfg["output_dir"]
    font = cfg.get("font", FONT)
    problems = []
    with tempfile.TemporaryDirectory() as t:
        tmp = Path(t)
        if not check:
            out_dir.mkdir(parents=True, exist_ok=True)
        for s in cfg["screens"]:
            src, out = src_dir / s["source"], out_dir / s["output"]
            if not src.is_file():
                raise SystemExit(f"{cfg_path.name}: missing source {src}")
            target = tmp / s["output"] if check else out
            render(src, target, s["headline"].strip(), W, H, font, tmp)
            if check:
                same = out.is_file() and hashlib.sha256(out.read_bytes()).digest() == \
                    hashlib.sha256(target.read_bytes()).digest()
                if not same:
                    problems.append(f"stale or missing: {out.relative_to(REPO)}")
            else:
                print(f"{out.relative_to(REPO)}  {W}x{H}  {s['headline'].strip()!r}")
    return problems


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("configs", nargs="*", type=Path, help="caption .toml files (default: all)")
    ap.add_argument("--check", action="store_true", help="re-render to a temp dir and compare; exit 1 if stale")
    a = ap.parse_args(argv)
    cfgs = [p.resolve() for p in a.configs] or sorted(CAPTIONS.glob("*/*.toml"))
    problems = [p for c in cfgs for p in build(c, a.check)]
    for p in problems:
        print(p, file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
