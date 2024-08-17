#!/bin/env bash
# Sends the entire directory to a remote machine
# There it will dispatch the build.sh script
# Optionally, with the -r flag, it will run the built program on the remote machine,
# capture active I/O, and send the log file back.
# It also sends the ./build folder back, and cleans up files on the remote machine.

# Usage: remotebuild.sh [-r] [-v] <remote machine> <dest> <build.sh> <directory-to-send> [<run-command>]

# Text styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Directory for logs
LOG_DIR="/tmp/remotebuild"
mkdir -p "$LOG_DIR"

# Check if required commands are available
for cmd in rsync ssh scp; do
    command -v $cmd >/dev/null 2>&1 || { echo -e "${RED}Error:${RESET} $cmd is not installed."; exit 1; }
done

# Check for the -r flag and -v flag for verbose mode
RUN_FLAG=false
VERBOSE=false
if [ "$1" == "-r" ]; then
    RUN_FLAG=true
    shift
fi
if [ "$1" == "-v" ]; then
    VERBOSE=true
    shift
fi

# Check if the correct number of arguments are passed
if [ "$#" -lt 4 ]; then
    echo -e "${RED}${BOLD}Error:${RESET} Usage: remotebuild.sh [-r] [-v] <remote machine> <dest> <build.sh> <directory-to-send> [<run-command>]"
    exit 1
fi

# Assigning arguments to variables
REMOTE_MACHINE=$1
DEST=$2
BUILD_SCRIPT=$3
DIRECTORY_TO_SEND=$4
RUN_COMMAND=$5

# Function to display status messages
function status_message() {
    echo -e "${BLUE}${BOLD}[*]${RESET} $1"
}

# Function to display success messages
function success_message() {
    echo -e "${GREEN}${BOLD}[✔]${RESET} $1"
}

# Function to display warning messages
function warning_message() {
    echo -e "${YELLOW}${BOLD}[!]${RESET} $1"
}

# Check if SSH key is set up
ssh-add -l >/dev/null 2>&1 || { echo -e "${YELLOW}Warning:${RESET} SSH key not added to ssh-agent."; }

# Ensure no spaces or special characters in destination paths
if [[ "$DEST" =~ [\*\?\[\]\{\}\|\;\&\$\`\<\>\|\'] ]]; then
    echo -e "${RED}Error:${RESET} Invalid characters in destination path."
    exit 1
fi

# Optionally log all output to a specific log file
LOGFILE="$LOG_DIR/remotebuild_$(date +'%Y%m%d_%H%M%S').log"
exec > >(tee -a "$LOGFILE") 2>&1

# Confirm with the user
read -p "Are you sure you want to proceed with sending files to $REMOTE_MACHINE? (y/n) " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Aborting."
    exit 1
fi

# Sending the directory to the remote machine while ignoring hidden files and directories
status_message "Sending directory ${CYAN}$DIRECTORY_TO_SEND${RESET} to ${CYAN}$REMOTE_MACHINE:$DEST${RESET}, ignoring hidden files"
rsync -av --exclude='.*' "$DIRECTORY_TO_SEND/" "$REMOTE_MACHINE":"$DEST/" || { echo -e "${RED}Failed to send directory.${RESET}"; exit 1; }

# Executing the build script on the remote machine
status_message "Executing build script on ${CYAN}$REMOTE_MACHINE${RESET}"
ssh "$REMOTE_MACHINE" "cd $DEST && bash $BUILD_SCRIPT" || { echo -e "${RED}Failed to execute build script.${RESET}"; exit 1; }

# If the -r flag is set, run the command and capture I/O
if [ "$RUN_FLAG" == true ]; then
    LOG_FILE=".log.$(date +'%Y%m%d_%H%M%S').rb"
    status_message "Running command on ${CYAN}$REMOTE_MACHINE${RESET} and capturing I/O"
    ssh "$REMOTE_MACHINE" "cd $DEST && $RUN_COMMAND" | tee "$LOG_FILE"
    success_message "Sending the log file ${CYAN}$LOG_FILE${RESET} back to the local machine"
    scp "$REMOTE_MACHINE":"$DEST/$LOG_FILE" .
fi

# Sending the build folder back to the local machine
status_message "Sending the ${CYAN}build${RESET} folder back to the local machine"
scp -r "$REMOTE_MACHINE":"$DEST/build" .

# Cleaning up the remote machine
status_message "Cleaning up files on the remote machine"
ssh "$REMOTE_MACHINE" "rm -rf $DEST" || { echo -e "${RED}Failed to clean up remote files.${RESET}"; exit 1; }

success_message "Build process complete, and remote files cleaned up."

