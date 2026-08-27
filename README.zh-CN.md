# Resume Workbench

[![CI](https://github.com/Jimmy-Smo/resume-workbench/actions/workflows/ci.yml/badge.svg)](https://github.com/Jimmy-Smo/resume-workbench/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)

**隐私优先的 Markdown 简历与面试准备工作台。**

用 Markdown 维护中英文及岗位定制简历，通过 Pandoc 和 WeasyPrint 在本地
生成 PDF，并把代表性的面试准备材料放在同一套版本管理流程里。

> 本仓库中的人物、公司、学校、项目、时间、指标和面试回答全部是虚构的教学示例。

## 效果预览

<p align="center">
  <a href="assets/resume-preview.png">
    <img src="assets/resume-preview.png" alt="Resume Workbench 生成的虚构中文简历" width="720">
  </a>
</p>

## 功能

- 中英文简历排版。
- 通用、Java、后端和全栈岗位变体。
- 本地生成 PDF，不上传简历数据。
- 虚构的技术故事、HR 回答和故障排查练习。
- 检查联系方式、二进制成品和本地配置误提交的隐私守卫。
- 内置新增岗位变体和按 JD 定制的 agent skills。
- 从真实工作到求职材料的技能流水线：从自己的提交里挖项目亮点、导入已有的
  Word/PDF 简历、生成面试物料、产出 BOSS 直聘在线简历与打招呼语。
- 不附带商业字体文件。

## 快速开始

macOS：

```bash
brew install node pandoc pango gdk-pixbuf libffi
```

Debian/Ubuntu：

```bash
sudo apt-get update
sudo apt-get install nodejs npm pandoc python3-venv python3-pip libpango-1.0-0 libpangoft2-1.0-0
```

然后在任一平台执行：

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

npm run check
npm run build:all
```

PDF 输出到被 Git 忽略的 `dist/`。
原生 Windows 暂不属于支持范围，请使用 WSL2 或 Linux 容器。

## 常用命令

| 命令 | 用途 |
|---|---|
| `npm run build` | 构建默认中文简历 |
| `npm run build:english` | 构建英文简历 |
| `npm run build:java` | 构建 Java 岗位简历 |
| `npm run build:backend` | 构建后端岗位简历 |
| `npm run build:fullstack` | 构建全栈岗位简历 |
| `npm run build:all` | 构建全部岗位变体 |
| `npm run qa -- default` | 构建简历，并在工具可用时生成预览图 |
| `npm run mine -- --author "<你>" <仓库路径>` | 统计自己在本地仓库中的提交 |
| `npm test` | 执行结构、样式和隐私检查 |

使用本机已安装的文楷字体栈：

```bash
./scripts/build.sh backend --font wenkai
```

可通过环境变量覆盖输出文件名中的示例姓名与年限：

```bash
RESUME_NAME_ZH="候选人" YOE_CN="5年" ./scripts/build.sh backend
RESUME_NAME_EN="Candidate" YOE_EN="5YOE" ./scripts/build.sh english
```

## 目录结构

```text
resume/        虚构的中英文简历变体
interview/     虚构的面试准备示例
styles/        A4 页面、字体栈与主题样式
scripts/       构建、归档、QA、清理、提交挖掘和隐私工具
tests/         Shell 接口与内容测试
.agents/skills/  Agent skills（软链到 .claude/skills/ 供 Claude Code 读取）
dist/          本地生成的 PDF 和预览图（已忽略）
archive/       可选的本地归档（已忽略）
local/         你的真实内容：证据卡、面试物料、BOSS 直聘文案（已忽略）
```

## 开发流程

- `main` 是受保护的发布分支，禁止直接推送、强推和删除。
- `dev` 是日常迭代的集成分支；贡献代码时请向 `dev` 发起 PR。
- 发布时从 `dev` 向 `main` 发起 PR，等待 CI 通过并合并，再为合并提交打 tag。

## 安全使用

加入真实履历前，请从本项目创建一个**私有仓库**。不要把真实联系方式、工作经历、
学校信息或生成的 PDF 提交到公开 fork。`npm run privacy:check` 只能拦截常见错误；
个性化仓库改为公开前仍须人工审查完整 Git 历史。

本地隐私检查只检查精确的暂存区快照。提交前请先暂存全部目标文件、检查差异，
再运行隐私检查：

```bash
git add --all
git diff --cached
npm run privacy:check
```

未跟踪和未暂存的内容不在该快照中。CI 会额外使用 Gitleaks 扫描完整历史，但两者都
不能替代人工隐私审查。

真实的个人内容一律放在 `local/`：它被 Git 忽略，一旦被跟踪隐私检查会直接失败。
Agent skills 默认写到那里，只有在本机显式开启后才会写入 `resume/` 和
`interview/`：

```bash
mkdir -p local && touch local/.private-ok
```

这个标记同时会把 `privacy:check` 切到 personal 模式，私有 fork 才能提交真实邮箱和
手机号而不让 `npm test` 变红。它只放宽联系方式两条规则，被跟踪的二进制产物、
机器 home 路径和凭据模式仍然照拦。由于 `local/` 被忽略，标记不会跟着 fork 走，
CI 也永远不会进入 personal 模式。

## 设计、字体与许可

版式借鉴了 [Kami](https://github.com/tw93/Kami)，详见
[第三方声明](THIRD_PARTY_NOTICES.md)。仓库不包含商业字体；默认使用系统衬线字体，
`--font wenkai` 会优先选择本机文楷字体并安全回退。

项目采用 Apache-2.0，详见 [LICENSE](LICENSE) 与 [NOTICE](NOTICE)。
