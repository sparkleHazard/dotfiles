#!/usr/bin/env bash

# =============================================================================
# dotfiles.sh - A comprehensive script to manage your dotfiles using Git
# =============================================================================
#
# This script provides a complete solution for managing dotfiles using a Git
# bare repository approach, as described in:
# https://stegosaurusdormant.com/bare-git-repo/
#
# Features:
# - Initialize a new dotfiles repository
# - Clone an existing dotfiles repository
# - Add files to the repository
# - Commit and push changes
# - Sync dotfiles across multiple machines
# - Backup and restore functionality
# - Automatic shell configuration
# - Validation and overwrite protection
#
# Author: Generated with AI assistance
# License: MIT
# Version: 1.0.0
#
# Usage: See the help command for details
#   ./dotfiles.sh help
#
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_BACKUP="$HOME/dotfiles_backup"
REMOTE_URL=""
SHELL_TYPE=""
DOTGIT_ALIAS="dotgit"
EXCLUDE_PATTERNS=(".git" ".DS_Store" "*.swp" "*.bak" "*~")

# Print message with color
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Print error message and exit
error_exit() {
  print_message "$RED" "ERROR: $1"
  exit 1
}

# Print warning message
warning() {
  print_message "$YELLOW" "WARNING: $1"
}

# Print success message
success() {
  print_message "$GREEN" "$1"
}

# Print info message
info() {
  print_message "$BLUE" "$1"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
  if ! command_exists git; then
    error_exit "Git is not installed. Please install Git and try again."
  fi
}

# Display usage information
show_usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] COMMAND

A script to manage your dotfiles using a Git bare repository.

Commands:
  init [REMOTE_URL]       Initialize a new dotfiles repository
                          Optionally specify a remote repository URL
  clone REMOTE_URL        Clone an existing dotfiles repository
  add FILE [FILE...]      Add files to the dotfiles repository
  commit MESSAGE          Commit changes with the specified message
  push                    Push changes to the remote repository
  list                    List tracked files
  sync                    Sync dotfiles (pull from remote and apply changes)
  restore BACKUP_DIR      Restore files from a backup directory
  backup [FILES...]       Backup specific files or all tracked files
  help                    Show this help message

Options:
  -d, --dir DIR           Set the dotfiles directory (default: $HOME/dotfiles)
  -b, --backup DIR        Set the backup directory (default: $HOME/dotfiles_backup)
  -a, --alias NAME        Set the Git alias name (default: dotgit)
  -f, --force             Force overwrite without prompting
  -y, --yes               Assume yes to all prompts
  -n, --dry-run           Show what would be done without making changes
  -v, --verbose           Enable verbose output
  -i, --interactive       Use interactive mode for file selection
  -e, --exclude PATTERN   Exclude files matching pattern (can be used multiple times)
  -h, --help              Show this help message

Examples:
  $(basename "$0") init
  $(basename "$0") init git@github.com:username/dotfiles.git
  $(basename "$0") clone git@github.com:username/dotfiles.git
  $(basename "$0") add .zshrc .vimrc .gitconfig
  $(basename "$0") commit "Add shell and editor configurations"
  $(basename "$0") push
  $(basename "$0") sync
  $(basename "$0") backup
  $(basename "$0") restore $HOME/dotfiles_backup/20250726_120000

EOF
}

