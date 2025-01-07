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
alias py="python3"

if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

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

# Function to stash all changes except the selected ones
function git_stash_exclude() {
  # Get the list of changed files
  local files=($(git status --porcelain=v1 | awk '{print $2}'))
  
  # Use fzf to select files to exclude from stashing
  local exclude=($(printf "%s\n" "${files[@]}" | fzf --multi --preview 'git diff --color=always -- "{}"'))
  
  if [[ -z "$exclude" ]]; then
    echo "No files selected to exclude. Stashing everything."
    git stash -u
    return
  fi

  # Temporarily stash all changes
  git stash -u

  # Reapply changes for excluded files
  for file in "${exclude[@]}"; do
    git stash pop --quiet
    git checkout stash@{0} -- "$file"
  done

  # Remove the stash entry if it's empty
  git stash drop --quiet
  echo "Stashed all changes except: ${exclude[*]}"
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

## Set up fzf shell integration
source <(fzf --zsh)

########

# nvm: https://github.com/nvm-sh/nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Execute config local to this machine
[ -s "$HOME/.zsh/local.zsh" ] && \. "$HOME/.zsh/local.zsh"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/akiva/.cache/lm-studio/bin"

# Created by `pipx` on 2024-12-29 03:48:41
export PATH="$PATH:/Users/akiva/.local/bin"
