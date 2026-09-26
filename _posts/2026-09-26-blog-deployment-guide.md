---
title: 从零部署我的 Jekyll 博客
date: 2026-09-26 10:00:00 +0800
categories: [博客]
tags: [Jekyll, GitHub Pages, 部署]
---

这篇文章记录这个博客从主题选择、环境安装，到 GitHub Pages 部署、域名绑定和日常更新的全过程。

## 参考主题与仓库

- 参考主题：[jekyll-theme-chirpy](https://github.com/cotes2020/jekyll-theme-chirpy)
- 我的博客仓库：[ypj0/ypj_blog](https://github.com/ypj0/ypj_blog)
- 在线地址：[ypj0.xyz](https://ypj0.xyz)

Chirpy 是一个基于 Jekyll 的静态博客主题。文章使用 Markdown 编写，构建后生成 HTML、CSS 和 JavaScript，不需要数据库或后端服务器。

## 项目结构

```text
ypj_blog/
├── _config.yml                 # 站点、作者、域名和评论配置
├── _posts/                     # Markdown 文章
├── _tabs/about.md              # 关于页面
├── _data/contact.yml           # GitHub 和邮箱入口
├── _data/locales/zh-CN.yml     # 中文界面文字
├── assets/                     # 图片和静态资源
├── .github/workflows/          # GitHub Pages 自动部署
└── CNAME                       # 自定义域名
```

## 本地环境

本博客使用 Ruby 3.3、Bundler、Jekyll 和 Node.js 构建资源：

```bash
cd ypj_blog
source tools/use-local-ruby.sh
bundle install
npm install
npm run build
bundle exec jekyll serve --livereload
```

打开 <http://127.0.0.1:4000>，修改文章后页面会自动刷新。

## 站点配置

在 `_config.yml` 中填写博客信息。

## 部署到 GitHub Pages

在 GitHub 创建公开仓库。

仓库中已有 `.github/workflows/pages-deploy.yml`。进入 **Settings → Pages**，将部署来源设置为 **GitHub Actions**。每次推送到 `main` 后，GitHub Actions 会自动安装依赖、构建 Jekyll 网站并发布。

## 绑定自定义域名

项目根目录的 `CNAME` 文件内容为：

```text
ypj0.xyz
```

在 DNS 控制台添加四条 A 记录：

```text
@  A  185.199.108.153
@  A  185.199.109.153
@  A  185.199.110.153
@  A  185.199.111.153
```

如需使用 `www.ypj0.xyz`，再添加：

```text
www  CNAME  ypj0.github.io
```

DNS 生效后，在 GitHub 的 **Settings → Pages → Custom domain** 中填写 `ypj0.xyz`，等待证书签发后开启 **Enforce HTTPS**。

## GitHub 评论

博客使用 Utterances，读者通过 GitHub 账号登录，评论保存在博客仓库的 Issues 中：

```yaml
comments:
  provider: utterances
  utterances:
    repo: ypj0/ypj_blog
    issue_term: pathname
```

使用前需要安装 [Utterances App](https://github.com/apps/utterances)，授权访问 `ypj0/ypj_blog`，并开启仓库的 Issues 功能。

## 新增文章

在 `_posts/` 下创建 `YYYY-MM-DD-title.md` 文件：

```markdown
---
title: 我的新文章
date: 2026-09-27 20:00:00 +0800
categories: [技术]
tags: [学习]
---

这里写文章正文。
```

## 更新博客

本地预览确认无误后提交：

```bash
cd ypj_blog
source tools/use-local-ruby.sh
bundle exec jekyll serve --livereload

git add .
git commit -m "feat: add a new post"
git push
```

GitHub Actions 会自动部署新版本，可以在 **Actions → Deploy Blog** 查看状态。

修改关于页面编辑 `_tabs/about.md`；修改站点名称、域名、头像、邮箱或评论编辑 `_config.yml`。不要直接修改 `_site/`，它是 Jekyll 自动生成的目录。
