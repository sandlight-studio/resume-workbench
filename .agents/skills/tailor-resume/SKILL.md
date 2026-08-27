---
name: tailor-resume
description: Tailor a Resume Workbench resume to a specific job description — pick the closest variant, rewrite the bullets against the posting's keywords while preserving the structure the test suite enforces, then build and preview the PDF. Use this whenever someone pastes or links a job posting and wants their resume matched to it, says "adapt my resume for this role", "帮我按这个 JD 改简历", "which variant fits this job", or asks to rewrite resume bullets to hit certain keywords. It also runs the privacy gate first, which matters because this repo is a public template where real personal history must never be committed.
---

# Tailor a resume to a job description

Two things make this different from ordinary Markdown editing: the resume
skeleton is load-bearing (the test suite greps for exact headings), and this
repo is a public template where committing real career history is a privacy
incident, not a style problem.

## 1. Check where the content is allowed to go — do this first

Before reading the posting or touching a file, work out whether real personal
data is allowed here:

```bash
git remote -v
gh repo view --json visibility,nameWithOwner 2>/dev/null
```

**If the repo is public** (or is the upstream `resume-workbench` template, or
`gh` reports `"visibility": "PUBLIC"`), real names, employers, schools, dates,
and metrics must not be written into `resume/` or `interview/`. `CLAUDE.md`
requires committed content to stay fictional, and `git` history is forever —
`scripts/privacy-check.sh` and CI's Gitleaks scan are guardrails, not undo
buttons.

Say so plainly and offer the two workable paths:

- Create a **private** repo from this template and tailor there.
- Or work in `local/`, which is ignored by `.gitignore` and actively rejected
  by `scripts/privacy-check.sh` if it ever gets staged.

You can still do the full job in a public repo — just do it against the
fictional persona, demonstrating the structure and phrasing without importing
anyone's real history.

**If the repo is private**, proceed normally with real content.

## 2. Read the posting and extract what actually matters

Pull out, in the posting's own vocabulary:

- Hard requirements (years, language/stack, degree, domain).
- Repeated keywords — repetition signals what the screen filters on.
- The team's problem. A posting that keeps mentioning latency wants different
  evidence than one that keeps mentioning migrations.

Note which requirements the current resume already supports with a concrete
project. Those become the bullets to promote. Requirements with no supporting
evidence are gaps — surface them to the user instead of inventing experience.

## 3. Choose the variant

Read `resolve_variant()` in `config/variants.sh` for the registered variants.
Match on the role's center of gravity, not on keyword overlap.

Prefer editing an existing variant. Adding a new one is the right call only
when the target role is a genuinely different track that will be reused — in
that case use the `add-resume-variant` skill, which handles the four coupled
edits a new variant requires.

Editing an existing variant overwrites it, so if the user still needs the old
targeting, ask before rewriting rather than after.

## 4. Rewrite the content, not the skeleton

Edit `resume/<zh|en>/<key>.md`. Change the prose inside sections; leave the
section headings, the `class="resume-header"` block, and the
`### Project | Company` heading format exactly as they are. `AGENTS.md` lists
these invariants under "Resume structure invariants" — they are matched
literally by `tests/content-structure.sh`, so a "cleaner" heading is a test
failure.

What tends to move the needle:

- **Mirror the posting's nouns.** If it says "可观测性", using "监控体系"
  costs you a keyword match for no gain in meaning.
- **Reorder before rewriting.** Putting the most relevant project first is
  cheaper and more honest than embellishing a weaker one.
- **Keep numbers attached to a mechanism.** "Cut p99 by 40% by batching the
  callback writes" survives an interview; "improved performance by 40%" invites
  a question you can't answer.
- **Cut aggressively.** These layouts target a single A4 page. Every bullet
  that doesn't speak to this posting is pushing a bullet that does onto page 2.

Never add experience the person doesn't have. Beyond the obvious, it collapses
in the interview — and `interview/` in this repo exists precisely because the
resume is expected to be defended line by line.

## 5. Verify and preview

```bash
npm test
npm run qa -- <key>
```

`npm test` confirms the structure invariants and privacy rules still hold.
`npm run qa -- <key>` builds the PDF and renders preview images to
`dist/preview-*.png` when `pdftoppm` is available; it skips the preview step
rather than failing when it isn't, so a missing preview is not an error.

Read the preview image and check the things only a rendered page shows: does it
still fit one page, did a project block break across the page boundary, is the
top third carrying the most relevant material.

## 6. Before committing

Follow the staged-snapshot procedure in `AGENTS.md`. The privacy check reads
staged content only, so an unstaged file it never saw will pass and then get
committed:

```bash
git add --all
git diff --cached
npm run privacy:check
```

Read the staged diff yourself. The check catches emails, mainland China mobile
numbers, home paths, and credential patterns — it has no idea whether a company
name is real.
