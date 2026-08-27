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
```

## Structure

- `resume/zh/` and `resume/en/`: fictional resume variants.
- `interview/`: fictional interview-preparation examples.
- `styles/`: print CSS; never commit commercial font files.
- `config/variants.sh`: single source of truth for resume variants.
- `scripts/`: build, archive, QA, cleanup, and privacy checks.
- `.agents/skills/`: agent workflows for adding a variant and tailoring to a job.
  `.claude/skills/` holds symlinks to them, because Claude Code reads only its
  own directory while Codex and Gemini CLI read only `.agents/skills/`. Edit the
  real files under `.agents/skills/` and leave the symlinks alone.
- `dist/` and `archive/`: generated local output; always ignored.

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

## Resume structure invariants

`tests/content-structure.sh` matches these literally, so a resume that drops or
renames a section fails the test suite rather than rendering badly.

- Chinese variants need all six: `## 岗位优势`, `## 工作经历`, `## 项目经历`,
  `## 技术能力`, `## 教育背景`, `## 自我评价`.
- English variants need all five: `## Professional Summary`,
  `## Work Experience`, `## Selected Projects`, `## Technical Skills`,
  `## Education`.
- Every variant needs `class="resume-header"` and at least one
  `### Project | Company` heading.

## Style and releases

- Markdown sections use `##`; project headings use `### Project | Company`.
- CSS uses two-space indentation and print units such as `pt` and `mm`.
- Versions and Git tags use `x.y.z` without a `v` prefix.
- Use Conventional Commit prefixes such as `feat:`, `fix:`, `docs:`, and
  `chore:`.
- Open contribution PRs against `dev`. To release, open a `dev` to `main` PR,
  wait for CI, merge, then tag the merge commit and update `CHANGELOG.md`.
