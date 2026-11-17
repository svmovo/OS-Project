#!/bin/bash
# Helper functions. This file is loaded by auditor.sh using source.

# Prints a normal message.
log_info() {
    echo "[INFO] $1"
}

# Prints an error message.
log_error() {
    echo "[ERROR] $1" >&2
}

# Adds one line (date, time, action) to auditor.log.
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Stops with an error if the chosen directory does not exist.
require_dir() {
    if [ ! -d "$TARGET_DIR" ]; then
        log_error "Directory does not exist!"
        return 1
    fi
}
