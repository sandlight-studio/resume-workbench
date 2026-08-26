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
- `dist/` and `archive/`: generated local output; always ignored.

## Privacy rules

- Never commit real contact details, employment history, school information,
  salary data, private repository names, internal service names, or source
  commit hashes.
- Example email addresses must use `example.com`.
- Do not commit PDF, DOCX, TTF, OTF, `.env`, or local content overrides.
- Run `npm run privacy:check` before every push.
- CI also scans commit history with Gitleaks; both checks must pass.
- Personal forks should be private. Public contributions must retain fictional
  examples.

## Style and releases

- Markdown sections use `##`; project headings use `### Project | Company`.
- CSS uses two-space indentation and print units such as `pt` and `mm`.
- Versions and Git tags use `x.y.z` without a `v` prefix.
- Use Conventional Commit prefixes such as `feat:`, `fix:`, `docs:`, and
  `chore:`.
