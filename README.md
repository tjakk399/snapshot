# snapshot

Lightweight backup-utility for the command line -- using `rsync`'s hardlinking feature.

This tool allows you to maintain a series of snapshots of your data, also known as a "backup".
Identical files are hardlinked in order to avoid redundant disk usage, just like in any other backup utility.

Think of Apple's *Time Machine* feature, but more reliable, more stable and with output that can be easily managed with any file manager.
No special tools needed.

Each invocation of the script creates a new backup directory at the destination with the current snapshot.
If there is a symlink named `current` at the destination then `current`'s target path will be checked for unchanged files.
All unchanged files will be hardlinked in the new snapshot to maximize disk efficiency.

Use this tool with a cronjob in order to create regular backups automatically.


## Requirements

- `bash`
- `rsync

Tested on:

- Macos 10.14.6,
- Ubuntu 20.04
- Arch Linux


## Installation

Download the script or clone the repository.


## Usage

```
./snapshot <OPTIONS>
```

Options:

- `-h`: Show usage
- `-s`: Source directory for the snapshot
- `-d`: Path to destination directory, either just as local path or as authority + path (i.e. `<user>@<host>:<path>`)
- `-e`: Path to rsync's exclude-from file (default: none)
- `-i`: Path to rsync's include-from file (default: none)
- `-c`: rsync's compress flag (default: false)
- `-p`: rsync's progress flag (default: false)
- `-n`: Backup directory name (default: `backup-<hostname>-<timestamp>`)

Example usages:

```
./snapshot.sh -s ~ -d /Volumes/2TB/backups
```

```
./snapshot.sh -s ~/Fotos -d /Volumes/2TB/backups/Fotos -p
```

```
./snapshot.sh -s ~/Fotos -d pi@192.168.50.10:/media/500GB/backups/Fotos -cp
```

```
./snapshot.sh -s ~ -d pi@192.168.50.10:/media/500GB/backups/home ~/.rsync/exclude -i ~/.rsync/include -cp
```

```
./snapshot.sh -s ~ -d /Volumes/2TB/backups/home -e ~/.rsync/exclude -i ~/.rsync/include -p
```

