#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Location-aware `colmena apply --reboot` orchestrator for this flake's hive.

colmena's own `--on`/`-p` only support one global parallelism limit, but this fleet
needs per-location concurrency plus two ordering constraints colmena can't express:

  * `ca-work` is the only colmena host that builds the `leaf` package from source
    (modules/leaf.nix) and pushes it to the shared id-attic binary cache that every
    host substitutes from (modules/shared.nix). It runs alone, first, to warm that
    cache before anything else starts building.
  * `id-attic` runs the binary cache server itself (services.atticd). Rebooting it
    briefly interrupts the cache, so it runs alone, last, after everything else has
    finished deploying.

Everything else is grouped by the flake's `ca`/`id` deployment tags and deployed
concurrently, with a per-group parallelism limit.
"""

import argparse
import asyncio
import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

LEAF_BUILD_HOST = "ca-work"
CACHE_HOST = "id-attic"

# Hosts that exist in the flake but aren't reliably up (e.g. usually powered off).
# Edit this set to persistently skip them, or use --skip/--include for a one-off run.
DISABLED_HOSTS: set[str] = {"nixpi", "ca-meshview"}

CA_CONCURRENCY = 2
ID_CONCURRENCY = 3
UNGROUPED_CONCURRENCY = 0  # 0 = unlimited, per `colmena apply -p`

# Harmless noise from colmena's ssh-ng builders-use-substitutes workaround
# (colmena passes --builders-use-substitutes to `nix copy` to route around a
# ssh-ng UX bug; the remote daemon rejects it as a restricted setting every
# RPC, flooding output without affecting the deploy). Filter it out.
SUPPRESSED_LINE_SUBSTRINGS = [
    "ignoring the client-specified setting 'builders-use-substitutes'",
]


def _is_suppressed(line: str) -> bool:
    return any(s in line for s in SUPPRESSED_LINE_SUBSTRINGS)


def discover_tags() -> dict[str, list[str]]:
    result = subprocess.run(
        [
            "nix",
            "eval",
            ".#colmenaHive.nodes",
            "--apply",
            "nodes: builtins.mapAttrs (n: v: v.config.deployment.tags) nodes",
            "--json",
        ],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)


def build_groups(tags: dict[str, list[str]]) -> tuple[list[str], list[str], list[str]]:
    ca_hosts = sorted(h for h, t in tags.items() if "ca" in t and h != LEAF_BUILD_HOST)
    id_hosts = sorted(h for h, t in tags.items() if "id" in t and h != CACHE_HOST)
    ungrouped = sorted(
        h
        for h, t in tags.items()
        if "ca" not in t and "id" not in t and h not in (LEAF_BUILD_HOST, CACHE_HOST)
    )
    return ca_hosts, id_hosts, ungrouped


def colmena_cmd(hosts: list[str], parallel: int | None = None, verbose: bool = False) -> list[str]:
    cmd = ["colmena", "apply", "--reboot"]
    if verbose:
        cmd.append("--verbose")
    cmd += ["--on", ",".join(hosts)]
    if parallel is not None:
        cmd += ["-p", str(parallel)]
    return cmd


def run_solo(label: str, cmd: list[str], dry_run: bool) -> int:
    print(f"[{label}] $ {' '.join(cmd)}", flush=True)
    if dry_run:
        return 0
    proc = subprocess.Popen(
        cmd,
        cwd=REPO_ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    assert proc.stdout is not None
    for line in proc.stdout:
        if _is_suppressed(line):
            continue
        print(line, end="", flush=True)
    return proc.wait()


async def run_group(label: str, cmd: list[str], dry_run: bool) -> int:
    print(f"[{label}] $ {' '.join(cmd)}", flush=True)
    if dry_run:
        return 0
    proc = await asyncio.create_subprocess_exec(
        *cmd,
        cwd=REPO_ROOT,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.STDOUT,
    )
    assert proc.stdout is not None
    async for raw in proc.stdout:
        line = raw.decode(errors="replace").rstrip()
        if _is_suppressed(line):
            continue
        print(f"[{label}] {line}", flush=True)
    return await proc.wait()


async def main_async(dry_run: bool, disabled: set[str]) -> int:
    tags = discover_tags()
    if disabled:
        print(f"skipping disabled hosts: {sorted(disabled)}")
        tags = {h: t for h, t in tags.items() if h not in disabled}
    ca_hosts, id_hosts, ungrouped = build_groups(tags)

    leaf_build_host = LEAF_BUILD_HOST if LEAF_BUILD_HOST in tags else None
    cache_host = CACHE_HOST if CACHE_HOST in tags else None

    print("Discovered groups:")
    print(f"  phase 1 (leaf build, solo):  {leaf_build_host}")
    print(f"  phase 2 ca   (-p {CA_CONCURRENCY}):        {ca_hosts}")
    print(f"  phase 2 id   (-p {ID_CONCURRENCY}):        {id_hosts}")
    print(f"  phase 2 rest (-p unlimited): {ungrouped}")
    print(f"  phase 3 (cache host, solo):  {cache_host}")
    print()

    if leaf_build_host is None:
        print(f"{LEAF_BUILD_HOST} is disabled; skipping phase 1.")
    else:
        rc = run_solo("phase1", colmena_cmd([leaf_build_host]), dry_run)
        if rc != 0:
            print(f"phase 1 ({leaf_build_host}) failed with exit code {rc}; aborting.")
            return rc

    phase2 = []
    if ca_hosts:
        phase2.append(("ca", colmena_cmd(ca_hosts, parallel=CA_CONCURRENCY, verbose=True)))
    if id_hosts:
        phase2.append(("id", colmena_cmd(id_hosts, parallel=ID_CONCURRENCY, verbose=True)))
    if ungrouped:
        phase2.append(
            ("ungrouped", colmena_cmd(ungrouped, parallel=UNGROUPED_CONCURRENCY, verbose=True))
        )

    results = await asyncio.gather(*(run_group(label, cmd, dry_run) for label, cmd in phase2))
    failed = [label for (label, _), rc in zip(phase2, results) if rc != 0]
    if failed:
        print(f"phase 2 groups failed: {', '.join(failed)}; skipping phase 3 ({CACHE_HOST}).")
        return 1

    if cache_host is None:
        print(f"{CACHE_HOST} is disabled; skipping phase 3.")
        return 0

    rc = run_solo("phase3", colmena_cmd([cache_host]), dry_run)
    if rc != 0:
        print(f"phase 3 ({cache_host}) failed with exit code {rc}.")
        return rc

    print("all phases completed successfully.")
    return 0


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        "--dry-run", action="store_true", help="print planned groups and commands without executing"
    )
    parser.add_argument(
        "--skip", default="", help="comma-separated extra hosts to exclude for this run"
    )
    parser.add_argument(
        "--include",
        default="",
        help="comma-separated hosts to force-include even if in DISABLED_HOSTS",
    )
    args = parser.parse_args()

    disabled = DISABLED_HOSTS | {h for h in args.skip.split(",") if h}
    disabled -= {h for h in args.include.split(",") if h}

    sys.exit(asyncio.run(main_async(args.dry_run, disabled)))


if __name__ == "__main__":
    main()
