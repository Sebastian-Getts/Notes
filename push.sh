#!/biin/bash
hexo clean && hexo g && hexo deploy && git add -A && git commit -m "update from Mac" && git push origin source
