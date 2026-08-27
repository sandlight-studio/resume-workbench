---
name: add-resume-variant
description: Add a new position-specific resume variant to Resume Workbench (a new entry in config/variants.sh, a new Markdown file under resume/zh/ or resume/en/, an npm build script, and both README command tables). Use this whenever someone wants a resume for a role the repo doesn't cover yet — "add a data engineering resume", "I need a variant for SRE roles", "make a product manager version", "新增一个算法岗简历" — or asks why `npm test` fails after they hand-edited config/variants.sh. The four edits are coupled and the required section names live only in the test suite, so doing this from memory reliably breaks the build.
---

# Add a resume variant

A variant is not a single file. It is one entry that four different places have
to agree on: the variant registry, the Markdown source, the npm script, and the
two README tables. Miss one and either the test suite fails or the variant
exists but nobody can discover it.

Work in this order — each step depends on the one before it.

## 1. Pick the key, slug, and language

- `<key>`: lowercase, no spaces, used on the command line (`data`, `sre`, `pm`).
- `<position>`: the human-readable job title printed during the build and
  embedded in the Chinese PDF filename.
- `<slug>`: ASCII, hyphenated, used in the English PDF filename
  (`Data-Engineer`).
- Language: Chinese variants live in `resume/zh/` and keep the default
  `OUTPUT_MODE="zh"`. English variants live in `resume/en/` and must set
  `OUTPUT_MODE="en"` explicitly, which is what selects `styles/base-en.css`
  and `styles/theme-english.css` in `scripts/build.sh`.

## 2. Register it in `config/variants.sh`

This file is the single source of truth. Two separate edits:

**a. Add `<key>` to the `RESUME_VARIANTS` array.** Three callers iterate over
it — `scripts/check.sh`, `tests/content-structure.sh`, and
`tests/structure-alignment.sh` — so a variant that is missing here is silently
untested even if everything else works.

**b. Add a `case` branch to `resolve_variant()`**, before the `*)` fallback.
Set every field; `scripts/build.sh` reads all of them:

```bash
    data)
      VARIANT_KEY="data"
      SOURCE_FILE="zh/data.md"
      POSITION="数据开发工程师"
      OUTPUT_SLUG="Data-Engineer"
      ;;
```

For an English variant, add `OUTPUT_MODE="en"` as the last line of the branch.
`resolve_variant()` resets `OUTPUT_MODE="zh"` on every call, so omitting it for
a Chinese variant is correct, and omitting it for an English one produces a
Chinese-styled PDF from English source — a bug the tests will not catch.

You can add an alias by listing it in the same pattern, the way the existing
code does with `default|general|resume)` and `english|en)`.

## 3. Create the Markdown source

Copy an existing variant in the same language rather than writing from scratch:

```bash
cp resume/zh/backend.md resume/zh/data.md
```

This is not laziness — it inherits the `class="resume-header"` block and the
exact section headings that `tests/content-structure.sh` greps for literally.
Those headings are listed in `AGENTS.md` under "Resume structure invariants".
Rewrite the prose inside the sections; leave the skeleton alone.

Keep the content fictional. `CLAUDE.md` requires every committed person,
company, school, project, and metric to be invented, and the repo is a public
template. If the request is to add a variant filled with someone's real
history, add the variant with fictional placeholder content and tell them to
personalize it in a private fork or an ignored `local/` directory.

## 4. Wire up the npm script

In `package.json`, add to `scripts`, keeping the existing ordering:

```json
    "build:data": "bash scripts/build.sh data",
```

`build:all` needs no change — `scripts/build-all.sh` loops over
`RESUME_VARIANTS`, so step 2a already covered it.

## 5. Update both README command tables

`README.md` and `README.zh-CN.md` each carry a command table. Add a row to
both, matching the surrounding language. A variant that only appears in the
English README is effectively invisible to half the audience.

## 6. Verify

```bash
npm test
npm run build:data
```

`npm test` is the real gate. `tests/structure-alignment.sh` stubs out pandoc
and WeasyPrint, so it builds every registered variant end-to-end without
needing the PDF toolchain installed — if the variant is wired correctly, it
passes even on a machine with no Pandoc.

## When a check fails

Map the error back to the step that was missed:

| Failure | Cause |
|---|---|
| `FAIL: <key> missing ## 自我评价` (or any section) | Step 3 — the Markdown is missing a required heading, or you renamed one |
| `FAIL: <key> has no project heading` | Step 3 — no `### Project \| Company` line |
| `Missing: resume/<path>` from `npm run check` | Step 2b — `SOURCE_FILE` does not match the file you created |
| `Error: Unsupported variant '<key>'` | Step 2b — the `case` branch is missing or sits after `*)` |
| `FAIL: <key> did not build` | Step 2b — a field like `POSITION` or `OUTPUT_SLUG` is unset |
| Variant builds but ignores English styling | Step 2b — `OUTPUT_MODE="en"` was omitted |
| English PDF filename has no position in it | Expected: `OUTPUT_SLUG` only appears in English filenames; Chinese ones use `POSITION` |

Before committing, follow the staged-snapshot privacy procedure in `AGENTS.md` —
the check only sees what you have staged.
