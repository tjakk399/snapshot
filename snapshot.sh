#!/bin/bash

set -e

SRC=""
DESTINATION=""

EXCLUDE_FROM=""
INCLUDE_FROM=""

BACKUP_ID="backup-$(hostname)-$(date '+%Y-%m-%dT%H-%M-%S')"

# Rsync options
COMPRESS=""
PROGRESS=""

usage () {
    cat <<'USAGE'
Options:

- `-h`: Show usage.
- `-s`: Source directory to be snapshot.
- `-d`: Destination directory, either just as directory or as `<user>@<host>:<directory>`.
- `-e`: Path to rsync's exclude-from file. (Default: none)
- `-i`: Path to rsync's include-from file. (Default: none)
- `-c`: rsync's compress flag. (Default: false)
- `-p`: rsync's progress flag. (Default: false)
- `-n`: Backup directory name. (Default: `backup-<hostname>-<timestamp>`)

Examples:

```
./snapshot -s ~/Fotos -d pi@192.168.50.10:/media/500GB/backups/Fotos -cp

./snapshot -s ~/Fotos -d /Volumes/2TB/backups/Fotos -p

./snapshot -s ~ -d pi@192.168.50.10:/media/500GB/backups/home ~/.rsync/exclude -i ~/.rsync/include -cp

./snapshot -s ~ -d /Volumes/2TB/backups/home -e ~/.rsync/exclude -i ~/.rsync/include -p
```
USAGE
    exit 1
}

while getopts "s:d:e:i:n:cph" option; do
    case "${option}" in
        h  ) usage; exit;;
        s  ) SRC=${OPTARG};;
        d  ) DESTINATION=${OPTARG};;
        e  ) EXCLUDE_FROM=${OPTARG};;
        i  ) INCLUDE_FROM=${OPTARG};;
        n  ) BACKUP_ID=${OPTARG};;
        c  ) COMPRESS=true;;
        p  ) PROGRESS=true;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

if [[ $# -eq 0 || -z "$SRC" || -z "$DESTINATION" ]]; then
    usage
    exit
fi

current_symlink () {
    echo "$1/current"
    return
}

cmd_update_current_symlink () {
    echo \
        "ln \
            --force \
            --no-target-directory \
            --relative \
            --symbolic \
            --verbose \
            "$2" \
            $(current_symlink $1)"
    return
}

cmd_mkdir () {
    echo \
        "mkdir \
            --parents \
            $1"
    return
}

make_target_dir () {
    if [[ ! -z "$2" ]]; then
        ssh \
            "$2" \
            "$(cmd_mkdir $1)"
        return
    else
        eval "$(cmd_mkdir $1)"
        return
    fi
}

update_current_symlink () {
    if [[ ! -z "$3" ]]; then
        ssh \
            "$3" \
            "$(cmd_update_current_symlink $1 $2)"
        return
    else
        eval "$(cmd_update_current_symlink $1 $2)"
        return
    fi
}

host_from_destination () {
    local host="${1%%:*}"
    if [ "$host" = "$1" ]; then
        echo ""
        return
    else
        echo "$host"
        return
    fi
}

run () {
    local host="$(host_from_destination "$DESTINATION")"
    local target_dir="${DESTINATION##*:}"

    make_target_dir "$target_dir" "$host"

    time rsync \
        --archive \
        --link-dest="$(current_symlink $target_dir)" \
        $([ ! -z "$host"         ] && echo -n "-e ssh"                      ) \
        $([ ! -z "$COMPRESS"     ] && echo -n "--compress"                  ) \
        $([ ! -z "$PROGRESS"     ] && echo -n "--progress"                  ) \
        $([ ! -z "$EXCLUDE_FROM" ] && echo -n "--exclude-from=$EXCLUDE_FROM") \
        $([ ! -z "$INCLUDE_FROM" ] && echo -n "--include-from=$INCLUDE_FROM") \
        "$SRC/" \
        "$DESTINATION/$BACKUP_ID"

    update_current_symlink "$target_dir" "$BACKUP_ID" "$host"

    return
}

run
