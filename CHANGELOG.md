# Changelog

## 0.2.0 - 2026-08-27

- Agent skills for the resume itself: `add-resume-variant` and
  `tailor-resume`, symlinked into `.claude/skills/`.
- Job-application pipeline skills: `mine-project-highlights`,
  `import-resume-doc`, `prep-interview-kit`, and `boss-zhipin-profile`,
  with a privacy mode that keeps real content in the ignored `local/`
  workspace.
- `mine-commits.sh` surveys all refs of a local repository and reports
  per-author commit share.
- Python content contract validator (`scripts/check-content.py`) enforcing
  resume section structure in the test suite.
- `npm run preview` regenerates the README preview, now rendered at 288 DPI
  and auto-synced by an opt-in pre-commit hook.
- WeasyPrint bumped to 69.0.
- CI secret scanning switched from gitleaks-action to the gitleaks CLI.

## 0.1.0 - 2026-08-27

- Initial public template with fictional Chinese and English resumes.
- Position-specific Java, backend, and full-stack variants.
- Curated fictional interview-preparation examples.
- Generated resume preview embedded in both READMEs.
- Staged-snapshot privacy checks for generated artifacts and contact details.
- GitHub Actions CI with Gitleaks and pinned third-party actions.
- Protected `main` release workflow with a long-lived `dev` integration branch.
