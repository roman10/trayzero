# Store screenshot captions

Marketing headlines for the store screenshots, added in a post-capture framing step. The step
needs no device, emulator, or simulator. Each raw capture (real app UI, fictional data) is scaled
without changing its aspect ratio and placed under one large headline on the Trayzero cream and
amber background.

| path | what |
|---|---|
| `play/<locale>.toml` | Google Play captions: raw source folder, fastlane output folder, canvas size, one `headline` per screenshot |
| `ios/<locale>.toml` | App Store captions, in the same format |
| `../tool/caption_screenshots.py` | renderer (Python 3.11+ and ImageMagick 7 `magick`) |

Current sets:

| set | raw source | output (what fastlane and `aso ocr` read) | size |
|---|---|---|---|
| `play/en-US` | `docs/mobile/play-store-listing/releases/1.0.8-52/` | `mobile/fastlane/metadata/android/en-US/images/phoneScreenshots/` | 1080×1920 (9:16) |
| `ios/en-US` | `docs/app-store-listing/releases/1.0.8-52/iphone-6.9/` | `mobile/ios/fastlane/screenshots/en-US/` | 1320×2868 (6.9-inch iPhone) |

en-GB on the App Store inherits the en-US screenshots. No other locale has its own screenshots yet.

## Render and check

```bash
python3 mobile/tool/caption_screenshots.py            # render every set
python3 mobile/tool/caption_screenshots.py mobile/store_captions/play/en-US.toml
python3 mobile/tool/caption_screenshots.py --check    # exit 1 if any output is stale
~/startup/aso/bin/aso ocr trayzero                    # OCR the outputs against aso/targets/
```

The output is deterministic: the same inputs give byte-identical RGB PNGs (no alpha, no
timestamp chunks). The renderer fails if a headline wraps past two lines or if a source image is
too wide for the canvas. Fonts come from ImageMagick (default `Helvetica-Bold`). For CJK
locales, set `font = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"` (or another file path)
in that locale's TOML.

## Writing captions

- Write one benefit headline per screenshot, about 2 to 6 words. Use a `\n` to control the
  break across two lines.
- The headline must describe what that screenshot actually shows. No AI, sync, sharing or
  ranking claims (see `aso/decisions/`).
- Take keywords from the storefront's `aso/targets/<cc>.txt` (the locale-to-storefront map is
  `STOREFRONT_LOCALES` in the toolkit's `aso/lint.py`). Work them in naturally and never as a
  list. Write non-English captions natively, not as literal translations, and have a native
  speaker review them.
- Apple reportedly OCR-indexes caption text (vendor-reported, unverified). On Play, captions
  affect conversion only.

## Add a locale

1. Capture raw screenshots for the locale with the existing harness (see the Play and App Store
   listing READMEs) into a docs folder.
2. Copy `play/en-US.toml` or `ios/en-US.toml` to `<platform>/<locale>.toml`. Point
   `source_dir` and `output_dir` at the locale, then write the headlines.
3. Render, run `aso ocr trayzero --platform <platform>`, and view the PNGs before committing.

## Revert to raw screenshots

The raw captures stay unchanged in their docs folders. To ship uncaptioned screenshots,
`git revert` the caption commit. Alternatively, copy the raw PNGs back into the output folder
and delete the matching TOML.

Rendering only writes files. Nothing is uploaded. If you use fastlane `supply` or `deliver` for
listing text only, pass `--skip_upload_screenshots` / `skip_screenshots`. Otherwise these
folders are uploaded.
