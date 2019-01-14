#!/usr/bin/env bash
set -e
case $1 in
    check)      jekyll clean && jekyll build && jekyll doctor ;;
    preview)    jekyll serve --watch --drafts ;;
    *)          echo "'check' or 'preview' is allowed"; exit -1 ;;
esac

