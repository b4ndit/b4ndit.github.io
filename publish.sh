#!/bin/bash

# Blog Publishing Script for b4ndit.github.io
# This script helps manage and publish blog posts to GitHub Pages

set -e

BLOG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
POSTS_DIR="$BLOG_DIR/_posts"
DRAFTS_DIR="$BLOG_DIR/_drafts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure gem environment is set
export GEM_HOME="$HOME/.gems"
export PATH="$HOME/.gems/bin:$PATH"

print_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  new <title>      Create a new blog post with the given title"
    echo "  draft <title>    Create a new draft post"
    echo "  publish <draft>  Move a draft to published posts"
    echo "  serve            Start local Jekyll server for preview"
    echo "  deploy [message] Build, commit, and push to GitHub Pages"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 new \"My Awesome Post\""
    echo "  $0 draft \"Work in Progress\""
    echo "  $0 publish 2024-01-06-work-in-progress.markdown"
    echo "  $0 serve"
    echo "  $0 deploy \"Added new post about security\""
}

create_post() {
    local title="$1"
    local is_draft="$2"

    if [ -z "$title" ]; then
        echo -e "${RED}Error: Post title is required${NC}"
        exit 1
    fi

    # Generate filename-safe title
    local date=$(date +%Y-%m-%d)
    local slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
    local filename="${date}-${slug}.markdown"

    local target_dir="$POSTS_DIR"
    if [ "$is_draft" = "true" ]; then
        mkdir -p "$DRAFTS_DIR"
        target_dir="$DRAFTS_DIR"
    fi

    local filepath="${target_dir}/${filename}"

    if [ -f "$filepath" ]; then
        echo -e "${RED}Error: File already exists: $filepath${NC}"
        exit 1
    fi

    # Create post with frontmatter
    cat > "$filepath" <<EOF
---
layout: post
title: "$title"
date: $(date +"%Y-%m-%d %H:%M:%S %z")
tags: []
---

Write your post content here...

EOF

    echo -e "${GREEN}Created new $([ "$is_draft" = "true" ] && echo "draft" || echo "post"): $filepath${NC}"
    echo -e "${BLUE}Opening in editor...${NC}"

    # Try to open in user's preferred editor
    ${EDITOR:-nano} "$filepath"
}

publish_draft() {
    local draft_name="$1"

    if [ -z "$draft_name" ]; then
        echo -e "${YELLOW}Available drafts:${NC}"
        ls -1 "$DRAFTS_DIR" 2>/dev/null || echo "No drafts found"
        exit 0
    fi

    local draft_path="$DRAFTS_DIR/$draft_name"

    if [ ! -f "$draft_path" ]; then
        echo -e "${RED}Error: Draft not found: $draft_path${NC}"
        exit 1
    fi

    # Update the date in filename
    local date=$(date +%Y-%m-%d)
    local basename=$(basename "$draft_name")
    local title_part=$(echo "$basename" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')
    local new_filename="${date}-${title_part}"
    local new_path="$POSTS_DIR/$new_filename"

    # Move to posts directory
    mv "$draft_path" "$new_path"

    echo -e "${GREEN}Published draft to: $new_path${NC}"
}

serve_local() {
    echo -e "${BLUE}Starting Jekyll development server...${NC}"
    echo -e "${YELLOW}Server will be available at: http://127.0.0.1:4000${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""

    cd "$BLOG_DIR"
    bundle exec jekyll serve --host 127.0.0.1 --port 4000 --livereload
}

deploy() {
    local commit_message="$1"

    if [ -z "$commit_message" ]; then
        commit_message="Update blog content"
    fi

    cd "$BLOG_DIR"

    echo -e "${BLUE}Checking git status...${NC}"
    git status

    echo ""
    echo -e "${YELLOW}Files to be committed:${NC}"
    git diff --name-status
    git diff --cached --name-status

    echo ""
    read -p "Do you want to continue with deployment? (y/n) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Deployment cancelled${NC}"
        exit 0
    fi

    echo -e "${BLUE}Adding changes...${NC}"
    git add .

    echo -e "${BLUE}Committing changes...${NC}"
    git commit -m "$commit_message"

    echo -e "${BLUE}Pushing to GitHub...${NC}"
    git push origin main || git push origin master

    echo -e "${GREEN}Successfully deployed to GitHub Pages!${NC}"
    echo -e "${BLUE}Your changes will be live at https://b4ndit.github.io in a few moments${NC}"
}

# Main script logic
case "${1:-help}" in
    new)
        create_post "$2" "false"
        ;;
    draft)
        create_post "$2" "true"
        ;;
    publish)
        publish_draft "$2"
        ;;
    serve)
        serve_local
        ;;
    deploy)
        deploy "$2"
        ;;
    help|--help|-h)
        print_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
