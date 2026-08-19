#!/usr/bin/env python3

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from portage.versions import vercmp


def nvchecker_versions(config, keyfile):
    tmp_key = None

    if keyfile is None:
        with tempfile.NamedTemporaryFile(
            suffix=".toml",
            mode="w",
            delete=False,
        ) as f:
            f.write("[keys]\n")
            tmp_key = keyfile = f.name

    try:
        proc = subprocess.run(
            ["nvchecker", "-c", config, "-k", keyfile, "--logger", "json"],
            capture_output=True,
            text=True,
        )

        versions = {}

        for line in (proc.stdout + proc.stderr).splitlines():
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            if "name" in obj and "version" in obj:
                name = str(obj["name"])
                version = str(obj["version"])
                versions[name] = normalize_version(name, version)

        return versions

    finally:
        if tmp_key:
            os.unlink(tmp_key)


def strip_pkgrel(v):
    parts = v.rsplit("-", 1)

    if len(parts) == 2 and parts[1].isdigit():
        return parts[0]

    return v


def normalize_version(name, v):
    v = strip_pkgrel(v)

    # AUR packages phoenix-arch and dove expose versions such as
    # 202608171, while the corresponding Gentoo ebuilds use
    # 2026.08.17.1.
    if name in {"firefox-phoenix", "thunderbird-dove"}:
        m = re.fullmatch(r"(\d{4})(\d{2})(\d{2})(\d+)", v)

        if m:
            return f"{m.group(1)}.{m.group(2)}.{m.group(3)}.{m.group(4)}"

    return v


EBUILD_RE = re.compile(r"^.+?-(\d[\w.]*)(?:-r\d+)?\.ebuild$")

SKIP = frozenset({
    "metadata",
    "profiles",
    "eclass",
    "licenses",
    "sets",
    ".git",
    "files",
})


def ebuild_versions(overlay):
    found = {}

    for eb in Path(overlay).rglob("*.ebuild"):
        parts = eb.relative_to(overlay).parts

        if len(parts) != 3:
            continue

        cat, pkg, fname = parts

        if cat in SKIP:
            continue

        m = EBUILD_RE.match(fname)

        if not m:
            continue

        ver = m.group(1)

        if ver == "9999":
            continue

        if pkg not in found or ver_gt(ver, found[pkg]):
            found[pkg] = ver

    return found


def ver_gt(a, b):
    result = vercmp(a, b)

    if result is not None:
        return result > 0

    def key(v):
        return [
            (0, int(p)) if p.isdigit() else (1, p)
            for p in re.split(r"[._-]", v)
        ]

    try:
        return key(a) > key(b)
    except TypeError:
        return a > b


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-c", "--config", default="nvchecker.toml")
    ap.add_argument("-d", "--overlay", default=".")
    ap.add_argument("-k", "--keyfile", default=None)

    args = ap.parse_args()

    upstream = nvchecker_versions(args.config, args.keyfile)

    if not upstream:
        sys.exit("no versions from nvchecker")

    overlay = ebuild_versions(args.overlay)

    outdated = []
    ok = []
    missing = []

    for name, up in sorted(upstream.items()):
        cur = overlay.get(name) or next(
            (
                v
                for k, v in overlay.items()
                if k.lower() == name.lower()
            ),
            None,
        )

        if cur is None:
            missing.append((name, up))
        elif ver_gt(up, cur):
            outdated.append((name, cur, up))
        else:
            ok.append((name, cur))

    if outdated:
        print("outdated:")

        for name, cur, up in outdated:
            print(f"  {name}: {cur} -> {up}")

    if ok:
        print("ok:")

        for name, cur in ok:
            print(f"  {name}: {cur}")

    if missing:
        print("no ebuild:")

        for name, up in missing:
            print(f"  {name}: {up}")

    sys.exit(len(outdated))


if __name__ == "__main__":
    main()
