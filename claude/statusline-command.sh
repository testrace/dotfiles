#!/bin/bash
# Claude Code status line: directory, git branch, model, context usage
input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

short_dir=$dir
case "$dir" in
  "$HOME"*) short_dir="~${dir#"$HOME"}" ;;
esac
out=$(printf '\033[34m%s\033[0m' "$short_dir")

branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
[ -n "$branch" ] && out+=$(printf ' \033[32m(%s)\033[0m' "$branch")

[ -n "$model" ] && out+=$(printf ' \033[35m%s\033[0m' "$model")
# Additional items: context usage and rate limits (joined onto the same line)
line2=()
[ -n "$ctx" ] && line2+=("$(printf '\033[33mctx %.0f%%\033[0m' "$ctx")")

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Time left until a reset given as epoch seconds, e.g. " (2h13m)" or " (3d4h)"
remaining() {
  case "$1" in ''|*[!0-9]*) return ;; esac
  local left=$(( $1 - $(date +%s) ))
  [ "$left" -le 0 ] && return
  local d=$(( left / 86400 )) h=$(( left % 86400 / 3600 )) m=$(( left % 3600 / 60 ))
  if [ "$d" -gt 0 ]; then printf ' (%dd%dh)' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf ' (%dh%dm)' "$h" "$m"
  else printf ' (%dm)' "$m"
  fi
}

[ -n "$five" ] && line2+=("$(printf '\033[36m5h %.0f%%%s\033[0m' "$five" "$(remaining "$five_reset")")")
[ -n "$week" ] && line2+=("$(printf '\033[36m7d %.0f%%%s\033[0m' "$week" "$(remaining "$week_reset")")")

sep=$(printf ' \033[2m|\033[0m ')
for item in "${line2[@]}"; do
  out+="${sep}${item}"
done
echo "$out"

# Second line: system resources (CPU / RAM / DISK), macOS
cpu=$(ps -A -o %cpu= | awk -v n="$(sysctl -n hw.ncpu)" '{s+=$1} END {v=s/n; if (v>100) v=100; printf "%.0f", v}')
mem=$(vm_stat | awk -v total="$(sysctl -n hw.memsize)" '
  /page size of/ {ps=$8}
  /Pages active/ {a=$3}
  /Pages wired down/ {w=$4}
  /occupied by compressor/ {c=$5}
  END {printf "%.1f/%.0fG", (a+w+c)*ps/1073741824, total/1073741824}')
disk=$(df -k /System/Volumes/Data 2>/dev/null | awk 'NR==2 {printf "%.0f/%.0fG", $3/1048576, $2/1048576}')

res=()
[ -n "$cpu" ]  && res+=("$(printf '\033[33mCPU %s%%\033[0m' "$cpu")")
[ -n "$mem" ]  && res+=("$(printf '\033[36mRAM %s\033[0m' "$mem")")
[ -n "$disk" ] && res+=("$(printf '\033[35mDISK %s\033[0m' "$disk")")
if [ "${#res[@]}" -gt 0 ]; then
  line=${res[0]}
  for item in "${res[@]:1}"; do line+="${sep}${item}"; done
  echo "$line"
fi
exit 0
