# Blog Drafts

This directory contains draft posts that are not yet ready to be published.

## How Drafts Work

### Creating a Draft

**Option 1: Use the publish script**
```bash
./publish.sh draft "Your Post Title"
```

**Option 2: Create manually**
Create a file in `_drafts/` with just the title (no date needed):
```
_drafts/my-awesome-post.markdown
```

### Draft File Structure

```markdown
---
layout: post
title: "Your Post Title"
tags:
- tag1
- tag2
---

Your content here...
```

**Note:** Drafts don't need a date in the filename or frontmatter!

## Previewing Drafts Locally

To see drafts on your local development server:

```bash
# Option 1: Using the publish script with --drafts flag
bundle exec jekyll serve --drafts

# Option 2: Manual command
cd /home/bandit/Documents/Python\ Workspace/b4ndit.github.io
export GEM_HOME="$HOME/.gems"
export PATH="$HOME/.gems/bin:$PATH"
bundle exec jekyll serve --host 127.0.0.1 --port 4000 --drafts
```

Drafts will appear as if they were published today.

## Publishing a Draft

When your draft is ready to go live:

```bash
./publish.sh publish my-awesome-post.markdown
```

This will:
1. Add today's date to the filename (e.g., `2026-01-06-my-awesome-post.markdown`)
2. Move it from `_drafts/` to `_posts/`
3. The post will now appear on your published blog

## Listing Current Drafts

```bash
./publish.sh publish
```

Running the publish command without a filename will list all available drafts.

## Important Notes

- **Drafts are NOT published** to your live site (even if you push to GitHub)
- Jekyll only includes drafts when using the `--drafts` flag
- This is perfect for work-in-progress posts
- You can commit drafts to git for backup without publishing them

## Example Workflow

```bash
# 1. Create a new draft
./publish.sh draft "Analyzing RFID Security"

# 2. Edit the draft (opens in your editor)
# Write your content...

# 3. Preview it locally
bundle exec jekyll serve --drafts
# Visit http://127.0.0.1:4000

# 4. When ready, publish it
./publish.sh publish 2026-01-06-analyzing-rfid-security.markdown

# 5. Deploy to GitHub Pages
./publish.sh deploy "Added new post about RFID security"
```
