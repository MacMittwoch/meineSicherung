#!/bin/sh
#
# meineSicherung
#
# Autor: Farid Mésbahi
# Version: 1.0
# Date: 01.06.2020
# Description: Script to backup and restore your files with restic backup 
# (https://github.com/restic/restic).
#
# This script is free software as it is without any license behind.
# The downloading, installation and use of the programs, scripts, documents and images in this
# context is at your own risk.

###################################################################################################
# Standard user options.
###################################################################################################

# Backup target location (path).
REPOSITORY="$HOME/meinesicherung"

# Count of archives.
BACKUP_ARCHIVES=3

# Restore path.
RESTORE_PATH="$HOME/restore"

# Backup password (must have and don't forget it).
export RESTIC_PASSWORD="mypassword"

###################################################################################################
# Here is the end for standard options. If you don't know what will come, please don't touch it.
###################################################################################################

###################################################################################################
# Function: Logfile and entry creation.
###################################################################################################

log_file()
{
    # Time stamp format
    local TIME_STAMP=$(date +%Y)$(date +%m)$(date +%d)-$(date +%H):$(date +%M)

    #Initial logfile check.
    if [ ! -e $LOG_PATH/meinesicherung.log ]; then
        echo "meineSicherung Log-File" >> $LOG_PATH/meinesicherung.log
        echo "--------------------------------------------------------------------------------------------------------------------" >> $LOG_PATH/meinesicherung.log
    fi

    #Logfile entry.
    echo "[$TIME_STAMP] Error-Code $1: $2" >> $LOG_PATH/meinesicherung.log
}

###################################################################################################
# Function: Standard backup and prune with restic.
###################################################################################################

backupStandard()
{
    # Inital repository creation
    if [ ! -e $REPOSITORY/config ]; then
        restic -r $REPOSITORY init
    fi
       
    # restic backup start. Please maintain the path to restic.
    restic -r $REPOSITORY backup --files-from $HOME/.config/restic/include_files.txt --exclude-file=$HOME/.config/restic/exclude_files.txt --verbose --cleanup-cache
       
    # Create log entry.
    if [ $? -eq 0 ]; then
        log_file $? 'Backup was successful.'
    else
        log_file $? 'Backup was NOT successful.'
    fi
    
    # Prune backups. Please maintain the path to restic.
    restic -r $REPOSITORY forget --keep-last $BACKUP_ARCHIVES --prune --verbose
    
    # Create log entry.
    if [ $? -eq 0 ]; then
        log_file $? 'Pruning was successful.'
    else
        log_file $? 'Pruning was NOT successful'
    fi
}

###################################################################################################
# Function: Restore backup
###################################################################################################

backupRestore()
{
    /opt/local/bin/restic -r $REPOSITORY restore latest --target $RESTORE_PATH
    
    # Create log entry.
    if [ $? -eq 0 ]; then
        log_file $? 'Restoring was successful.'
    else
        log_file $? 'Restoring was NOT successful'
    fi
}

###################################################################################################
# Function: Repository information 
###################################################################################################

repositoryInformation()
{
    /opt/local/bin/restic -r $REPOSITORY snapshots
}

###################################################################################################
# Function: Repository check 
###################################################################################################

repositoryCheck()
{
    /opt/local/bin/restic -r $REPOSITORY check --read-data
}

###################################################################################################
# Main
###################################################################################################

#Skriptname and version.
SCRIPT_NAME="meineSicherung V1.0"

#Menu; 1=Yes, 0=No.
MENU_SWITCH=1

#Logfile path.
LOG_PATH="/var/log"

#Backup status
BACKUP_STATUS="OK"

#File size
FILE_SIZE=0

#Arguments and options identification.
while getopts sh opt 2>/dev/null
do
    case $opt in
        s) #Silent mode, no menus and dialogues.
            MENU_SWITCH=0
            ;;
        h) #Ausgabe der Hilfe.
            echo
            echo $SCRIPT_NAME
            echo
            echo "Options are: ./meineSicherung [-sh]"
            echo
            echo "s = Silent mode, no menus dialogues."
            echo "h = Help."
            echo
            echo "Example:"
            echo "The enter: $0 -s"
            echo "will start all backup jobs direct without menus."
            echo
            echo "No arguments will start the user mode with menus."
            echo
            exit 0
            ;;
        ?) #Ausgabe von Fehlermeldungen bei falschen Optionen.
            echo
            echo $SCRIPT_NAME
            echo
            echo "($0): Error!"
            echo
            echo "You will get a help with: $0 -h"
            echo
            exit 0
            ;;
   esac
done

# Inital creation of include/exclude files.
if [ ! -e $HOME/.config/restic ]; then
    mkdir -p $HOME/.config/restic/
    touch $HOME/.config/restic/include_files.txt
    touch $HOME/.config/restic/exclude_files.txt
fi

# Initial set of the log file path.
if [ $USER = "root" ]; then
    LOG_PATH="/var/log"
else
    LOG_PATH=$HOME/.config/restic
fi

# Initial set of the backup status.
FILE_SIZE=$(wc -c $HOME/.config/restic/include_files.txt | awk '{print $1}')

if [ $FILE_SIZE != 0 ]; then
    BACKUP_STATUS="OK"
else
    BACKUP_STATUS="Not OK. Please maintain your include-file for restic with all folders to backup!"
fi

#Main menu.
if [ $MENU_SWITCH -eq 1 ]; then
    while [ "$MENU_CHOICE" != "e" ]
    do
    #Startmenue
    clear
    echo $SCRIPT_NAME
    echo "-------------------"
    echo
    echo "Backup Repository: "$REPOSITORY
    echo
    echo "Backup-Status: "$BACKUP_STATUS
    echo
    read -p "Command: [S]=Start [R]=Restore [I]=Info [C]=Check [E]=Exit: " MENU_CHOICE

    case $MENU_CHOICE in
        s) #Backup start
            clear
            echo $SCRIPT_NAME
            echo "-------------------"
            echo
            echo "Standard Backup"
            echo
            
            backupStandard
            ;;
        r) #Backup Restore
            clear
            echo $SCRIPT_NAME
            echo "-------------------"
            echo
            echo "Backup Restore"
            echo
            
            backupRestore
            ;;
        i) #Repository Information
        clear
            echo $SCRIPT_NAME
            echo "-------------------"
            echo
            echo "Repository Information (Snapshots)"
            echo
            
            repositoryInformation
            ;;
        c) #Repository Check
        clear
            echo $SCRIPT_NAME
            echo "-------------------"
            echo
            echo "Repository Check"
            echo
            
            repositoryCheck
            ;;    
       ?) #Different selection
            ;;
    esac
    
    echo
    read -p "Hit Enter to continue."
    
    done
else
    backupStandard
fi

echo
echo "FIN"
echo
