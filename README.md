# snapshot

Create a disk-efficient series of data snapshots as backups by using rsync's hardlinking feature to avoid redundant files.
Each invocation of this script creates a new snapshot based on the latest one, and updates a symlink to the new snapshot.

This tools mimics Apple's Time Machine feature, but is more stable and creates output that can easily be traversed (and deleted) with any file manager.
No special tools needed.

Tested on: Macos 10.14.6, Linux

## Requirements

- bash
- rsync


## Installation

Git clone.


## Usage

```
./snapshot <OPTIONS>
```

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
