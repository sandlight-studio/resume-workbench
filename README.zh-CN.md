# Resume Workbench

[![CI](https://github.com/Jimmy-Smo/resume-workbench/actions/workflows/ci.yml/badge.svg)](https://github.com/Jimmy-Smo/resume-workbench/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)

**隐私优先的 Markdown 简历与面试准备工作台。**

用 Markdown 维护中英文及岗位定制简历，通过 Pandoc 和 WeasyPrint 在本地
生成 PDF，并把代表性的面试准备材料放在同一套版本管理流程里。

> 本仓库中的人物、公司、学校、项目、时间、指标和面试回答全部是虚构的教学示例。

## 功能

- 中英文简历排版。
- 通用、Java、后端和全栈岗位变体。
- 本地生成 PDF，不上传简历数据。
- 虚构的技术故事、HR 回答和故障排查练习。
- 检查联系方式、二进制成品和本地配置误提交的隐私守卫。
- 不附带商业字体文件。

## 快速开始

macOS：

```bash
brew install pandoc pango gdk-pixbuf libffi
```

Debian/Ubuntu：

```bash
sudo apt-get update
sudo apt-get install pandoc python3-venv python3-pip libpango-1.0-0 libpangoft2-1.0-0
```

然后在任一平台执行：

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

npm run check
npm run build:all
```

PDF 输出到被 Git 忽略的 `dist/`。常用命令：

原生 Windows 暂不属于支持范围，请使用 WSL2 或 Linux 容器。

```bash
npm run build
npm run build:english
npm run build:java
npm run build:backend
npm run build:fullstack
npm run qa -- default
npm test
```

使用本机已安装的文楷字体栈：

```bash
./scripts/build.sh backend --font wenkai
```

可通过环境变量覆盖输出文件名中的示例姓名与年限：

```bash
RESUME_NAME_ZH="候选人" YOE_CN="5年" ./scripts/build.sh backend
RESUME_NAME_EN="Candidate" YOE_EN="5YOE" ./scripts/build.sh english
```

## 安全使用

加入真实履历前，请从本项目创建一个**私有仓库**。不要把真实联系方式、工作经历、
学校信息或生成的 PDF 提交到公开 fork。`npm run privacy:check` 只能拦截常见错误；
个性化仓库改为公开前仍须人工审查完整 Git 历史。

## 设计、字体与许可

版式借鉴了 [Kami](https://github.com/tw93/Kami)，详见
[第三方声明](THIRD_PARTY_NOTICES.md)。仓库不包含商业字体；默认使用系统衬线字体，
`--font wenkai` 会优先选择本机文楷字体并安全回退。

项目采用 Apache-2.0，详见 [LICENSE](LICENSE) 与 [NOTICE](NOTICE)。
