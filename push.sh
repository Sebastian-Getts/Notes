#!/biin/bash
hexo clean && hexo g && hexo deploy && git add -A && git commit -m "${1}" && git push origin source