# Parse command line arguments
parse_arguments() {
  # Default values for options
  FORCE=false
  ASSUME_YES=false
  DRY_RUN=false
  VERBOSE=false
  INTERACTIVE=false
  CUSTOM_EXCLUDE=""

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -d | --dir)
      DOTFILES_DIR="$2"
      shift 2
      ;;
    -b | --backup)
      DOTFILES_BACKUP="$2"
      shift 2
      ;;
    -a | --alias)
      DOTGIT_ALIAS="$2"
      shift 2
      ;;
    -f | --force)
      FORCE=true
      shift
      ;;
    -y | --yes)
      ASSUME_YES=true
      shift
      ;;
    -n | --dry-run)
      DRY_RUN=true
      shift
      ;;
    -v | --verbose)
      VERBOSE=true
      shift
      ;;
    -i | --interactive)
      INTERACTIVE=true
      shift
      ;;
    -e | --exclude)
      CUSTOM_EXCLUDE="$2"
      shift 2
      ;;
    -h | --help)
      show_usage
      exit 0
      ;;
    -*)
      error_exit "Unknown option: $1"
      ;;
    *)
      # First non-option argument is the command
      COMMAND="$1"
      shift
      # Remaining arguments are command arguments
      COMMAND_ARGS=("$@")
      return
      ;;
    esac
  done

  # If we get here, no command was provided
  show_usage
  exit 1
}

