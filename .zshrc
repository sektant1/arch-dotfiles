# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Compile + run: cppr main.cpp [program args...]
cppr() {
  if [ $# -lt 1 ]; then
    echo "usage: cppr <file.cpp> [args...]"
    return 2
  fi

  local src="$1"; shift
  local cxx="${CXX:-g++}"
  local std="${CPPSTD:-c++23}"
  local exe="/tmp/${USER}-cppr-$(basename "${src%.*}")"

  "$cxx" -std="$std" -O2 -pipe \
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion \
    "$src" -o "$exe" || return $?

  "$exe" "$@"
}

# Debug/sanitize build: cpprd main.cpp [program args...]
cpprd() {
  if [ $# -lt 1 ]; then
    echo "usage: cpprd <file.cpp> [args...]"
    return 2
  fi

  local src="$1"; shift
  local cxx="${CXX:-g++}"
  local std="${CPPSTD:-c++23}"
  local exe="/tmp/${USER}-cpprd-$(basename "${src%.*}")"

  "$cxx" -std="$std" -O0 -g3 -pipe \
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion \
    -fsanitize=address,undefined -fno-omit-frame-pointer \
    "$src" -o "$exe" || return $?

  "$exe" "$@"
}


source /usr/share/cachyos-zsh-config/cachyos-config.zsh

alias "stremio"="flatpak run com.stremio.Stremio"
alias nvchad='NVIM_APPNAME="nvchad" nvim'

alias "nvim"="bob run nightly"
export EDITOR="bob run nightly"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH="/home/garrosh/.bun/bin:$PATH"
export PATH="$HOME/bin:$PATH"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export W3CHAMP='export WINEPREFIX="$HOME/Faugus/battlenet"
wine "C:\Program Files\W3Champions\W3Champions.exe"'
export PATH="$HOME/.local/bin:$PATH"
alias config='/usr/bin/git --git-dir=/home/garrosh/.dotfiles/ --work-tree=/home/garrosh'
