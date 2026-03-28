#!/usr/bin/env bash
# Claude Code status line — mirrors your p10k prompt
# Elements: user@host  cwd  git  time | model  usage_bar  ctx_bar

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# ---------------------------------------------------------------------------
# make_bar PERCENT [WIDTH]
#   Renders a compact block-character progress bar with Naysayer color coding.
#   Color thresholds: <50% linefg #126367 | 50-79% warn #ffaa00 | 80%+ red
# ---------------------------------------------------------------------------
make_bar() {
  local pct="$1"
  local width="${2:-10}"
  local pct_int
  pct_int=$(printf '%.0f' "$pct")

  # Pick color based on threshold
  local r g b
  if [ "$pct_int" -ge 80 ]; then
    r=255; g=0;   b=0
  elif [ "$pct_int" -ge 50 ]; then
    r=255; g=170; b=0
  else
    r=18;  g=99;  b=103
  fi

  # Block characters in eighths: ▏▎▍▌▋▊▉█ (plus space for empty)
  local eighths_chars=' ▏▎▍▌▋▊▉█'

  # Total eighths filled = pct * width / 100 * 8
  local total_eighths=$(( pct_int * width * 8 / 100 ))
  local full_blocks=$(( total_eighths / 8 ))
  local remainder=$(( total_eighths % 8 ))

  local bar=""
  local i=0
  while [ $i -lt $full_blocks ]; do
    bar="${bar}█"
    i=$(( i + 1 ))
  done

  # Partial block (skip if remainder is 0 or bar is already full)
  if [ $remainder -gt 0 ] && [ $full_blocks -lt $width ]; then
    # Extract the nth character from eighths_chars (0-indexed, 0=space … 8=█)
    partial=$(printf '%s' "$eighths_chars" | cut -c$(( remainder + 1 )))
    bar="${bar}${partial}"
    full_blocks=$(( full_blocks + 1 ))
  fi

  # Pad with spaces to reach full width
  while [ $full_blocks -lt $width ]; do
    bar="${bar} "
    full_blocks=$(( full_blocks + 1 ))
  done

  # Wrap bar in color, append percentage label
  printf '\033[38;2;%d;%d;%dm[%s] %d%%\033[0m' "$r" "$g" "$b" "$bar" "$pct_int"
}

# user (linefg #126367)
user_host=$(printf '\033[38;2;18;99;103m%s\033[0m' "$(whoami)")

# cwd (blue #66D9EF) — abbreviate $HOME to ~
display_cwd="${cwd/#$HOME/\~}"
dir_part=$(printf '\033[38;2;102;217;239m%s\033[0m' "$display_cwd")

# git info (linefg / warn on dirty)
git_part=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # check dirty
    if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
      git_part=$(printf ' \033[38;2;18;99;103m%s\033[38;2;255;170;0m*\033[0m' "$branch")
    else
      git_part=$(printf ' \033[38;2;18;99;103m%s\033[0m' "$branch")
    fi
  fi
fi

# time (fg #d0b892)
time_part=$(printf '\033[38;2;208;184;146m%s\033[0m' "$(date +%H:%M:%S)")

# model (subtle)
model_part=""
[ -n "$model" ] && model_part=$(printf '\033[38;2;18;99;103m%s\033[0m' "$model")

# usage bar — 5-hour API rate limit (only shown when data is available)
usage_bar_part=""
if [ -n "$five_hour_pct" ]; then
  usage_bar_part=" $(make_bar "$five_hour_pct" 10)"
  # Prepend a dim label
  usage_bar_part=$(printf '\033[38;2;18;99;103mapi:\033[0m%s' "$usage_bar_part")
fi

# context bar — context window usage (only shown when data is available)
ctx_bar_part=""
if [ -n "$used_pct" ]; then
  ctx_bar_part=" $(make_bar "$used_pct" 10)"
  ctx_bar_part=$(printf '\033[38;2;18;99;103mctx:\033[0m%s' "$ctx_bar_part")
fi

# Compose line
line="${user_host}  ${dir_part}${git_part}  ${time_part}"
if [ -n "$model_part" ]; then
  line="${line}  ${model_part}"
  [ -n "$usage_bar_part" ] && line="${line}  ${usage_bar_part}"
  [ -n "$ctx_bar_part" ]   && line="${line}  ${ctx_bar_part}"
fi

printf '%s\n' "$line"
