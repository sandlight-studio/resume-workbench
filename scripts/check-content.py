#!/usr/bin/env python3
"""Validate hard Markdown contracts for every resume variant.

Variant discovery stays in config/variants.sh; this script only enforces
the structural contract each variant's Markdown must satisfy.
"""

from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path


CN_SECTIONS = (
    "## 岗位优势",
    "## 工作经历",
    "## 项目经历",
    "## 技术能力",
    "## 教育背景",
    "## 自我评价",
)
EN_SECTIONS = (
    "## Professional Summary",
    "## Work Experience",
    "## Selected Projects",
    "## Technical Skills",
    "## Education",
)
CN_DATE_RE = re.compile(r"^\d{4}\.\d{2} - ")
EN_DATE_RE = re.compile(r"^[A-Z][a-z]{2} \d{4} - ")
PLACEHOLDER_RE = re.compile(r"\{\{[^}]+\}\}|【待填】|【待核实】|\[DATA NEEDED", re.I)


def discover_variants(root: Path) -> list[tuple[str, str, str]]:
    """Return (key, source_file, output_mode) tuples from config/variants.sh."""
    probe = (
        'source "$1/config/variants.sh"; '
        'for variant in "${RESUME_VARIANTS[@]}"; do '
        'resolve_variant "${variant}" '
        '&& printf "%s|%s|%s\\n" "${variant}" "${SOURCE_FILE}" "${OUTPUT_MODE}"; '
        "done"
    )
    result = subprocess.run(
        ["bash", "-c", probe, "bash", str(root)],
        capture_output=True,
        text=True,
        check=True,
    )
    variants: list[tuple[str, str, str]] = []
    for line in result.stdout.splitlines():
        key, source_file, output_mode = line.split("|")
        variants.append((key, source_file, output_mode))
    return variants


def validate_sections(lines: list[str], sections: tuple[str, ...], label: str) -> list[str]:
    positions: list[int] = []
    errors: list[str] = []
    for section in sections:
        try:
            positions.append(lines.index(section))
        except ValueError:
            errors.append(f"{label}: missing section '{section}'")
    if not errors and positions != sorted(positions):
        errors.append(f"{label}: required sections are out of order")
    return errors


def project_blocks(lines: list[str], start: int, end: int) -> list[tuple[int, str, list[str]]]:
    headings = [index for index in range(start + 1, end) if lines[index].startswith("### ")]
    blocks: list[tuple[int, str, list[str]]] = []
    for offset, heading_index in enumerate(headings):
        block_end = headings[offset + 1] if offset + 1 < len(headings) else end
        blocks.append((heading_index, lines[heading_index][4:].strip(), lines[heading_index + 1:block_end]))
    return blocks


def validate_projects(
    lines: list[str],
    section_start: int,
    section_end: int,
    label: str,
    *,
    english: bool,
) -> list[str]:
    errors: list[str] = []
    blocks = project_blocks(lines, section_start, section_end)
    if not blocks:
        return [f"{label}: project section has no project entries"]

    date_re = EN_DATE_RE if english else CN_DATE_RE
    date_hint = "'Jan 2023 - Present | Role'" if english else "'2023.01 - 至今 | 角色'"
    stack_field = "**Stack:**" if english else "**技术栈：**"

    for heading_line, heading, block in blocks:
        project_label = f"{label}:{heading_line + 1} '{heading}'"
        if "|" not in heading:
            errors.append(f"{project_label}: heading must follow 'Project Name | Company'")

        nonempty = [line for line in block if line.strip()]
        if not nonempty:
            errors.append(f"{project_label}: project block is empty")
            continue
        if not date_re.match(nonempty[0]):
            errors.append(f"{project_label}: first field must be a date range such as {date_hint}")
        if not any(line.startswith(stack_field) for line in block):
            errors.append(f"{project_label}: missing {stack_field} field")
        if not any(line.startswith("- ") for line in nonempty[1:]):
            errors.append(f"{project_label}: project needs at least one bullet")
    return errors


def validate_file(path: Path, *, english: bool) -> list[str]:
    label = path.as_posix()
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        return [f"{label}: cannot read file: {exc}"]

    errors: list[str] = []
    lines = text.splitlines()
    if 'class="resume-header"' not in text:
        errors.append(f"{label}: missing resume-header block")
    if PLACEHOLDER_RE.search(text):
        errors.append(f"{label}: contains an unresolved placeholder or verification marker")

    sections = EN_SECTIONS if english else CN_SECTIONS
    section_errors = validate_sections(lines, sections, label)
    errors.extend(section_errors)
    if not section_errors:
        project_section = "## Selected Projects" if english else "## 项目经历"
        skills_section = "## Technical Skills" if english else "## 技术能力"
        errors.extend(validate_projects(
            lines,
            lines.index(project_section),
            lines.index(skills_section),
            label,
            english=english,
        ))
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    root = args.root.resolve()

    errors: list[str] = []
    for key, source_file, output_mode in discover_variants(root):
        path = root / "resume" / source_file
        if not path.is_file():
            errors.append(f"{path.as_posix()}: file not found (variant '{key}')")
            continue
        errors.extend(validate_file(path, english=output_mode == "en"))

    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print("All content contract checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
