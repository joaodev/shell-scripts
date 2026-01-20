#!/usr/bin/env bash

################################################################################
# Shell Menu Script
# Description: Interactive menu to run available setup scripts
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(pwd)"
SCRIPT_NAME="$(basename "$0")"

print_header() {
  echo "========================================"
  echo "$1"
  echo "========================================"
}

find_categories() {
  # find directories that contain .sh files (exclude hidden dirs like .git)
  mapfile -t categories < <(find . -type f -name "*.sh" -not -path "./.git/*" -printf '%h\n' | sed 's|^\./||' | sort -u)
  # normalize empty directory to "."
  for i in "${!categories[@]}"; do
    if [ -z "${categories[$i]}" ]; then
      categories[$i]='.'
    fi
  done
}

choose_category() {
  while true; do
    find_categories
    if [ ${#categories[@]} -eq 0 ]; then
      echo "No shell scripts found in the repository."
      return 1
    fi

    PS3="Select a category (or 0 to Exit): "
    echo
    print_header "Categories"
    options=("All scripts" "${categories[@]}")
    select opt in "${options[@]}"; do
      if [ -z "$opt" ]; then
        echo "Invalid option."
        break
      fi
      case $REPLY in
        0) return 1 ;;
        1) CHOSEN_CATEGORY="ALL"; return 0 ;;
        *) CHOSEN_CATEGORY="$opt"; return 0 ;;
      esac
    done
  done
}

list_scripts_in_category() {
  local cat="$1"
  if [ "$cat" = "ALL" ]; then
    mapfile -t scripts < <(find . -type f -name "*.sh" -not -path "./.git/*" | sort)
  else
    mapfile -t scripts < <(find "$cat" -maxdepth 1 -type f -name "*.sh" | sort)
  fi
}

choose_script() {
  while true; do
    list_scripts_in_category "$CHOSEN_CATEGORY"
    if [ ${#scripts[@]} -eq 0 ]; then
      echo "No scripts found in this category."
      return 1
    fi

    echo
    print_header "Scripts in ${CHOSEN_CATEGORY}"
    PS3="Select a script (or 0 to go back): "

    options=("${scripts[@]}")
    select opt in "${options[@]}"; do
      if [ -z "$opt" ]; then
        echo "Invalid option."
        break
      fi
      if [ "$REPLY" -eq 0 ]; then
        return 1
      fi
      CHOSEN_SCRIPT="$opt"
      return 0
    done
  done
}

script_actions() {
  while true; do
    echo
    print_header "Script: ${CHOSEN_SCRIPT}"
    echo "1) Show help (-h)"
    echo "2) Run" 
    echo "3) Run with -y (non-interactive)"
    echo "4) Run with sudo"
    echo "5) Back"
    read -r -p "Choose an action [1-5]: " action
    case "$action" in
      1)
        echo; echo "---- Help output for ${CHOSEN_SCRIPT} ----"; echo
        bash "$CHOSEN_SCRIPT" -h || true
        echo; read -r -p "Press Enter to continue..." _ ;;
      2)
        run_script "" ;;
      3)
        run_script "-y" ;;
      4)
        run_script_with_sudo ;;
      5)
        return 0 ;;
      *) echo "Invalid option." ;;
    esac
  done
}

run_script() {
  local extra="$1"
  if [ ! -x "$CHOSEN_SCRIPT" ]; then
    read -r -p "Script is not executable. Make it executable? [y/N]: " resp
    case "$resp" in
      [yY]|[yY][eE][sS]) chmod +x "$CHOSEN_SCRIPT" ;;
      *) echo "Will attempt to run using bash..." ;;
    esac
  fi

  read -r -p "Enter additional arguments (leave empty for none): " argstr
  # build args array
  if [ -n "$argstr" ]; then
    read -r -a ARGS <<<"$argstr"
  else
    ARGS=()
  fi
  # prepend extra if provided (e.g. -y)
  if [ -n "$extra" ]; then
    ARGS=("$extra" "${ARGS[@]}")
  fi

  echo; echo "---- Running: bash $CHOSEN_SCRIPT ${ARGS[*]} ----"; echo
  bash "$CHOSEN_SCRIPT" "${ARGS[@]}"
  local status=$?
  echo; echo "---- Script finished with exit code: $status ----"
  read -r -p "Press Enter to continue..." _
}

run_script_with_sudo() {
  read -r -p "Enter additional arguments (leave empty for none): " argstr
  if [ -n "$argstr" ]; then
    read -r -a ARGS <<<"$argstr"
  else
    ARGS=()
  fi
  echo; echo "---- Running with sudo: sudo bash $CHOSEN_SCRIPT ${ARGS[*]} ----"; echo
  sudo bash "$CHOSEN_SCRIPT" "${ARGS[@]}"
  local status=$?
  echo; echo "---- Script finished with exit code: $status ----"
  read -r -p "Press Enter to continue..." _
}

# Main loop
while true; do
  echo
  print_header "Shell Scripts Menu"
  echo "Repository: $ROOT_DIR"
  echo "1) Choose category & script"
  echo "2) Search script by name"
  echo "3) Exit"
  read -r -p "Select an option [1-3]: " main_choice
  case "$main_choice" in
    1)
      if choose_category; then
        if choose_script; then
          script_actions
        fi
      fi ;;
    2)
      read -r -p "Enter search term: " term
      mapfile -t matches < <(find . -type f -name "*.sh" -not -path "./.git/*" | grep -i -- "$term" || true)
      if [ ${#matches[@]} -eq 0 ]; then
        echo "No matches for '$term'"
        read -r -p "Press Enter to continue..." _
      else
        echo; print_header "Search results"
        select opt in "${matches[@]}" "Back"; do
          if [ -z "$opt" ]; then echo "Invalid option"; break; fi
          if [ "$opt" = "Back" ]; then break; fi
          CHOSEN_SCRIPT="$opt"
          script_actions
          break
        done
      fi ;;
    3)
      echo "Goodbye."; exit 0 ;;
    *) echo "Invalid option." ;;
  esac
done
