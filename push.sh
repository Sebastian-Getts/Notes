#!/biin/bash
# hexo clean && hexo g && hexo deploy && git add -A && git commit -m "${1}" && git push origin source

CHOICE=''

function hexo_opr {
    echo '===hexo start to clean...'
    hexo clean >> process.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo '===hexo clean failed'
        exit
    fi
    echo '===hexo clean done'
    echo '===hexo start to generate...'
    hexo g >> process.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo '===hexo generate failed======='
        exit
    fi
    echo '===hexo generate done'
    echo '===hexo start to deploy...'
    hexo d >> process.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo '===hexo deploy failed'
        exit
    fi
    echo '===hexo deploy done'
    echo -e "\n"
}

function git_opr {
    echo '===git start...'
    sleep 3
    git status
    read -t 15 -p "Here's git status info, do you want to continue?(y/n): " GIT_OPR_ANS
    if [[ ${GIT_OPR_ANS} != 'y' ]]; then
        echo "bye~"
        exit;
    fi
    echo '===git add...'
    git add -A
    echo '===git add All done'
    git status
    read -t 60 -p "commit messsage: " MESSAGE
    echo '===git commit...'
    git commit -m "$MESSAGE" >> process.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo '==git commit failed'
        exit
    fi
    echo '===git commit done'
    echo '===git push...'
    git push
    if [[ $? -ne 0 ]]; then
        echo '===git psuh failed'
    fi
    echo '===git push done'
}

function choice {
    CHIOCE=''
    local prompt="$*"
    local answer

    read -p "$prompt" answer
    case "$answer" in
        [yY1] ) CHOICE='y';;
        [nN0] ) CHOICE='n';;
        *     ) CHOICE="$answer";;
    esac
}

function main {
    init_env
    echo 'Do you want to execute hexo or git? '
    PS3="Enter option: "
    select option in "git" "hexo" "hexo && git" "Exit"
    do
        case $option in
            "git")
                git_opr;;
            "hexo")
                hexo_opr;;
            "hexo && git")
                hexo_opr
                git_opr;;
            "Exit")
                exit;;
            *)
                echo 'Sorry, wrong selection.'
                exit;;
            esac
        done
}

function init_env() {
    cat process.log > /dev/null
    if [[ $? -ne 0 ]]; then
        touch process.log
    fi
    cat process.log > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "failed to touch process.log"
    fi
    "" > process.log
}

main
