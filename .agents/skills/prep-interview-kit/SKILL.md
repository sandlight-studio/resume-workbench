---
name: prep-interview-kit
description: Generate a complete interview kit from someone's real projects and resume — 自我介绍 (technical and HR phone-screen versions), one deep-dive story per project with the follow-up chain an interviewer will actually walk, HR answers in spoken Chinese (离职原因/期望薪资/加班/到岗时间/反问), stack-specific technical drills, and a consistency check across resume, Boss profile, and HR script. Use whenever someone is preparing to interview — "帮我准备面试", "写个自我介绍", "项目面会问什么", "HR 面怎么答", "模拟一下面试官会怎么追问", "prep me for this interview". Reads evidence cards from local/evidence/ when they exist and runs the privacy gate first.
---

# Build an interview kit from real material

The `interview/` directory in this repo is a worked example of the output, not a
script to copy. Its value is in the shapes — the five-part story structure, the
answer skeletons, the honesty rules — and this skill's job is to fill those
shapes with one specific person's actual work.

Two failure modes to design against. The first is generic output: answers that
would fit anyone, which is what happens when the kit is written from the resume
alone. The second is fluent output the user cannot defend, which is worse,
because it survives preparation and collapses in the room.

## 1. Decide where the content is allowed to land — do this first

```bash
ls local/.private-ok 2>/dev/null
gh repo view --json visibility,nameWithOwner 2>/dev/null
git remote get-url origin
```

- **`local/.private-ok` exists** → private mode; `interview/` is writable.
- **No marker, `gh` reports `PRIVATE`** and not the upstream template → offer to
  create the marker.
- **`gh` missing or unauthenticated** → `Jimmy-Smo/resume-workbench` as origin
  means public mode. Any other remote, or none, is ambiguous — default to public
  mode and ask once.

Public mode writes everything to `local/interview/`. The committed `interview/`
files stay fictional; `AGENTS.md` requires it and `tests/content-structure.sh`
enforces the README disclaimers that go with it.

## 2. Gather the inputs before writing a word

- **Evidence cards** in `local/evidence/`. If they are not there, run
  `mine-project-highlights` first — writing stories from the resume alone
  produces exactly the generic output this skill exists to avoid.
- **The resume variant** being sent for this role, so the kit and the document
  agree.
- **The job posting**, if there is one. It decides which project leads and which
  technical drills matter.
- **The user's real situation**: currently employed or not, notice period,
  salary expectation, other processes in flight. Ask — never assume, and never
  fill these in with plausible defaults. They are the answers most likely to be
  cross-checked.

## 3. Write the kit

Output into `local/interview/` (or `interview/` in private mode), mirroring the
existing file set so the two are comparable:

### `scripts.md` — openings and closings

Follow `interview/scripts.md`. Four pieces:

- **技术面自我介绍 (60 秒)** — who, current focus, the one system worth asking
  about, and a closing line that hands the interviewer a thread to pull. The
  example ends by naming what the candidate wants to learn about the role; that
  is what turns a monologue into a conversation.
- **HR 电话初筛 (30 秒)** — shorter, no architecture, states job-search status
  honestly.
- **"最近在做什么？"** — split into two workstreams, not a chronology.
- **面试后跟进** — references one specific thing from the conversation.

### `story-<topic>.md` — one per major project

Reuse the structure from `interview/story-idempotent-callback.md`:
30 秒版本 / 背景 / 设计 / 为什么不用<替代方案> / 结果如何说 / 追问清单.

The follow-up chain is the part that earns its keep. Generate 3–5 questions per
story, sourced from failure modes that actually exist in the code — ordering,
partial failure, crash recovery, concurrent compensation, data retention. The
existing example's list is the calibration:

> 事件已经处理成功，但写成功状态失败怎么办？
> 同一业务对象的两个不同事件乱序到达怎么办？

**Mark every question the user cannot currently answer as homework.** Do not
supply an answer they did not give you. An unanswered question on a checklist is
useful; a fabricated answer in their own kit is a trap they will walk into.

### `hr.md` — spoken Chinese, honest

Follow `interview/hr.md`, which already encodes the rules that matter:

- 期望薪资: no example numbers. Anchor on the posted range, the city, the total
  package structure, and verifiable experience.
- 手里有其他机会吗: state the real stage. No invented offers, no fake deadlines.
- 离职原因: continuous growth, no blame. Must match what the resume dates imply.
- 到岗时间: only a date the user can actually honour, counting handover and
  contractual notice.
- 反问: three questions that are genuinely about the job — first ninety days,
  how the team prioritises and reviews, the engineering problem they most want
  solved.

Write these to be *spoken*. Short sentences, no written-Chinese connectives, no
bullet-point cadence. Read them aloud mentally; anything that needs a comma
splice to survive gets rewritten.

### `technical.md` and `troubleshooting.md`

Derive the questions from the stack the mining actually found — not a generic
八股 list. If the projects are Spring Boot and RocketMQ, the drills are about
transaction boundaries and message idempotency; if they are React and Node, they
are not.

`interview/troubleshooting.md` opens with a reusable six-step frame (影响面 →
时间线 → 止损 → 证据 → 验证 → 复盘). Keep the frame, replace the scenarios with
incidents from the user's own systems — a real outage they handled beats any
hypothetical.

## 4. Cross-check consistency, then report contradictions

`interview/scripts.md` states the requirement: 求职状态、离职原因、薪资和到岗时间
必须在所有渠道保持一致. Interviewers compare notes, and the Boss profile, the
resume, and the HR round are three surfaces where the same facts get restated.

Check explicitly and list any mismatch:

- Resume dates vs. the 离职原因 narrative.
- Titles and scope in `resume/` vs. how the stories describe them.
- Job-search status in `local/boss/` vs. `hr.md`.
- Salary expectation stated in more than one place.

Report contradictions to the user as findings. Do not silently harmonise them —
you do not know which version is true, and picking one for them is how a wrong
fact becomes a rehearsed one.

## 5. Close with what is missing

End with the homework list: the follow-ups without answers, the metrics that
need to be looked up in a dashboard or an incident ticket, and the stories that
are still thin. That list is the actual deliverable — the prose is just what
gets rehearsed once the gaps are closed.

```bash
git status --short   # local/ must not appear
```
