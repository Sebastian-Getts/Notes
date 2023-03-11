#!/biin/bash
# hexo clean && hexo g && hexo deploy && git add -A && git commit -m "${1}" && git push origin source

CHOICE=''

function hexo_opr {
    echo '=======hexo start clean========'
    hexo clean
    if [[ $? -ne 0 ]]; then
        echo '======hexo clean failed======'
        exit
    fi
    echo '=======hexo start generate======'
    hexo g
    if [[ $? -ne 0 ]]; then
        echo '=========hexo generate failed======='
        exit
    fi
    echo '=======hexo start deploy========='
    hexo deploy
    if [[ $? -ne 0 ]]; then
        echo '=========hexo deploy failed======='
        exit
    fi
}

function git_opr {
    read -t 15 -p "commit messsage: " MESSAGE
    echo '===========git status=================='
    git status
    echo '===========git status=================='
    choice 'Do you want to continue?(y/n) '
    if [[ $? = 'y' ]]; then
        echo '==========start git add && comit && push=========='
        git add -A
        git commit -m $MESSAGE
        git push
    else
        exit
    fi
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
    echo 'Do you want to execute hexo or git? '
    PS3="Enter option: "
    select option in "git" "hexo" "git && hexo" "Exit"
    do
        case $option in
            "git")
                git_opr;;
            "hexo")
                hexo_opr;;
            "git && hexo")
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

main
#hexoOpr
#gitOpr
