---
name: import-resume-doc
description: Import an existing resume from .docx, .doc, or .pdf into this repo's Markdown format — convert with pandoc (already a build dependency) or pdftotext, clean up the conversion artefacts, rebuild the resume-header HTML block by hand, and map the content onto the exact section headings the test suite greps for. Use whenever someone hands over an existing resume file or asks to bring one in — "把我的简历导进来", "解析一下这个 word 简历", "帮我把 PDF 简历转成 markdown", "import my existing resume", "convert my docx resume". It runs the privacy gate first, because a real resume is exactly the content this public template forbids committing.
---

# Import an existing resume document

Conversion is the easy half and it is not the point. `pandoc` will hand you a
pile of Markdown in thirty seconds; none of it has the section headings
`tests/content-structure.sh` requires, and the header block — the part that
carries the name and contact details — never survives any converter. The real
work is the mapping, and it has to be done by reading the content, not by
pattern-matching headings that a designer laid out as a table.

## 1. Decide where the content is allowed to land — do this first

A real resume is real employment history, real schools, a real phone number and
email. `AGENTS.md` forbids all of it in this repo's tracked content.

```bash
ls local/.private-ok 2>/dev/null
gh repo view --json visibility,nameWithOwner 2>/dev/null
git remote get-url origin
```

- **`local/.private-ok` exists** → private mode. The marker is authoritative;
  it lives in gitignored `local/` and never travels with a fork.
- **No marker, `gh` reports `PRIVATE`**, not the upstream template → offer to
  create the marker, then proceed in private mode.
- **`gh` missing or unauthenticated** → check the remote. `Jimmy-Smo/resume-workbench`
  is the public upstream: public mode. Any other remote, or none, is ambiguous —
  default to public mode and ask once.

Landing zone follows from the mode:

- **Private mode** → build a real variant with the `add-resume-variant` skill,
  which handles the four coupled edits a variant needs. Also create
  `local/.private-ok` if it is not there yet, or `npm test` will fail the moment
  a real email address is committed (see step 6).
- **Public mode** → write to `local/resume/`. Say so plainly and offer the
  private-fork path; do not quietly write real history into `resume/`.

**The original file always stays in `local/inbox/`.** `.docx` and `.pdf` are
gitignored, and `scripts/privacy-check.sh` rejects them as tracked files even in
personal mode — that rule has no escape hatch, by design.

```bash
mkdir -p local/inbox && cp "<original>" local/inbox/
```

## 2. Convert, by format

Check the tool before using it. Report the install command if it is missing
rather than guessing at the document's contents:

```bash
# .docx — pandoc is already required by scripts/build.sh, so it is present
pandoc -f docx -t markdown --wrap=none local/inbox/resume.docx -o local/inbox/resume.raw.md

# .pdf — poppler, the same package that provides the pdftoppm used by scripts/qa.sh
pdftotext -layout local/inbox/resume.pdf local/inbox/resume.raw.txt

# .doc (old binary format) — pandoc cannot read it; macOS ships a converter
textutil -convert docx local/inbox/resume.doc
```

`--wrap=none` matters: without it pandoc hard-wraps prose at 72 columns, and
every bullet you later edit fights the wrapping.

For PDFs, `-layout` preserves column structure. A two-column resume still comes
out interleaved — read it carefully before trusting the ordering, and prefer the
`.docx` original whenever the user has one.

If neither tool is available:

- macOS: `brew install pandoc poppler`
- Debian/Ubuntu: `sudo apt-get install pandoc poppler-utils`

## 3. Clean up what the converter leaves behind

`docx` → Markdown reliably produces junk that has to go:

- `[]{.underline}` and other empty span/div spans from Word character styles.
- Layout tables converted to pipe tables. Most Word resumes lay out the header
  and the skills grid as tables — these become tables in Markdown and must be
  rewritten as prose or lists.
- Trailing `\` hard line breaks at the end of nearly every line.
- `**bold**` runs applied to half a word, from Word's revision tracking.
- Image references pointing at extracted media you do not want.

PDF text extraction has its own: hyphenation across line breaks, page headers
and footers repeated mid-content, and bullet glyphs (`•`, `▪`) that need to
become `-`.

## 4. Rebuild the header block by hand

No converter produces this, and `tests/content-structure.sh` greps for
`class="resume-header"` literally. Copy the shape from `resume/zh/default.md`
and fill in the real values:

```html
<div class="resume-header">
<div class="resume-header__name-block">
<h1>姓名</h1>
</div>
<div class="resume-header__meta-block">
<p class="resume-header__role">期望职位：…</p>
<p class="resume-header__personal">城市 · 学历</p>
<p class="resume-header__contact">(+86) … · …@…</p>
</div>
</div>
```

The English variants use the same block with English labels — see
`resume/en/default.md`.

## 5. Map the content onto the required sections

This is the actual work. `AGENTS.md` lists the invariants under "Resume
structure invariants" and `tests/content-structure.sh` matches them with
`grep -qxF`, so the heading text must be exact:

- Chinese: `## 岗位优势`, `## 工作经历`, `## 项目经历`, `## 技术能力`,
  `## 教育背景`, `## 自我评价` — all six.
- English: `## Professional Summary`, `## Work Experience`,
  `## Selected Projects`, `## Technical Skills`, `## Education` — all five.
- At least one project heading in the form `### Project | Company`.

An imported resume almost never has this shape. Common reconciliations:

| What the source has | Where it goes |
|---|---|
| 个人简介 / 求职意向 / Summary | `## 岗位优势` / `## Professional Summary` |
| 工作经历 with projects nested inside | Split: employers to `## 工作经历`, projects to `## 项目经历` as `### 项目 \| 公司` |
| 专业技能 / 技能清单 / 掌握技术 | `## 技术能力` / `## Technical Skills` |
| 自我评价 missing entirely | `## 自我评价` is required in Chinese variants — write it or the tests fail |
| 获奖 / 证书 / 校园经历 | Fold into the nearest required section; do not add new top-level sections |

Preserve the person's actual wording and numbers. You are restructuring a
document, not rewriting a career — if a bullet is weak, flag it for the user
instead of improving it into something they cannot defend. Rewriting against a
specific posting is the `tailor-resume` skill's job, and it should happen after
the import is faithful.

## 6. Verify

```bash
npm test
```

In **public mode** the imported file lives in `local/`, so the tests only
confirm nothing regressed.

In **private mode** the real content is now in `resume/`, and `npm test` chains
`scripts/privacy-check.sh`, which rejects any non-`@example.com` email and any
mainland China mobile number. That is what `local/.private-ok` turns off:

```bash
mkdir -p local && touch local/.private-ok
npm test   # now prints "personal mode: contact rules relaxed"
```

Personal mode relaxes *only* the contact rules. Tracked PDFs, DOCX files, fonts,
`dist/`, `local/`, home paths, and credential patterns are still rejected.

Then build it and look at the page:

```bash
npm run qa -- <variant>
```

An imported resume is almost always too long — the source was written for a
different layout and these styles target a single A4 page. Read the preview and
cut, rather than shrinking the font.
