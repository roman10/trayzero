#!/usr/bin/env python3
"""Capture an unscaled Duo framebuffer after the native verification gate passes.

Uses the selected Xcode. Requires Pillow for image validation. Never uploads.
"""

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import plistlib
import re
import subprocess
import sys

from PIL import Image


def run(*args):
    return subprocess.check_output(args, text=True).strip()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def version(text):
    match = re.search(r"(\d+)\.(\d+)", text)
    require(match is not None, f"Cannot parse version: {text}")
    return tuple(map(int, match.groups()))


def app_code_sha256(app):
    digest = hashlib.sha256()
    for relative in ["Runner", "Runner.debug.dylib", "Frameworks/App.framework/App",
                     "Frameworks/App.framework/flutter_assets/kernel_blob.bin"]:
        file = app / relative
        if file.is_file():
            digest.update(relative.encode())
            digest.update(file.read_bytes())
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True, help="Exact booted Duo simulator UDID")
    parser.add_argument("--display", required=True, help="Display ID from simctl io UDID enumerate")
    parser.add_argument("--surface", choices=["outer", "inner"], required=True)
    parser.add_argument("--verification", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True, help="New .jpg filename")
    parser.add_argument("--bundle-id", default="app.cleartray")
    args = parser.parse_args()

    xcode = run("xcodebuild", "-version")
    require(version(xcode) >= (27, 1), "Xcode 27.1 or later is required; found " + xcode)
    verification = json.loads(args.verification.read_text())
    require(verification.get("native_duo_verified") is True,
            "Native Duo audit is incomplete; capture is gated on verification.")
    listing = json.loads(run("xcrun", "simctl", "list", "devices", "available", "--json"))
    matches = [(runtime, device) for runtime, devices in listing["devices"].items()
               for device in devices if device["udid"] == args.device]
    require(len(matches) == 1, "Exact simulator UDID was not found.")
    runtime, device = matches[0]
    require(device["state"] == "Booted", "Boot the simulator before capturing.")
    require("iphone-duo" in device.get("deviceTypeIdentifier", "").lower(),
            "Capture requires the genuine iPhone Duo simulator device type.")
    require(verification.get("device_udid") == args.device,
            "The verification record must identify this simulator.")
    app = Path(run("xcrun", "simctl", "get_app_container", args.device, args.bundle_id, "app"))
    with (app / "Info.plist").open("rb") as stream:
        info = plistlib.load(stream)
    sdk = info.get("DTSDKName", "")
    require(sdk.startswith("iphonesimulator") and version(sdk) >= (27, 1),
            "The installed app must be rebuilt with the iOS 27.1 SDK or later.")
    build = f"{info['CFBundleShortVersionString']} ({info['CFBundleVersion']})"
    require(verification.get("build") == build, "Installed app differs from the verified build.")
    executable_sha256 = hashlib.sha256((app / info['CFBundleExecutable']).read_bytes()).hexdigest()
    require(verification.get("executable_sha256") == executable_sha256,
            "Installed executable differs from the verified binary.")
    code_sha256 = app_code_sha256(app)
    require(verification.get("app_code_sha256") == code_sha256,
            "Installed native/Dart code differs from the verified app.")
    require(args.output.suffix.lower() == ".jpg", "Use .jpg; native JPEG has no alpha channel.")
    receipt = args.output.with_suffix(".json")
    require(not args.output.exists() and not receipt.exists(), "Refusing to overwrite an existing capture.")
    enumeration = run("xcrun", "simctl", "io", args.device, "enumerate")
    display_enumeration = "\nPort:".join(
        port for port in enumeration.split("\nPort:")
        if "Class: Display\n" in port or "Class: DisplayAdapter\n" in port
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    # Capture to a staging file so failed validation never creates a store asset.
    staging = args.output.with_suffix(".pending.jpg")
    require(not staging.exists(), "A pending capture already exists; inspect it first.")
    subprocess.run(["xcrun", "simctl", "io", args.device, "screenshot",
                    "--type=jpeg", f"--display={args.display}", str(staging)], check=True)
    with Image.open(staging) as image:
        allowed = {"outer": {(1398, 2034), (2034, 1398)},
                   "inner": {(2007, 2853), (2853, 2007)}}
        require(image.size in allowed[args.surface],
                f"Unexpected {args.surface} framebuffer size {image.size}; no resizing is allowed.")
        require(image.mode == "RGB", f"Expected opaque RGB, got {image.mode}.")
        require(any(high - low > 8 for low, high in image.getextrema()),
                "Capture appears blank. Wait for Duo framebuffer initialization, then retry.")
        dimensions = image.size
    evidence = {
        "status": "captured_pending_visual_review",
        "captured_at": datetime.now(timezone.utc).isoformat(),
        "device": device, "runtime": runtime, "display": args.display,
        "surface": args.surface, "dimensions": dimensions,
        "xcode": xcode, "sdk": sdk, "build": build,
        "bundle_id": args.bundle_id,
        "executable_sha256": executable_sha256,
        "app_code_sha256": code_sha256,
        "verification_sha256": hashlib.sha256(args.verification.read_bytes()).hexdigest(),
        "sha256": hashlib.sha256(staging.read_bytes()).hexdigest(),
        "display_enumeration": display_enumeration,
        "transformations": [], "uploaded": False,
    }
    receipt.write_text(json.dumps(evidence, indent=2) + "\n")
    staging.rename(args.output)
    print(f"Captured {args.output}: {dimensions[0]}×{dimensions[1]}; visual review remains required.")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, subprocess.CalledProcessError, OSError, KeyError) as error:
        sys.exit(f"Capture stopped: {error}")
