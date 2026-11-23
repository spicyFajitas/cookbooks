#!/usr/bin/env python3
"""Email when the latest published version of a watched Ubuntu package changes.

Reads the watch list from PACKAGES_FILE, asks Launchpad for each package's
published sources in the Ubuntu primary archive, and emails one report
covering every package whose newest matching version differs from the last
run's. Ubuntu Pro (ESM/FIPS/Livepatch) kernels live in separate private
archives, never the primary one, so they're never seen here.
"""

import json
import os
import smtplib
import sys
import urllib.parse
import urllib.request
from email.message import EmailMessage

LP_API = "https://api.launchpad.net/1.0"
DEFAULT_POCKETS = ["Release", "Security", "Updates"]

PACKAGES_FILE = os.environ.get("PACKAGES_FILE", "/config/packages.json")
STATE_FILE = os.environ.get("STATE_FILE", "/state/state.json")


def _order(c):
    if c == "~":
        return -1
    if c.isdigit():
        return 0
    if c.isalpha():
        return ord(c)
    return ord(c) + 256


def _cmp_part(a, b):
    ia = ib = 0
    while ia < len(a) or ib < len(b):
        while (ia < len(a) and not a[ia].isdigit()) or (ib < len(b) and not b[ib].isdigit()):
            ca = _order(a[ia]) if ia < len(a) and not a[ia].isdigit() else 0
            cb = _order(b[ib]) if ib < len(b) and not b[ib].isdigit() else 0
            if ca != cb:
                return ca - cb
            ia += 1
            ib += 1
        ja, jb = ia, ib
        while ja < len(a) and a[ja].isdigit():
            ja += 1
        while jb < len(b) and b[jb].isdigit():
            jb += 1
        diff = int(a[ia:ja] or 0) - int(b[ib:jb] or 0)
        if diff:
            return diff
        ia, ib = ja, jb
    return 0


def debian_version_cmp(a, b):
    """dpkg --compare-versions semantics: <0, 0, >0."""

    def split(v):
        epoch, _, rest = v.partition(":") if ":" in v else ("0", "", v)
        upstream, _, revision = rest.rpartition("-") if "-" in rest else (rest, "", "0")
        return int(epoch or 0), upstream, revision

    ea, ua, ra = split(a)
    eb, ub, rb = split(b)
    return (ea - eb) or _cmp_part(ua, ub) or _cmp_part(ra, rb)


def lp_get(url):
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.load(resp)


def latest_version(pkg):
    params = {
        "ws.op": "getPublishedSources",
        "source_name": pkg["name"],
        "exact_match": "true",
        "distro_series": f"{LP_API}/ubuntu/{pkg['series']}",
        "status": "Published",
    }
    url = f"{LP_API}/ubuntu/+archive/primary?{urllib.parse.urlencode(params)}"
    pockets = set(pkg.get("pockets", DEFAULT_POCKETS))
    prefix = pkg.get("version_prefix", "")

    best = None
    while url:
        page = lp_get(url)
        for entry in page["entries"]:
            version = entry["source_package_version"]
            if entry["pocket"] not in pockets or not version.startswith(prefix):
                continue
            if best is None or debian_version_cmp(version, best["version"]) > 0:
                best = {
                    "version": version,
                    "pocket": entry["pocket"],
                    "published": entry["date_published"],
                }
        url = page.get("next_collection_link")
    return best


def package_key(pkg):
    return f"{pkg['name']}/{pkg['series']}/{pkg.get('version_prefix', '')}"


def load_json(path, default):
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return default


def send_email(subject, body):
    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = os.environ.get("MAIL_FROM", os.environ["SMTP_USERNAME"])
    msg["To"] = os.environ["MAIL_TO"]
    msg.set_content(body)

    host = os.environ.get("SMTP_HOST", "smtp.gmail.com")
    port = int(os.environ.get("SMTP_PORT", "587"))
    with smtplib.SMTP(host, port, timeout=60) as smtp:
        smtp.starttls()
        smtp.login(os.environ["SMTP_USERNAME"], os.environ["SMTP_PASSWORD"])
        smtp.send_message(msg)


def main():
    packages = load_json(PACKAGES_FILE, None)
    if not packages:
        sys.exit(f"no packages configured in {PACKAGES_FILE}")

    state = load_json(STATE_FILE, {})
    changes = []
    errors = []

    for pkg in packages:
        key = package_key(pkg)
        try:
            latest = latest_version(pkg)
        except Exception as e:  # one bad package shouldn't hide the rest
            errors.append(f"{key}: {e}")
            continue
        if latest is None:
            errors.append(f"{key}: no published version matches")
            continue

        previous = state.get(key, {}).get("version")
        print(f"{key}: latest={latest['version']} previous={previous}")
        if latest["version"] != previous:
            changes.append((key, previous, latest))
            state[key] = latest

    for err in errors:
        print(f"ERROR {err}", file=sys.stderr)

    if not changes:
        print("no changes, not emailing")
        sys.exit(1 if errors else 0)

    lines = ["Ubuntu package updates detected:", ""]
    for key, previous, latest in changes:
        lines += [
            f"{key}",
            f"  latest:    {latest['version']} ({latest['pocket']}, published {latest['published']})",
            f"  previous:  {previous or '(first run)'}",
            "",
        ]
    if errors:
        lines += ["Errors:"] + [f"  {e}" for e in errors]

    names = ", ".join(f"{k.split('/')[0]} {l['version']}" for k, _, l in changes)
    send_email(f"[kernel-watch] {names}", "\n".join(lines))
    print(f"emailed {len(changes)} change(s)")

    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    tmp = f"{STATE_FILE}.tmp"
    with open(tmp, "w") as f:
        json.dump(state, f, indent=2, sort_keys=True)
    os.replace(tmp, STATE_FILE)

    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
