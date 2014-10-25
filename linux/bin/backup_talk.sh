#!/bin/sh
pico2wave -w /tmp/backup_talk.wav "`ssh robin@robin.com.au \"ls -tl --time-style=long-iso --block-size=K ~/backup/lightcube/* |head -n 1\"|awk '{print $5" "$8}'|python /home/robin/linux/bin/read_backup_file.py`";aplay /tmp/backup_talk.wav
