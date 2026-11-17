#!/bin/bash
# File Auditor & Backup Tool - Operating Systems Project

# ---------- Settings ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"
LOG_FILE="$SCRIPT_DIR/auditor.log"
BACKUP_DIR="$TARGET_DIR/backups"

source "$SCRIPT_DIR/lib.sh"

# Lists every file and folder of the directory and counts them.
scan_directory() {
    local f
    local files=0
    local folders=0

    for f in "$TARGET_DIR"/*; do
        if [ -d "$f" ]; then
            echo "[dir ] $(basename "$f")"
            folders=$((folders + 1))
        elif [ -f "$f" ]; then
            echo "[file] $(basename "$f")"
            files=$((files + 1))
        fi
    done

    echo "Files: $files Folders: $folders"
    log_action "Scan directory"
}

# Shows r/w/x flags of every file for the current user and counts
# the unreadable and the executable files.
permission_audit() {
    local f
    local flags
    local unreadable=0
    local executable=0

    for f in "$TARGET_DIR"/*; do
        if [ -f "$f" ]; then
            flags=""

            if [ -r "$f" ]; then
                flags="${flags}r"
            else
                flags="${flags}-"
                unreadable=$((unreadable + 1))
            fi

            if [ -w "$f" ]; then
                flags="${flags}w"
            else
                flags="${flags}-"
            fi

            if [ -x "$f" ]; then
                flags="${flags}x"
                executable=$((executable + 1))
            else
                flags="${flags}-"
            fi

            echo "$flags $(basename "$f")"
        fi
    done

    echo "Unreadable files: $unreadable Executable files: $executable"
    log_action "Permission audit"
}

# Counts the files per extension (txt, log, sh, jpg, other)
# using an associative array.
extension_report() {
    local f
    local name
    local ext
    declare -A count

    for f in "$TARGET_DIR"/*; do
        if [ -f "$f" ]; then
            name=$(basename "$f")

            if [[ "$name" == *.* ]]; then
                ext="${name##*.}"
            else
                ext="other"
            fi

            case "$ext" in
                txt|log|sh|jpg) ;;
                *) ext="other" ;;
            esac

            count[$ext]=$(( ${count[$ext]:-0} + 1 ))
        fi
    done

    for ext in txt log sh jpg other; do
        echo "$ext : ${count[$ext]:-0}"
    done

    log_action "Extension report"
}

# Asks for a text and prints every file whose name contains it.
search_file() {
    local f
    local name
    local text
    local found=0

    read -r -p "Enter text to search: " text

    for f in "$TARGET_DIR"/*; do
        if [ -f "$f" ]; then
            name=$(basename "$f")
            if [[ "$name" == *"$text"* ]]; then
                echo "$name"
                found=1
            fi
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo "No matching files found."
    fi

    log_action "Search file"
}

# Copies every readable file to the backups folder as
# name_YYYYMMDD_HHMMSS.bak. Unreadable files are skipped.
backup_all() {
    local f
    local name
    local dest
    local saved=0
    local skipped=0

    mkdir -p "$BACKUP_DIR"

    for f in "$TARGET_DIR"/*; do
        if [ -f "$f" ]; then
            name=$(basename "$f")
            dest="$BACKUP_DIR/${name}_$(date '+%Y%m%d_%H%M%S').bak"

            if [ ! -r "$f" ]; then
                echo "Error: cannot read $name"
                skipped=$((skipped + 1))
            elif [ -e "$dest" ]; then
                echo "Error: backup already exists for $name"
                skipped=$((skipped + 1))
            else
                cp "$f" "$dest"
                saved=$((saved + 1))
            fi
        fi
    done

    echo "Files saved: $saved Files skipped: $skipped"
    log_action "Backup all"
}

# Prints the names of all saved backups.
list_backups() {
    local f
    local found=0

    for f in "$BACKUP_DIR"/*.bak; do
        if [ -f "$f" ]; then
            echo "$(basename "$f")"
            found=1
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo "(no backups yet)"
    fi

    log_action "List backups"
}

# Copies a chosen backup back to the directory as restored_NAME.
# It never overwrites an existing file.
restore_backup() {
    local name
    local dest

    read -r -p "Enter backup name: " name

    # the name must be a plain file name that exists in backups
    if [[ "$name" == */* ]] || [ ! -f "$BACKUP_DIR/$name" ]; then
        echo "Error: backup does not exist!"
        log_action "Restore failed"
        return 1
    fi

    dest="$TARGET_DIR/restored_$name"

    if [ -e "$dest" ]; then
        echo "Error: restored_$name already exists!"
        log_action "Restore failed"
        return 1
    fi

    cp "$BACKUP_DIR/$name" "$dest"
    echo "Backup restored as restored_$name"
    log_action "Restore backup"
}

# ---------- Main program ----------
require_dir || exit 1

# Command-line mode: ./auditor.sh DIRECTORY ACTION
if [ -n "$2" ]; then
    case "$2" in
        scan)   scan_directory ;;
        perms)  permission_audit ;;
        ext)    extension_report ;;
        backup) backup_all ;;
        *)      log_error "Invalid action!"; exit 1 ;;
    esac
    exit 0
fi

# Menu mode: repeats until the user chooses Exit
while true; do
    echo ""
    echo "=============================="
    echo "       FILE AUDITOR"
    echo "=============================="
    echo "1. Scan Directory"
    echo "2. Permission Audit"
    echo "3. Extension Report"
    echo "4. Search File"
    echo "5. Backup All"
    echo "6. List Backups"
    echo "7. Restore Backup"
    echo "8. Exit"
    echo "=============================="

    read -r -p "Enter your choice: " choice

    case "$choice" in
        1) scan_directory ;;
        2) permission_audit ;;
        3) extension_report ;;
        4) search_file ;;
        5) backup_all ;;
        6) list_backups ;;
        7) restore_backup ;;
        8) echo "Goodbye!"; break ;;
        *) echo "Wrong choice! Try again." ;;
    esac
done
