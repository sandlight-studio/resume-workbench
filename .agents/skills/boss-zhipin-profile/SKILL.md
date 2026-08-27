---
name: boss-zhipin-profile
description: Produce a BOSS 直聘 online profile as plain text ready to paste field by field — 期望职位/城市/薪资, 个人优势, 工作经历, 项目经历, 技能标签 — plus three tiers of 打招呼语 (generic, JD-tailored, and a follow-up for when the first message goes unanswered). Use whenever someone is filling in or rewriting an online job-platform profile — "帮我写 Boss 直聘的简历", "在线简历怎么填", "打招呼语怎么写", "招呼语被已读不回", "写个 boss 直聘的自我介绍", "网页版简历". Formats for a form that does not render Markdown, and runs the privacy gate first because this content is published to recruiters, not just committed.
---

# Write a BOSS 直聘 profile

Two things make this different from producing a PDF resume, and both change the
writing rather than just the formatting.

The form does not render Markdown. `**加粗**` shows up as literal asterisks, `#`
headings show up as hashes, and nested indentation collapses on mobile. Anything
written for the PDF pipeline has to be converted, not pasted.

And the greeting message is the actual bottleneck. The profile only matters if
someone opens it, and what decides that is the first message. Most of the value
in this skill is in step 5.

## 1. Decide where the content lands — do this first

```bash
ls local/.private-ok 2>/dev/null
gh repo view --json visibility,nameWithOwner 2>/dev/null
git remote get-url origin
```

- **`local/.private-ok` exists** → private mode.
- **No marker, `gh` reports `PRIVATE`** and not the upstream template → offer to
  create the marker.
- **`gh` missing or unauthenticated** → origin `Jimmy-Smo/resume-workbench` means
  public mode; any other remote, or none, is ambiguous — default to public and
  ask once.

Output goes to `local/boss/` in **either** mode. Unlike resume prose, this is
platform copy with no home in the committed structure — `resume/` holds
Markdown that builds to PDF, and this does not build.

```bash
mkdir -p local/boss
```

## 2. A privacy rule that is different from the repo's

Everywhere else in this repo, the concern is Git history. Here the content is
**published to a searchable platform and read by recruiters, including ones at
your current employer**. Same prohibitions, different reason, and no undo:

- No internal service names, private repository names, or codenames.
- No un-anonymised client or customer names.
- No unreleased product names.
- Describe systems by function — "多租户任务平台" rather than the internal name.

If the user is job-hunting while employed, raise the platform's visibility
settings (屏蔽当前公司) before the profile goes live. It is worth one sentence
and it is the mistake with the highest cost.

## 3. Gather inputs

Evidence cards in `local/evidence/`, the resume variant closest to the target
roles, and the user's real expectations for 城市/薪资/到岗时间. If the evidence
cards do not exist, run `mine-project-highlights` first.

Facts stated here must match the resume and the HR script — recruiters read the
profile before the call and compare. `prep-interview-kit` cross-checks this;
flag any contradiction you notice while writing.

## 4. Write the fields as plain text

Produce `local/boss/profile.txt` with each field clearly delimited so it can be
pasted one at a time. Formatting rules throughout:

- Plain text only. No `**`, no `#`, no Markdown tables.
- Use `·` or numbered items (`1. `) instead of `-` for bullets; `-` reads as a
  dash on the platform, not as a list marker.
- Chinese punctuation, short sentences. Anything over about 40 characters
  wraps unpredictably on a phone.
- One idea per line. Blank lines between blocks survive; indentation does not.
- Field length caps differ by app version — write tight, then check the counter
  in the app rather than trusting a number from here.

The fields:

**期望职位 / 城市 / 薪资 / 求职状态** — Concrete. A vague 期望职位 is the most
common reason a profile does not surface in recruiter search, because the
platform matches on it.

**个人优势** — The highest-leverage field; it appears in search results. Three to
five lines, each one a claim plus its evidence. Lead with the role and years,
then the two or three capabilities you want to be searched for, then one
concrete system. No adjectives that cannot be checked — 认真负责、抗压能力强 are
noise. Mirror the vocabulary of the postings being targeted, since this is what
gets keyword-matched.

**工作经历** — Per employer: what the team did, what you owned, and two or three
outcomes. Ownership and scope matter more than task lists.

**项目经历** — The platform splits this into separate boxes (project description,
your responsibilities, and results; the exact split varies by app version).
Prepare all three regardless:

1. 项目描述 — what the system is and who uses it, in two sentences.
2. 我的职责 — your scope specifically, not the team's.
3. 项目业绩 — outcomes. Same rule as everywhere else in this repo: no invented
   percentages. With no monitoring data, name the failure modes eliminated.

**技能标签** — Match the exact strings used in postings. Recruiters filter on
these; a synonym is a missed match.

## 5. Write the 打招呼语

Three tiers, in `local/boss/greetings.txt`.

The default opener the platform offers gets ignored. So does 您好，我对贵司这个
岗位很感兴趣，请问方便沟通吗 — it says nothing, so there is nothing to reply to.

A first message should run roughly 60–100 characters and do three things:

1. Name the specific match to *this* posting, in the posting's own words.
2. Give one verifiable piece of evidence — a system, a scale, a stack.
3. Ask something concrete, so replying is easier than ignoring.

**通用版** — for postings worth a message but not a rewrite. Role, one
capability, one system, one question.

**按 JD 定制版** — the one that works. Quote the posting's own requirement, then
match it to a specific project. Produce one per target posting, not a template
with blanks.

**跟进版** — for 已读不回, sent once after two or three days. Add information
rather than repeating: a detail about a relevant project, or a narrower
question. Never ask 还在招吗 or 方便看下我的简历吗. One follow-up, then stop.

Write these to be sent from a phone: no line breaks that matter, no formatting,
nothing that needs to be read twice.

## 6. Hand off

Tell the user which fields to paste where, and flag anything you had to leave
as a placeholder — expected salary, notice period, anything you would have had
to invent. Those are theirs to fill, and a placeholder they see is better than
a plausible number they do not notice.

```bash
git status --short   # local/ must not appear
```
