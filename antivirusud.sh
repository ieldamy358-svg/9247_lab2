#!/bin/bash

# exit if less than three arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 dir malicious_dir interval-secs"
    exit 1
fi

dir="$1"
malicious_dir="$2"
interval="$3"

# flagged extensions and keywords
FLAGGED_EXTS=".exe .bat .vbs .scr .ps1"
FLAGGED_KEYWORDS="virus|trojan|malware|worm|ransomware"

# whitelist
whitelist_file="whitelist.txt"

# snapchots for comparing
last_file="directory-info.last"
new_file="directory-info.new"

# in first run there will be no last_file only for first_file because it wasn't  created yet
if [ ! -f "$last_file" ]; then
    for path in "$dir"/*; do
        filename=$(basename "$path")
        ext=".${filename##*.}"
        malicious=0

        # check the whitelist  
        if [ -f "$whitelist_file" ] && grep -qxF "$filename" "$whitelist_file"; then
            continue
        fi

        # flagged extensions
        for e in $FLAGGED_EXTS; do
            if [ "$ext" = "$e" ]; then
                malicious=1
                break
            fi
        done

        # falgged keywords 
        if grep -qiE "$FLAGGED_KEYWORDS" "$path" 2>/dev/null; then
            malicious=1
        fi

        # if malicous cut and copy to malicous directory
        if [ "$malicious" -eq 1 ]; then
            echo "$filename is malicious and it is DELETED"
            cp "$path" "$malicious_dir/$filename"
            rm "$path"
        fi
    done

    # take the snapchot
    ls -l "$dir" > "$last_file"
fi

# every time interval we will check the snapchots
while true; do
    sleep "$interval"

    # take the snapshot
    ls -l "$dir" > "$new_file"

    # enter only if something changed in new file
    if ! cmp -s "$last_file" "$new_file"; then
        for path in "$dir"/*; do
            filename=$(basename "$path")
            ext=".${filename##*.}"
            malicious=0

            # check the whitelist
            if [ -f "$whitelist_file" ] && grep -qxF "$filename" "$whitelist_file"; then
                continue
            fi

            # flagged extensions
            for e in $FLAGGED_EXTS; do
                if [ "$ext" = "$e" ]; then
                    malicious=1
                    break
                fi
            done

            # flagged keywords
            if grep -qiE "$FLAGGED_KEYWORDS" "$path" 2>/dev/null; then
                malicious=1
            fi

            # if malicious cut and copy to malicious directory
            if [ "$malicious" -eq 1 ]; then
                echo "$filename is malicious and it is DELETED"
                cp "$path" "$malicious_dir/$filename"
                rm "$path"
            fi
        done

        # update the snapshot
        cp "$new_file" "$last_file"
    fi
done
