# meineSicherung V1.0

## Description

meineSicherung is a very simple script for Unix (macOS, Linux or BSD) based shells to use restic ([Link](https://github.com/restic/restic)) as backup program. meineSicherung is a german name, the meaning is more or less myBackup.

It supports a menu with the most used easy functions of restic and a silent mode for automatic backups in the background without any menues.

You can configure and test your backup and restores with the menu at first before you start a regular backup driven by a cronjob for example in the silent mode.

All outputs of restic will be shown, to identify problems or mistakes also to follow the progress of your backup.

## Installation and Configuration

1. Copy the single file meinesicherung.sh in your user or root directroy, depends on how do you want to use meineSicherung, as personal or system backup solution. 

2. Open the file meinesicherung.sh with an text editor and maintain the following parameters:

    a) **REPOSITORY**: restic organize all backups in a single repository. A directory will be used, where restic will place all files. Please enter here the path to the repository. It is recomend to use the path to an external drive, which is mounted and reachable of the system.

    b) **BACKUP_ARCHIVES**: Here is the number of archives to maintain. restic speaks about snapshots. Every new backup run will create a new unique snapshot. Predifined are three snapshots to hold, the fourth run will delete the oldest one. In total you will have three backups in rotation. Please keep in mind, that restic will consider an incremental approach, but if you increase the value you should have the target capacity of your backup drive in focus.

    c) **RESTORE_PATH**: If you want to restore your backup, this is the place where restic will kopy all files back. restic will consider the original path structure and the complete backup. With other words, all files will be restored, if you want only one file. meineSicherung will consider the last actual snapshot.

    d) **RESTIC_PASSWORD**: This is very important, because this is a must have for restic to encrypt the complete repository with all snapshots inside. Please change the predefined standard password "mypassword" with an safty one by your self and keep it at a good place. 

3. Next step is to install restic. Please use here your package manager of your system. For macOS i can recomend to use MacPorts ([Link](https://www.macports.org))  

4. Change the file attributes of meinesicherung.sh, that the script is executable and only in use by you. Here is an example to change the access, the owner and group:

    ~~~~
    $ chmod 0700 meinesicherung.sh
    ~~~~

    ~~~~
    $ chown (YOUR USERNAME) meinesicherung.sh
    ~~~~

    ~~~~
    $ chgrp (YOUR USERNAME) meinesicherung.sh
    ~~~~

5. With the first start of meineSicherung the script will create a directory and two files in your home directory. You will find all files in:

~~~~
$ .config/restic
~~~~

The first file is called *include_files.txt*. Here you must enter all directories as list to backup. The second file *exclude_file.txt* is to exclude directories or single files as list from your backup. A directory list could be:

~~~~
/home/MY_USERNAME/data
/home/MY_USERNAME/projects
~~~~

Both files must be maintained, but if you have nothing to exclude, let the file *exclude_file.txt* empty and don't delete it.

With other words, if you start meineSicherung for the first time, the necessary files will be created automaticaly. You must exit the script to maintain the files and to restart and test your backup again.

## Common Information (License)

The change of the script, according to their needs is of course recommended. This script is free software as it is without any license.

The downloading, installation and use of the program, script and documents in this context is at your own risk.
