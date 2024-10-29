setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# Set up shell editor preferences
export EDITOR=hx
export VISUAL=hx

# Add colors to Terminal
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

alias branch="git rev-parse --abbrev-ref HEAD"

edit() {
    local files=$(git status -s | awk '{print $2}')
    local file_count
  
    if [ -z "$files" ]; then
      file_count=0
    else
      file_count=$(echo "$files" | wc -l | tr -d ' ')
    fi

    if [ "$file_count" -eq 1 ]; then
        $EDITOR "$files"
    elif [ "$file_count" -gt 1 ]; then
        local selected_file=$(echo "$files" | fzf)
        if [ -n "$selected_file" ]; then
            $EDITOR "$selected_file"
        fi
    else
        $EDITOR
    fi
}


# git
zstyle ':completion:*:*:git:*' script ~/.git-completion.zsh
fpath=(~/.zsh $fpath)

[ -s "$HOME/.git-prompt.sh" ] && source "$HOME/.git-prompt.sh"

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"

setopt PROMPT_SUBST ; PS1='$(__git_ps1 "[%s] ")\$ '

#########

# jump: https://www.datascienceworkshops.com/blog/quickly-navigate-your-filesystem-from-the-command-line/

export MARKPATH=$HOME/.marks
function jump { 
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function mark { 
  mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark { 
  rm -i "$MARKPATH/$1"
}
function marks {
  \ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}

function _completemarks {
  reply=($(ls $MARKPATH))
}

compctl -K _completemarks jump
compctl -K _completemarks unmark

########

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

########

# nvm: https://github.com/nvm-sh/nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Execute config local to this machine
[ -s "$HOME/.zsh/local.zsh" ] && \. "$HOME/.zsh/local.zsh"

