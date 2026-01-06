# Brandon's Blog

Personal blog built with Jekyll and hosted on GitHub Pages.

## Theme
Using the [Hacker theme](https://github.com/pages-themes/hacker) - a minimalist terminal-style theme.

## Local Development

```bash
# Install dependencies
bundle install

# Run local server
bundle exec jekyll serve

# Visit
http://127.0.0.1:4000
```

## Publishing

Use the `publish.sh` script for convenience:
```bash
# Create new post
./publish.sh new "Post Title"

# Preview locally
./publish.sh serve

# Deploy
./publish.sh deploy "Commit message"
```

## Posts
Blog posts are in the `_posts/` directory with the format: `YYYY-MM-DD-title.markdown`