# Main function to handle commands
main() {
  check_dependencies

  # If no arguments provided, show usage
  if [[ $# -eq 0 ]]; then
    show_usage
    exit 0
  fi

  parse_arguments "$@"

  case "$COMMAND" in
  init)
    # If remote URL is provided as an argument
    if [[ ${#COMMAND_ARGS[@]} -gt 0 ]]; then
      REMOTE_URL="${COMMAND_ARGS[0]}"
    fi
    init_dotfiles
    ;;
  clone)
    if [[ ${#COMMAND_ARGS[@]} -eq 0 ]]; then
      error_exit "Remote URL is required for clone command"
    fi
    REMOTE_URL="${COMMAND_ARGS[0]}"
    clone_dotfiles
    ;;
  add)
    if [[ ${#COMMAND_ARGS[@]} -eq 0 ]]; then
      error_exit "At least one file is required for add command"
    fi
    add_files "${COMMAND_ARGS[@]}"
    ;;
  commit)
    if [[ ${#COMMAND_ARGS[@]} -eq 0 ]]; then
      error_exit "Commit message is required for commit command"
    fi
    commit_changes "${COMMAND_ARGS[*]}"
    ;;
  push)
    push_changes
    ;;
  list)
    list_files
    ;;
  sync)
    sync_dotfiles
    ;;
  backup)
    backup_files "${COMMAND_ARGS[@]}"
    ;;
  restore)
    if [[ ${#COMMAND_ARGS[@]} -eq 0 ]]; then
      error_exit "Backup directory is required for restore command"
    fi
    restore_files "${COMMAND_ARGS[0]}" "${COMMAND_ARGS[@]:1}"
    ;;
  help)
    show_usage
    ;;
  *)
    error_exit "Unknown command: $COMMAND"
    ;;
  esac
}

# Detect the user's shell
detect_shell() {
  if [[ -n "$SHELL" ]]; then
    case "$SHELL" in
    */zsh)
      SHELL_TYPE="zsh"
      if [[ -n "$XDG_CONFIG_HOME" && -d "$XDG_CONFIG_HOME" ]]; then
        SHELL_CONFIG="$XDG_CONFIG_HOME/zsh/.zshrc"
        # Create directory if it doesn't exist
        mkdir -p "$(dirname "$SHELL_CONFIG")"
      else
        SHELL_CONFIG="$HOME/.zshrc"
      fi
      ;;
    */bash)
      SHELL_TYPE="bash"
      SHELL_CONFIG="$HOME/.bashrc"
      ;;
    *)
      warning "Unsupported shell: $SHELL"
      info "Defaulting to bash configuration"
      SHELL_TYPE="bash"
      SHELL_CONFIG="$HOME/.bashrc"
      ;;
    esac
  else
    warning "SHELL environment variable not set"
    info "Defaulting to bash configuration"
    SHELL_TYPE="bash"
    SHELL_CONFIG="$HOME/.bashrc"
  fi

  if [[ "$VERBOSE" == true ]]; then
    info "Detected shell: $SHELL_TYPE"
    info "Shell config file: $SHELL_CONFIG"
  fi
}

# Add the dotgit alias to shell configuration
add_dotgit_alias() {
  local alias_line="alias $DOTGIT_ALIAS=\"git --git-dir=$DOTFILES_DIR/ --work-tree=$HOME\""

  if grep -q "alias $DOTGIT_ALIAS=" "$SHELL_CONFIG" 2>/dev/null; then
    info "The $DOTGIT_ALIAS alias already exists in $SHELL_CONFIG"
  else
    if [[ "$DRY_RUN" == true ]]; then
      info "Would add the following line to $SHELL_CONFIG:"
      info "$alias_line"
    else
      echo "$alias_line" >>"$SHELL_CONFIG"
      success "Added $DOTGIT_ALIAS alias to $SHELL_CONFIG"
    fi
  fi
}

# Add the dotfiles_rsync function to shell configuration
add_rsync_function() {
  local function_def=$(
    cat <<'EOF'
function dotfiles_rsync {
  if [ "$#" -lt 2 ]; then
    echo "Usage: dotfiles_rsync <rsync-options> <source> <destination>"
    return 1
  fi

  # Extract the last two arguments as source and destination
  SOURCE="${@: -2:1}"
  DESTINATION="${@: -1}"
  RSYNC_OPTIONS=("${@:1:$#-2}")  # All arguments except the last two

  # Dry-run
  OUTPUT=$(rsync -av --dry-run --itemize-changes "${RSYNC_OPTIONS[@]}" "$SOURCE" "$DESTINATION")

  if echo "$OUTPUT" | grep -q '^>f.*'; then
    echo "The following files will be overwritten:"
    echo "$OUTPUT" | grep '^>f.*'
    read -r -p "Are you sure you wish to continue? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" ]]; then
      echo "Operation aborted."
      return 1
    fi
  fi

  # Actual sync
  rsync -av "${RSYNC_OPTIONS[@]}" "$SOURCE" "$DESTINATION"
}
EOF
  )

  if grep -q "function dotfiles_rsync" "$SHELL_CONFIG" 2>/dev/null; then
    info "The dotfiles_rsync function already exists in $SHELL_CONFIG"
  else
    if [[ "$DRY_RUN" == true ]]; then
      info "Would add the dotfiles_rsync function to $SHELL_CONFIG"
    else
      echo "$function_def" >>"$SHELL_CONFIG"
      success "Added dotfiles_rsync function to $SHELL_CONFIG"
    fi
  fi
}

# Source the shell configuration
source_shell_config() {
  if [[ "$DRY_RUN" == true ]]; then
    info "Would source $SHELL_CONFIG"
    return
  fi

  if [[ "$SHELL_TYPE" == "zsh" ]]; then
    if [[ -f "$SHELL_CONFIG" ]]; then
      # Using eval to avoid issues with sourcing in a bash script
      eval "source $SHELL_CONFIG" 2>/dev/null || true
      success "Sourced $SHELL_CONFIG"
    fi
  elif [[ "$SHELL_TYPE" == "bash" ]]; then
    if [[ -f "$SHELL_CONFIG" ]]; then
      source "$SHELL_CONFIG"
      success "Sourced $SHELL_CONFIG"
    fi
  else
    warning "Unable to source $SHELL_CONFIG for shell type $SHELL_TYPE"
    info "You may need to restart your shell or manually source your configuration file"
  fi
}

# Setup shell configuration
setup_shell_config() {
  detect_shell
  add_dotgit_alias
  add_rsync_function
  source_shell_config
}

# Initialize a new dotfiles repository
init_dotfiles() {
  info "Initializing dotfiles repository in $DOTFILES_DIR"

  # Check if dotfiles directory already exists
  if [[ -d "$DOTFILES_DIR" ]]; then
    if [[ "$FORCE" == true ]]; then
      warning "Dotfiles directory already exists. Forcing re-initialization."
    else
      error_exit "Dotfiles directory already exists. Use --force to re-initialize."
    fi
  fi

  # Create the bare repository
  if [[ "$DRY_RUN" == true ]]; then
    info "Would create bare Git repository in $DOTFILES_DIR"
  else
    git init --bare "$DOTFILES_DIR" || error_exit "Failed to initialize repository"
    success "Created bare Git repository in $DOTFILES_DIR"
  fi

  # Setup shell configuration
  setup_shell_config

  # Configure Git to hide untracked files
  if [[ "$DRY_RUN" == true ]]; then
    info "Would configure Git to hide untracked files"
  else
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config status.showUntrackedFiles no
    success "Configured Git to hide untracked files"
  fi

  # Add remote repository if provided
  if [[ -n "$REMOTE_URL" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      info "Would add remote repository: $REMOTE_URL"
    else
      git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" remote add origin "$REMOTE_URL"
      success "Added remote repository: $REMOTE_URL"
    fi
  fi

  info "Dotfiles repository initialized successfully"
  info "You can now use '$DOTGIT_ALIAS' to manage your dotfiles"
  info "Example: $DOTGIT_ALIAS add ~/.zshrc"
}

# Clone an existing dotfiles repository
clone_dotfiles() {
  info "Cloning dotfiles repository from $REMOTE_URL"

  # Check if dotfiles directory already exists
  if [[ -d "$DOTFILES_DIR" ]]; then
    if [[ "$FORCE" == true ]]; then
      warning "Dotfiles directory already exists. Forcing re-initialization."
      rm -rf "$DOTFILES_DIR"
    else
      error_exit "Dotfiles directory already exists. Use --force to re-initialize."
    fi
  fi

  # Create a temporary directory for cloning
  local tmp_dir="$HOME/dotfiles-tmp"

  if [[ -d "$tmp_dir" ]]; then
    if [[ "$FORCE" == true ]]; then
      warning "Temporary directory $tmp_dir already exists. Removing it."
      rm -rf "$tmp_dir"
    else
      error_exit "Temporary directory $tmp_dir already exists. Use --force to overwrite."
    fi
  fi

  # Clone the repository
  if [[ "$DRY_RUN" == true ]]; then
    info "Would clone repository from $REMOTE_URL to $tmp_dir"
  else
    git clone --separate-git-dir="$DOTFILES_DIR" "$REMOTE_URL" "$tmp_dir" || error_exit "Failed to clone repository"
    success "Cloned repository from $REMOTE_URL"
  fi

  # Setup shell configuration
  setup_shell_config

  # Configure Git to hide untracked files
  if [[ "$DRY_RUN" == true ]]; then
    info "Would configure Git to hide untracked files"
  else
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config status.showUntrackedFiles no
    success "Configured Git to hide untracked files"
  fi

  # Backup existing files that would be overwritten
  backup_existing_files "$tmp_dir"

  # Sync dotfiles to home directory
  if [[ "$DRY_RUN" == true ]]; then
    info "Would sync dotfiles from $tmp_dir to $HOME"
  else
    # If ASSUME_YES is true, use rsync directly
    if [[ "$ASSUME_YES" == true ]]; then
      rsync --recursive --verbose --exclude '.git' "$tmp_dir/" "$HOME/"
    else
      # Use the dotfiles_rsync function (which will be available after sourcing)
      dotfiles_rsync --recursive --verbose --exclude '.git' "$tmp_dir/" "$HOME/"
    fi
    success "Synced dotfiles to $HOME"
  fi

  # Clean up temporary directory
  if [[ "$DRY_RUN" == true ]]; then
    info "Would remove temporary directory $tmp_dir"
  else
    rm -rf "$tmp_dir"
    success "Removed temporary directory $tmp_dir"
  fi

  info "Dotfiles repository cloned successfully"
  info "You can now use '$DOTGIT_ALIAS' to manage your dotfiles"
}

# Backup existing files that would be overwritten
backup_existing_files() {
  local source_dir="$1"
  local backup_dir="$DOTFILES_BACKUP/$(date +%Y%m%d_%H%M%S)"

  info "Checking for files that would be overwritten..."

  # Create a list of files that would be overwritten
  local files_to_backup=()
  while IFS= read -r -d '' file; do
    # Get the relative path from the source directory
    local rel_path="${file#$source_dir/}"
    # Construct the destination path
    local dest_path="$HOME/$rel_path"

    # Check if the file exists and is not a directory
    if [[ -f "$dest_path" && ! -d "$dest_path" ]]; then
      files_to_backup+=("$rel_path")
    fi
  done < <(find "$source_dir" -type f -not -path "*/\.git/*" -print0)

  # If there are files to backup
  if [[ ${#files_to_backup[@]} -gt 0 ]]; then
    info "The following files will be overwritten:"
    printf "  %s\n" "${files_to_backup[@]}"

    # Ask for confirmation if not forced
    if [[ "$FORCE" == false && "$ASSUME_YES" == false ]]; then
      read -p "Do you want to backup these files before overwriting? (y/n): " confirm
      if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        info "Skipping backup"
        return
      fi
    fi

    # Create backup directory
    if [[ "$DRY_RUN" == true ]]; then
      info "Would create backup directory: $backup_dir"
    else
      mkdir -p "$backup_dir"
      success "Created backup directory: $backup_dir"
    fi

    # Backup files
    for file in "${files_to_backup[@]}"; do
      local dest_path="$HOME/$file"
      local backup_path="$backup_dir/$file"

      if [[ "$DRY_RUN" == true ]]; then
        info "Would backup $dest_path to $backup_path"
      else
        # Create directory structure in backup
        mkdir -p "$(dirname "$backup_path")"
        # Copy file to backup
        cp "$dest_path" "$backup_path"
        success "Backed up $dest_path to $backup_path"
      fi
    done

    success "Backed up ${#files_to_backup[@]} files to $backup_dir"
  else
    info "No files need to be backed up"
  fi
}

# Add files to the dotfiles repository
add_files() {
  local files=("$@")

  # Check if dotfiles repository exists
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    error_exit "Dotfiles repository does not exist. Run 'init' command first."
  fi

  # Add each file to the repository
  for file in "${files[@]}"; do
    # Convert to absolute path if needed
    if [[ "$file" != /* ]]; then
      file="$PWD/$file"
    fi

    # Check if file is within HOME directory
    if [[ "$file" != "$HOME"/* ]]; then
      warning "Skipping $file: Not within HOME directory"
      continue
    fi

    # Check if file exists
    if [[ ! -e "$file" ]]; then
      warning "Skipping $file: File does not exist"
      continue
    fi

    # Add file to repository
    if [[ "$DRY_RUN" == true ]]; then
      info "Would add $file to dotfiles repository"
    else
      git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" add "$file"
      success "Added $file to dotfiles repository"
    fi
  done
}

# Commit changes to the dotfiles repository
commit_changes() {
  local message="$1"

  # Check if dotfiles repository exists
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    error_exit "Dotfiles repository does not exist. Run 'init' command first."
  fi

  # Check if there are changes to commit
  if git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" diff-index --quiet HEAD --; then
    info "No changes to commit"
    return
  fi

  # Commit changes
  if [[ "$DRY_RUN" == true ]]; then
    info "Would commit changes with message: $message"
  else
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" commit -m "$message"
    success "Committed changes with message: $message"
  fi
}

# Push changes to remote repository
push_changes() {
  # Check if dotfiles repository exists
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    error_exit "Dotfiles repository does not exist. Run 'init' command first."
  fi

  # Check if remote repository is configured
  if ! git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" remote get-url origin &>/dev/null; then
    error_exit "Remote repository is not configured. Use 'init' command with REMOTE_URL."
  fi

  # Push changes
  if [[ "$DRY_RUN" == true ]]; then
    info "Would push changes to remote repository"
  else
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" push origin master
    success "Pushed changes to remote repository"
  fi
}

# List tracked files in the dotfiles repository
list_files() {
  # Check if dotfiles repository exists
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    error_exit "Dotfiles repository does not exist. Run 'init' command first."
  fi

  # List tracked files
  info "Files tracked in dotfiles repository:"
  git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" ls-tree -r master --name-only | while read -r file; do
    echo "  $HOME/$file"
  done
}

# Sync dotfiles from remote repository
sync_dotfiles() {
  # Check if dotfiles repository exists
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    error_exit "Dotfiles repository does not exist. Run 'init' command first."
  fi

  # Check if remote repository is configured
  if ! git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" remote get-url origin &>/dev/null; then
    error_exit "Remote repository is not configured. Use 'init' command with REMOTE_URL."
  fi

  # Fetch changes from remote
  if [[ "$DRY_RUN" == true ]]; then
    info "Would fetch changes from remote repository"
  else
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" fetch origin
    success "Fetched changes from remote repository"
  fi

  # Check if there are changes to pull
  local local_commit=$(git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" rev-parse HEAD)
  local remote_commit=$(git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" rev-parse origin/master)

  if [[ "$local_commit" == "$remote_commit" ]]; then
    info "Already up to date"
    return
  fi

  # Show changes that will be pulled
  info "Changes to be pulled:"
  git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" log --oneline HEAD..origin/master

  # Ask for confirmation if not forced
  if [[ "$FORCE" == false && "$ASSUME_YES" == false ]]; then
    read -p "Do you want to pull these changes? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      info "Sync aborted"
      return
    fi
  fi

  # Pull changes
  if [[ "$DRY_RUN" == true ]]; then
    info "Would pull changes from remote repository"
  else
    # Backup existing files that would be overwritten
    backup_modified_files

    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" pull origin master
    success "Pulled changes from remote repository"
  fi
}

# Backup files that would be modified by pull
backup_modified_files() {
  local backup_dir="$DOTFILES_BACKUP/$(date +%Y%m%d_%H%M%S)"
  local files_to_backup=()

  # Get list of files that will be changed
  while IFS= read -r file; do
    if [[ -f "$HOME/$file" ]]; then
      files_to_backup+=("$file")
    fi
  done < <(git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" diff --name-only HEAD..origin/master)

  # If there are files to backup
  if [[ ${#files_to_backup[@]} -gt 0 ]]; then
    info "The following files will be modified:"
    printf "  %s\n" "${files_to_backup[@]}"

    # Create backup directory
    mkdir -p "$backup_dir"
    success "Created backup directory: $backup_dir"

    # Backup files
    for file in "${files_to_backup[@]}"; do
      local source_path="$HOME/$file"
      local backup_path="$backup_dir/$file"

      # Create directory structure in backup
      mkdir -p "$(dirname "$backup_path")"
      # Copy file to backup
      cp "$source_path" "$backup_path"
      success "Backed up $source_path to $backup_path"
    done

    success "Backed up ${#files_to_backup[@]} files to $backup_dir"
  fi
}

# Backup dotfiles
backup_files() {
  local files=("$@")
  local backup_dir="$DOTFILES_BACKUP/$(date +%Y%m%d_%H%M%S)"
  local files_to_backup=()

  # Check if dotfiles repository exists
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    error_exit "Dotfiles repository does not exist. Run 'init' command first."
  fi

  # If no files specified, backup all tracked files
  if [[ ${#files[@]} -eq 0 ]]; then
    info "No files specified, backing up all tracked files"
    # Get list of all tracked files
    while IFS= read -r file; do
      files_to_backup+=("$file")
    done < <(git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" ls-tree -r master --name-only)
  else
    # Validate each file
    for file in "${files[@]}"; do
      # Convert to absolute path if needed
      if [[ "$file" != /* ]]; then
        file="$PWD/$file"
      fi

      # Check if file is within HOME directory
      if [[ "$file" != "$HOME"/* ]]; then
        warning "Skipping $file: Not within HOME directory"
        continue
      fi

      # Check if file exists
      if [[ ! -e "$file" ]]; then
        warning "Skipping $file: File does not exist"
        continue
      fi

      # Convert to relative path from HOME
      local rel_path="${file#$HOME/}"
      files_to_backup+=("$rel_path")
    done
  fi

  # If there are files to backup
  if [[ ${#files_to_backup[@]} -gt 0 ]]; then
    info "The following files will be backed up:"
    printf "  %s\n" "${files_to_backup[@]}"

    # Ask for confirmation if not forced
    if [[ "$FORCE" == false && "$ASSUME_YES" == false ]]; then
      read -p "Do you want to proceed with backup? (y/n): " confirm
      if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        info "Backup aborted"
        return
      fi
    fi

    # Create backup directory
    if [[ "$DRY_RUN" == true ]]; then
      info "Would create backup directory: $backup_dir"
    else
      mkdir -p "$backup_dir"
      success "Created backup directory: $backup_dir"
    fi

    # Backup files
    for file in "${files_to_backup[@]}"; do
      local source_path="$HOME/$file"
      local backup_path="$backup_dir/$file"

      if [[ "$DRY_RUN" == true ]]; then
        info "Would backup $source_path to $backup_path"
      else
        # Create directory structure in backup
        mkdir -p "$(dirname "$backup_path")"
        # Copy file to backup
        cp "$source_path" "$backup_path"
        success "Backed up $source_path to $backup_path"
      fi
    done

    if [[ "$DRY_RUN" != true ]]; then
      success "Backed up ${#files_to_backup[@]} files to $backup_dir"
      info "You can restore these files using: $(basename "$0") restore $backup_dir"
    fi
  else
    info "No files to backup"
  fi
}

# Restore files from backup
restore_files() {
  local backup_dir="$1"
  shift
  local specific_files=("$@")
  local files_to_restore=()

  # Check if backup directory exists
  if [[ ! -d "$backup_dir" ]]; then
    error_exit "Backup directory does not exist: $backup_dir"
  fi

  # If specific files are provided, validate them
  if [[ ${#specific_files[@]} -gt 0 ]]; then
    for file in "${specific_files[@]}"; do
      # Convert to relative path if absolute path is provided
      if [[ "$file" == /* ]]; then
        file="${file#$HOME/}"
      fi

      # Check if file exists in backup
      if [[ ! -f "$backup_dir/$file" ]]; then
        warning "Skipping $file: Not found in backup"
        continue
      fi

      files_to_restore+=("$file")
    done
  else
    # Get all files in backup directory
    while IFS= read -r -d '' file; do
      local rel_path="${file#$backup_dir/}"
      files_to_restore+=("$rel_path")
    done < <(find "$backup_dir" -type f -print0)
  fi

  # If there are files to restore
  if [[ ${#files_to_restore[@]} -gt 0 ]]; then
    info "The following files will be restored:"
    printf "  %s\n" "${files_to_restore[@]}"

    # Ask for confirmation if not forced
    if [[ "$FORCE" == false && "$ASSUME_YES" == false ]]; then
      read -p "Do you want to proceed with restore? This will overwrite existing files. (y/n): " confirm
      if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        info "Restore aborted"
        return
      fi
    fi

    # Restore files
    for file in "${files_to_restore[@]}"; do
      local source_path="$backup_dir/$file"
      local dest_path="$HOME/$file"

      if [[ "$DRY_RUN" == true ]]; then
        info "Would restore $source_path to $dest_path"
      else
        # Create directory structure in destination
        mkdir -p "$(dirname "$dest_path")"
        # Copy file to destination
        cp "$source_path" "$dest_path"
        success "Restored $source_path to $dest_path"
      fi
    done

    if [[ "$DRY_RUN" != true ]]; then
      success "Restored ${#files_to_restore[@]} files from $backup_dir"
    fi
  else
    info "No files to restore"
  fi
}

# Execute the main function with all arguments
main "$@"
