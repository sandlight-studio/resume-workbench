# Repository Guidelines

Resume Workbench turns Markdown resumes into PDFs with Pandoc and WeasyPrint.
Every committed person, company, school, project, metric, and interview answer
must be fictional.

## Commands

```bash
npm test
npm run check
npm run build:all
npm run qa -- default
npm run mine -- --all --author "<name-or-email>" <repo-path>
```

## Structure

- `resume/zh/` and `resume/en/`: fictional resume variants.
- `interview/`: fictional interview-preparation examples.
- `styles/`: print CSS; never commit commercial font files.
- `config/variants.sh`: single source of truth for resume variants.
- `scripts/`: build, archive, QA, cleanup, commit mining, and privacy checks.
- `.agents/skills/`: agent workflows. `.claude/skills/` holds symlinks to them,
  because Claude Code reads only its own directory while Codex and Gemini CLI
  read only `.agents/skills/`. Edit the real files under `.agents/skills/` and
  leave the symlinks alone.
  - `add-resume-variant`, `tailor-resume`: the resume itself.
  - `mine-project-highlights`, `import-resume-doc`, `prep-interview-kit`,
    `boss-zhipin-profile`: the pipeline from real work to application material.
- `dist/` and `archive/`: generated local output; always ignored.
- `local/`: ignored workspace for real personal content. Layout used by the
  skills:

```text
local/
  .private-ok          opt-in marker; see "Privacy rules"
  inbox/               original .docx / .pdf resumes
  evidence/raw/        scripts/mine-commits.sh output; never committed
  evidence/<项目>.md   distilled evidence cards
  interview/           generated interview kit
  boss/                BOSS 直聘 field text and greetings
  resume/              real resume drafts in public mode
```

## Privacy rules

- Never commit real contact details, employment history, school information,
  salary data, private repository names, internal service names, or source
  commit hashes.
- Example email addresses must use `example.com`.
- Do not commit PDF, DOCX, TTF, OTF, `.env`, or local content overrides.
- `npm run privacy:check` inspects the **staged snapshot only** (it uses
  `git grep --cached`). Stage everything first, review the staged diff, then
  run it: `git add --all && git diff --cached && npm run privacy:check`.
  Unstaged and untracked content is never scanned.
- CI also scans commit history with Gitleaks; both checks must pass.
- Personal forks should be private. Public contributions must retain fictional
  examples.

### Where real content is allowed

Repository detection is advisory; the marker is authoritative. The skills
resolve the mode in this order:

1. `local/.private-ok` exists → **private mode**. Because `local/` is ignored,
   the marker never travels with a clone or a fork — it is created deliberately,
   once per machine.
2. Otherwise `gh repo view --json visibility,nameWithOwner` reporting `PRIVATE`
   for a repo that is not the upstream template → offer to create the marker.
3. Otherwise fall back to `git remote get-url origin`. The upstream
   `Jimmy-Smo/resume-workbench` means **public mode**. Any other remote, or no
   remote, is ambiguous — default to public mode and ask.

Public mode writes real content to `local/` only. Private mode additionally
unlocks `resume/` and `interview/` for finished prose — never for raw mining
output, which carries private repository names, internal service names, and
commit hashes.

### Personal mode in `privacy:check`

A private fork committing a real resume needs the contact rules relaxed, or
`npm test` fails on the first real email address. Set
`RESUME_WORKBENCH_PERSONAL=1` or create `local/.private-ok`; the check then
prints `personal mode: contact rules relaxed`.

This relaxes the email and mobile-number rules **only**. Tracked `dist/`,
`archive/`, `local/`, PDF, DOCX, font and `.env` files, machine home paths, and
credential patterns are still rejected. CI never enters personal mode: `local/`
is ignored so the marker cannot exist in a checkout, and the variable is unset.

## Resume structure invariants

`scripts/check-content.py` (run by `tests/content-structure.sh`) matches these
literally, so a resume that drops or renames a section fails the test suite
rather than rendering badly. Variant discovery stays in `config/variants.sh`.

- Chinese variants need all six, in order: `## 岗位优势`, `## 工作经历`,
  `## 项目经历`, `## 技术能力`, `## 教育背景`, `## 自我评价`.
- English variants need all five, in order: `## Professional Summary`,
  `## Work Experience`, `## Selected Projects`, `## Technical Skills`,
  `## Education`.
- Every variant needs `class="resume-header"` and at least one
  `### Project | Company` heading.
- Each project entry starts with a date range (`2023.01 - 至今 | 角色` in
  Chinese, `Jan 2023 - Present | Role` in English), states its stack
  (`**技术栈：**` / `**Stack:**`), and carries at least one bullet.
- No unresolved placeholders (`{{...}}`, `【待填】`, `【待核实】`,
  `[DATA NEEDED`) may survive into a variant.

## Style and releases

- Markdown sections use `##`; project headings use `### Project | Company`.
- `assets/resume-preview.png` is regenerated automatically by the pre-commit
  hook in `.githooks/` whenever a commit stages changes under `resume/` or
  `styles/`. Enable it once per clone with
  `git config core.hooksPath .githooks`; without the hook (or without the
  local toolchain), run `npm run preview` before pushing.
- CSS uses two-space indentation and print units such as `pt` and `mm`.
- Versions and Git tags use `x.y.z` without a `v` prefix.
- Use Conventional Commit prefixes such as `feat:`, `fix:`, `docs:`, and
  `chore:`.
- Open contribution PRs against `dev`. To release, open a `dev` to `main` PR,
  wait for CI, merge, then tag the merge commit and update `CHANGELOG.md`.
