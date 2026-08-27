---
name: mine-project-highlights
description: Mine a person's real contributions out of local Git repositories and distil them into interview-ready evidence cards under local/evidence/ — author-filtered commit history via scripts/mine-commits.sh, then a code read of the hot paths to recover the constraints and trade-offs commits cannot show. Use whenever someone hands over one or more project paths and wants the highlights extracted — "分析下我这几个项目的亮点", "看看我在这几个仓库提交了什么", "帮我把项目经历整理出来", "what did I actually build here", "turn my commit history into resume bullets". It runs the privacy gate first, because mined output carries private repo names, internal service names, and commit hashes that must never reach this public template.
---

# Mine project highlights from real repositories

Commit history tells you *what* changed. A resume bullet and an interview answer
both need *why it was hard* and *what you traded away* — neither is in the log.
This skill exists to keep those two steps from collapsing into one, because a
highlight derived from subject lines alone reads plausibly and then dies at the
first follow-up question.

## 1. Decide where real content is allowed to land — do this first

Mined output is the most sensitive material this repo ever touches: private
repository names, internal service names, real commit hashes. `AGENTS.md` names
all three under "Privacy rules". Work out the mode before running anything:

```bash
ls local/.private-ok 2>/dev/null
gh repo view --json visibility,nameWithOwner 2>/dev/null
git remote get-url origin
```

- **`local/.private-ok` exists** → private mode. The marker is authoritative.
  It lives inside gitignored `local/`, so it never travels with a clone or a
  fork; whoever created it did so deliberately on this machine.
- **No marker, `gh` reports `"visibility": "PRIVATE"`** and the repo is not the
  upstream template → offer to create the marker, then proceed in private mode.
- **No marker and `gh` is missing or unauthenticated** → fall back to the
  remote. `Jimmy-Smo/resume-workbench` is the public upstream template: public
  mode, no real content in `resume/` or `interview/`, full stop. Any other
  remote, or no remote at all, is ambiguous — default to public mode and ask
  once rather than guessing.

**Regardless of mode, raw mining output only ever goes to `local/evidence/`.**
Private mode unlocks `resume/` and `interview/` for *finished prose*, never for
commit dumps. `local/` is gitignored and `scripts/privacy-check.sh` fails if
anything under it is ever tracked, so this is enforced, not just advised.

## 2. Pin down the author identity before mining

This is where the run usually fails. One person commits under a work email, a
personal email, a GitHub noreply address, and two spellings of their name.

```bash
git -C <repo> shortlog -sne --all | head -20
```

Read the output and pick every string that is the same human. Do not guess from
the user's Git config — `user.email` is what they commit as *today*, not what
they used three jobs ago in the repo you are about to mine.

## 3. Run the survey

```bash
npm run mine -- --author "<name>" --author "<email>" <repo-path> [<repo-path>...]
```

Repeat `--author` for each identity; git ORs them. `--since "3 years ago"`
narrows to relevant history, `--max-subjects` caps the subject dump.

Redirect each repo into its own file so the raw material survives the session:

```bash
mkdir -p local/evidence/raw
npm run mine -- --author "<email>" ~/code/foo > local/evidence/raw/foo.txt
```

The script is read-only — it only ever runs `git -C <path> log/shortlog/rev-parse`
and never writes to the repositories it inspects, so it is safe to point at a
work checkout with uncommitted changes.

If a repo reports no matches it prints the identities it *does* contain. That is
the answer to "why is this empty", not an error to work around.

## 4. Read the code — this step is not optional

Take the "Most touched areas" list and actually open those directories: the
README, the core module, the config, the tests. You are looking for what the log
structurally cannot contain:

- The constraint. Why did this need to exist — what was failing before?
- The alternative that was rejected, and why. This is the single highest-value
  thing you can recover, because it is what a senior interviewer probes.
- The failure modes the design handles. Retries, idempotency, partial writes,
  backpressure, tenancy. These become the follow-up questions later.

Interrogate churn instead of trusting it. The script prints a warning next to
that list for a reason: lockfiles, generated clients, vendored directories, and
mass reformatting all rank high and mean nothing. A 4,000-line commit that bumps
dependencies is not a highlight. Ask the user about anything ambiguous rather
than inventing a narrative that fits the diff.

## 5. Write one evidence card per project

Write to `local/evidence/<project>.md`, and reuse the structure that
`interview/story-idempotent-callback.md` already proves out:

```markdown
# <项目> — 证据卡

## 30 秒版本
## 背景
## 设计
## 为什么不用<被否决的方案>
## 结果如何说
## 追问清单
```

That shape is not decoration. `## 30 秒版本` is the resume bullet's source,
`## 设计` and `## 为什么不用…` are the project round, and `## 追问清单` is what
`prep-interview-kit` consumes downstream.

**Never invent a metric.** `interview/story-idempotent-callback.md` states the
rule plainly ("不要虚构百分比"), and it holds harder here because this material
describes real work someone will be cross-examined on. With no monitoring data,
write which failure modes were eliminated — "重复回调不再创建重复任务" survives
questioning; "性能提升 40%" invites a question with no answer.

Then tell the user where the real numbers live: monitoring dashboards, load-test
reports, incident tickets, release notes. Mark each one as a gap to fill rather
than leaving a blank the user will paper over later.

## 6. Report what is not worth using

Finish by naming the material you deliberately dropped and why — bulk
refactors, dependency bumps, generated-code churn, work that was real but
unremarkable. A person who knows which three of their eight projects carry
weight interviews better than one handed all eight flattened to equal size.

## 7. Confirm nothing leaked

```bash
git status --short
```

`local/` must not appear. If it does, `.gitignore` was modified — stop and fix
that before continuing, because `scripts/privacy-check.sh` only inspects the
staged snapshot and will not save you from content you never staged.
