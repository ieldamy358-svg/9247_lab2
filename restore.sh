#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

dir="$1"
malicious_dir="$2"
whitelist_file="whitelist.txt"

while true; do

    # collect quarantined files
    files=()
    for path in "$malicious_dir"/*; do
        if [ -f "$path" ]; then
            files+=("$(basename "$path")")
        fi
    done

    if [ ${#files[@]} -eq 0 ]; then
        echo "No malicious files to review."
        exit 0
    fi

    # print list
    echo ""
    echo "Files in quarantine:"
    i=1
    for f in "${files[@]}"; do
        echo "  $i) $f"
        i=$((i + 1))
    done
    echo "  0) Exit"

    read -rp "Pick a file by number: " choice

    if [ "$choice" = "0" ]; then
        echo "Goodbye."
        exit 0
    fi

    if (( ${choice:-0} < 1 || ${choice:-0} >= i )); then
        echo "Invalid choice."
        continue
    fi

    selected="${files[$((choice - 1))]}"

    # pick number 
    echo ""
    echo "Selected: $selected"
    echo "  1) Restore to $dir"
    echo "  2) Permanently delete"
    echo "  3) Back"

    read -rp "Choose an option: " action

    if [ "$action" = "1" ]; then
        cp "$malicious_dir/$selected" "$dir/$selected"
        rm "$malicious_dir/$selected"
        echo "$selected" >> "$whitelist_file"
        echo "Restored $selected."

    elif [ "$action" = "2" ]; then
        rm "$malicious_dir/$selected"
        echo "$selected deleted."

    elif [ "$action" = "3" ]; then
        continue

    else
        echo "Invalid option."
    fi

done
