#!/biin/bash
hexo clean && hexo g && hexo deploy && git add -A && git commit -m "update from Ubuntu" && git push origin source
