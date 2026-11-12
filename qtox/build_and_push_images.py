#!/usr/bin/env python3
# /// script
# dependencies = ["pyyaml"]
# ///
"""Builds the qTox images as .github/workflows/docker.yml does, and pushes
each one while the next one builds.

Usage: qtox/build_and_push_images.py [--dry-run] [image...]
  With no images, all of them. Names are the tags after "qtox:", e.g.
  host-qt_6.12.0, alpine, android-builder.arm64-v8a.release_6.2.4.
"""
import argparse
import itertools
import pathlib
import re
import subprocess
import sys
from typing import Any

import yaml

QTOX = pathlib.Path(__file__).resolve().parent
WORKFLOW = QTOX.parent / ".github" / "workflows" / "docker.yml"
CONTEXT = "{{defaultContext}}:qtox"

Matrix = dict[str, Any]


def expand(matrix: Matrix) -> list[Matrix]:
    """A strategy matrix's combinations, with its include entries, as
    GitHub Actions makes them."""
    axes = {k: v for k, v in matrix.items() if k not in ("include", "exclude")}
    combos = [dict(zip(axes, values)) for values in itertools.product(*axes.values())]
    for extra in matrix.get("include", []):
        matching = [c for c in combos
                    if all(c[k] == v for k, v in extra.items() if k in axes)]
        if not matching:
            combos.append(dict(extra))
        for combo in matching:
            combo.update({k: v for k, v in extra.items() if k not in axes})
    return combos


def evaluate(text: str, scope: dict[str, Matrix]) -> str:
    """The workflow's ${{ a.b || c.d }} expressions, as far as these jobs
    use them."""
    def value(match: re.Match[str]) -> str:
        for name in match.group(1).split("||"):
            context, key = name.strip().split(".", 1)
            found = scope.get(context, {}).get(key)
            if found:
                return str(found)
        return ""

    return re.sub(r"\$\{\{(.*?)\}\}", value, text)


def ordered_jobs(jobs: dict[str, Any]) -> list[str]:
    """The jobs that build qTox images, each after those it needs."""
    done: list[str] = []

    def visit(name: str) -> None:
        if name in done:
            return
        needs = jobs[name].get("needs", [])
        for need in [needs] if isinstance(needs, str) else needs:
            visit(need)
        done.append(name)

    for name, job in jobs.items():
        if build_step(job):
            visit(name)
    return [name for name in done if build_step(jobs[name])]


def build_step(job: dict[str, Any]) -> dict[str, Any] | None:
    for step in job.get("steps", []):
        if step.get("with", {}).get("context") == CONTEXT:
            return step["with"]
    return None


def images() -> list[tuple[str, list[str]]]:
    """Each image's tag and the docker build arguments that make it."""
    workflow = yaml.safe_load(WORKFLOW.read_text())
    env = workflow.get("env", {})
    result = []
    for name in ordered_jobs(workflow["jobs"]):
        job = workflow["jobs"][name]
        step = build_step(job)
        matrix = job.get("strategy", {}).get("matrix", {})
        for combo in expand(matrix) if matrix else [{}]:
            scope = {"env": env, "matrix": combo}
            tag = evaluate(step["tags"], scope)
            command = ["-f", evaluate(step["file"], scope), "-t", tag]
            for arg in evaluate(step.get("build-args", ""), scope).split("\n"):
                if arg.strip():
                    command += ["--build-arg", arg.strip()]
            result.append((tag, command + ["."]))
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true",
                        help="print the docker commands instead of running them")
    parser.add_argument("images", nargs="*")
    args = parser.parse_args()

    selected = images()
    if args.images:
        names = {tag.rsplit(":", 1)[1]: tag for tag, _ in selected}
        unknown = set(args.images) - names.keys()
        if unknown:
            sys.exit(f"unknown images: {' '.join(sorted(unknown))}")
        selected = [(tag, cmd) for tag, cmd in selected
                    if tag.rsplit(":", 1)[1] in args.images]

    def docker(*command: str) -> subprocess.Popen[bytes] | None:
        print("+ docker", " ".join(command), flush=True)
        if args.dry_run:
            return None
        return subprocess.Popen(["docker", *command], cwd=QTOX)

    def wait(what: str, process: subprocess.Popen[bytes] | None) -> int:
        code = process.wait() if process else 0
        if code:
            print(f"{what} failed (docker exited with {code})", file=sys.stderr)
        return code

    # One push at a time, quietly, as the build's output goes on.
    pushing: tuple[str, subprocess.Popen[bytes] | None] | None = None
    for tag, command in selected:
        built = wait(f"building {tag}", docker("build", *command))
        pushed = wait(f"pushing {pushing[0]}", pushing[1]) if pushing else 0
        if built or pushed:
            sys.exit(1)
        pushing = (tag, docker("push", "--quiet", tag))
    if pushing and wait(f"pushing {pushing[0]}", pushing[1]):
        sys.exit(1)

if __name__ == "__main__":
    main()
