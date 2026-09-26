# 博客修改清单

项目目录：`ypj_blog/`。原始主题目录 `jekyll-theme-chirpy/` 未被修改。

## 必须修改

打开 `_config.yml`，修改带有 `【需要修改】` 标记的配置：

| 配置 | 作用 | 示例 |
| --- | --- | --- |
| `title` | 博客名称 | `YPJ 的博客` |
| `tagline` | 首页副标题 | `记录技术、学习与生活` |
| `description` | SEO 和 RSS 描述 | `一个记录技术的个人博客` |
| `url` | 部署后的完整域名 | `https://blog.example.com` |
| `github.username` | GitHub 用户名 | `ypj0` |
| `social.name` | 作者名称 | `YPJ` |
| `social.email` | 联系邮箱 | `me@example.com` |
| `social.links` | 作者主页 | `https://github.com/ypj0` |
| `avatar` | 头像路径 | `/assets/img/avatar.jpg` |

## 头像

将图片放入 `assets/img/`，例如 `assets/img/avatar.jpg`，然后设置：

```yaml
avatar: /assets/img/avatar.jpg
```

如果暂时不需要头像，保持空值即可。

## 评论

评论默认关闭。需要 Giscus 时，在 `_config.yml` 中填写 `comments.giscus` 下的字段，并将：

```yaml
comments:
  provider: giscus
```

Giscus 需要 GitHub 仓库开启 Discussions。没有配置完成前不要启用，否则文章页会显示错误的评论组件。

## 写文章

在 `_posts/` 下新建 `YYYY-MM-DD-title.md` 文件，使用 Front Matter：

```markdown
---
title: 我的新文章
date: 2026-09-26 20:00:00 +0800
categories: [技术]
tags: [jekyll]
---

文章正文。
```

## 本地预览

```bash
cd ypj_blog
bundle install
npm install
npm run build
bundle exec jekyll serve --livereload
```

访问 <http://127.0.0.1:4000>。

## 发布到 GitHub

在 GitHub 创建一个空仓库，例如 `ypj_blog`，然后执行：

```bash
cd ypj_blog
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin git@github.com:你的用户名/ypj_blog.git
git push -u origin main
```

仓库的 Settings → Pages 中选择 GitHub Actions。之后每次推送到 `main`，工作流会自动构建和发布。
