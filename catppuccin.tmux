#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
  # Aggregate all commands in one array
  local tmux_commands=()

  # Catppuccin Mocha color palette
  local thm_bg="#1e1e2e"
  local thm_fg="#cdd6f4"
  local thm_cyan="#89dceb"
  local thm_black="#181825"
  local thm_gray="#313244"
  local thm_magenta="#cba6f7"
  local thm_pink="#f5c2e7"
  local thm_red="#f38ba8"
  local thm_green="#a6e3a1"
  local thm_yellow="#f9e2af"
  local thm_blue="#89b4fa"
  local thm_orange="#e6b450"
  local thm_black4="#585b70"

  # status
  set status "on"
  set status-bg "${thm_bg}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${thm_cyan},bg=${thm_gray},align=centre"
  set message-command-style "fg=${thm_cyan},bg=${thm_gray},align=centre"

  # panes
  set pane-border-style "fg=${thm_gray}"
  set pane-active-border-style "fg=${thm_blue}"

  # windows
  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  # Statusline
  local right_separator
  right_separator="$(get_tmux_option "@catppuccin_right_separator" "")"
  readonly right_separator

  local left_separator
  left_separator="$(get_tmux_option "@catppuccin_left_separator" "")"
  readonly left_separator

  local directory
  directory="$(get_tmux_option "@catppuccin_directory" "off")"
  readonly directory

  local user
  user="$(get_tmux_option "@catppuccin_user" "off")"
  readonly user

  local host
  host="$(get_tmux_option "@catppuccin_host" "off")"
  readonly host

  local date_time
  date_time="$(get_tmux_option "@catppuccin_date_time" "off")"
  readonly date_time

  local cpu
  cpu="$(get_tmux_option "@catppuccin_cpu" "off")"
  readonly cpu

  local window_status
  readonly window_status="#[fg=$thm_bg,bg=$thm_blue] #I #[fg=$thm_fg,bg=$thm_gray] #W "

  local window_status_current
  readonly window_status_current="#[fg=colour232,bg=$thm_orange] #I #[fg=colour255,bg=colour237] #W "

  local show_session
  readonly show_session="#[bg=$thm_gray]#{?client_prefix,#[fg=$thm_orange],#[fg=$thm_green]}$right_separator#{?client_prefix,#[bg=$thm_orange],#[bg=$thm_green]}#[fg=$thm_bg] #[fg=$thm_fg,bg=$thm_gray] #S "

  local show_directory
  readonly show_directory="#[fg=$thm_pink,bg=$thm_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$thm_bg,bg=$thm_pink,nobold,nounderscore,noitalics]  #[fg=$thm_fg,bg=$thm_gray] #{s|$HOME|~|:pane_current_path} "

  local show_user
  readonly show_user="#[fg=$thm_blue,bg=$thm_gray]$right_separator#[fg=$thm_bg,bg=$thm_blue] #[fg=$thm_fg,bg=$thm_gray] #(whoami) "

  local show_host
  readonly show_host="#[fg=$thm_blue,bg=$thm_gray]$right_separator#[fg=$thm_bg,bg=$thm_blue]󰒋 #[fg=$thm_fg,bg=$thm_gray] #H "

  local show_date_time
  readonly show_date_time="#[fg=$thm_blue,bg=$thm_gray]$right_separator#[fg=$thm_bg,bg=$thm_blue] #[fg=$thm_fg,bg=$thm_gray] $date_time "

  local show_cpu
  readonly show_cpu="#[fg=$thm_yellow,bg=$thm_gray]$right_separator#[fg=$thm_bg,bg=$thm_yellow] #[fg=$thm_fg,bg=$thm_gray] #(top -bn1 | grep 'Cpu(s)' | awk '{print \$2 + \$4 \"%%\"}') "

  local columns=""

  if [[ "${directory}" == "on" ]]; then
    columns=$columns$show_directory
  fi

  if [[ "${user}" == "on" ]]; then
    columns=$columns$show_user
  fi

  if [[ "${host}" == "on" ]]; then
    columns=$columns$show_host
  fi

  if [[ "${cpu}" == "on" ]]; then
    columns=$columns$show_cpu
  fi

  if [[ "${date_time}" != "off" ]]; then
    columns=$columns$show_date_time
  fi

  columns=$columns$show_session

  set status-left ""
  set status-right "${columns}"

  setw window-status-format "${window_status}"
  setw window-status-current-format "${window_status_current}"

  # Modes
  setw clock-mode-colour "${thm_blue}"
  setw mode-style "fg=${thm_pink} bg=${thm_black4} bold"

  tmux "${tmux_commands[@]}"
}

main "$@"
