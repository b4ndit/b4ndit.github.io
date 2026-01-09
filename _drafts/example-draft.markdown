---
layout: post
title: "Example Draft Post"
tags:
- example
---

This is an example draft post. Drafts are posts without a date in the filename.

## How Drafts Work

- Drafts live in the `_drafts/` folder
- They don't need a date in the filename (just `title.markdown`)
- They won't appear on your published site
- Preview drafts locally with: `bundle exec jekyll serve --drafts`

## When You're Ready to Publish

Use the publish script:
```bash
./publish.sh publish example-draft.markdown
```

This will:
1. Add today's date to the filename
2. Move it from `_drafts/` to `_posts/`
3. Make it live on your blog

Delete this example when you're ready to create your first real draft!
