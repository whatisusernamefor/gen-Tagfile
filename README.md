# genTagfiles.sh - Record of your fresh Slackware install

A script to run post install of a fresh slackware installation. Will create tagfiles and structure for documentation and future auto-installs.

## Why this matters

This is a self-documenting proceedure run after a fresh install of slackware. This may be used to self-document a manual, 'expert', installation that can later be passed to Slackware's setup program to recreate your current install.

## Usage

Must install locally.
First mount the install media to /media
``` mount <device> /media ```

The script will do the rest
``` ./genTagfiles.sh ```

## Program Flow

  - checks for slackware media
  - checks for 64-bit install
  - Uses two files /media/slackware[64]/FILE_LIST and PACKAGES.TXT
    parse these to extract all slackware packages available.
  - check is installed and create the tagfiles based on installed packages.
    - If installed, adds the line "PKGNAM:ADD"
    - else adds the line "PKGNAM:SKP"
  - After completion runs a sanity check to verify script ran as intended
    and prints out results.



