#!/bin/bash

# Program: matikan.sh
# Version: 1.0.1
# Operating System: Ubuntu 16.04
# Description: Shutdown/Reboot system with LUKS Swap Encryption
# Author: Eko Junaidi Salam

# GNU GENERAL PUBLIC LICENSE
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# program / version
program="matikan"
version="1.0.1"

# define colors
export red=$'\e[0;91m'
export green=$'\e[0;92m'
export blue=$'\e[0;94m'
export yellow=$'\e[0;93m'
export white=$'\e[0;97m'
export endc=$'\e[0m'

# print banner
function banner {
printf "${white}
*****************************************
*           _______________             *
*          | ____|___ |  __|            *
*          | |___   | | |__             *
*          |  ___|  | |__  |  	        *
*          | |______|  __| |  	        *
*          |__________|____|            *
*                                       *
*****************************************

Custom Shutdown/Reboot for LUKS Swap.
Version: $version
Author: Eko Junaidi Salam${endc}\n"
}


# check if the program run as a root
function check_root {
    if [ "$(id -u)" -ne 0 ]; then
        printf "${red}%s${endc}\n"  "[ failed ] Please run this program as a root!" >&2
        exit 1
    fi
}

# Turn on LUKS Swap manually
function swap_on {
    banner
    check_root
    
    # open LUKS
    printf "\n${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Open LUKS Swap..."
    cryptdisks_start sda6_crypt
    sleep 3

    # turn on swap
    printf "${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Turn on the swap..."
	swapon -a
    sleep 3
    
    # check swap
    printf "${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Checking the swap..."
    sleep 3
    free -h
}

# Turn off LUKS Swap manually
function swap_off {
    banner
    check_root

    # turn off swap
    printf "\n${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Turn off the swap..."
	swapoff -a
    sleep 3
    
    # close LUKS
    printf "${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Close LUKS Swap..."
    cryptsetup luksClose sda6_crypt
    sleep 3
    
    # check swap
    printf "${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Checking the swap..."
    sleep 3
    free -h
}

# shutdown the system
function power_off {
    banner
    check_root

    # turn off swap
    printf "\n${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Turn off the swap..."
	swapoff -a
    sleep 3
    
    # close LUKS
    printf "${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Close LUKS Swap..."
    cryptsetup luksClose sda6_crypt
    sleep 3
    
    # shutdown
    printf "${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Shutdown the system..."
    sleep 3
    poweroff
}

# reboot the system
function power_on {
    banner
    check_root

    # turn off swap
    printf "\n${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Turn off the swap"
	swapoff -a
    sleep 3
    
    # close LUKS
    printf "${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Close LUKS Swap"
    cryptsetup luksClose sda6_crypt
    sleep 3
    
    # reboot
    printf "${blue}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Reboot the system"
    sleep 3
    reboot
}

# rebuild the swap
function rebuild {
    banner
    check_root
    
    # check swap
    free -h
    printf "${blue}::${endc} ${green}Are you sure to rebuild the LUKS Swap? [YES]${endc}"
	read -p "${green}:${endc} " yn
    case $yn in
        YES)
            printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Rebuilding in progress..."
            ;;
        *)
			exit 1
            ;;
    esac
    
    printf "${blue}::${endc} ${green}Where is your partition location ex:/dev/sda6? [/dev/sda6]${endc}"
	read -p "${green}:${endc} " ptt
	
    printf "${blue}::${endc} ${green}Mapping name, ex:sda6_crypt? [sda6_crypt]${endc}"
	read -p "${green}:${endc} " map_name
	
	if [ "$ptt" = "" ]; then
		ptt="/dev/sda6"
	fi
	
	if [ "$map_name" = "" ]; then
		map_name="sda6_crypt"
	fi
	
	# check there's partition or not
	ls $ptt | grep dev > /dev/null
	
	if [ "$?" -ne 0 ]; then
        printf "${red}%s${endc}\n"  "[ failed ] There's no partitions, exited..." >&2
        exit 1
    fi
	
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "You choose partition : $ptt"
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Encrypting the partition using LUKS Encryption"
	cryptsetup --verbose --verify-passphrase luksFormat "$ptt"
	
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Opening the partition"
	cryptsetup luksOpen "$ptt" "$map_name"
	
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Creating Swap in /dev/mapper/$map_name"
	mkswap -L swap /dev/mapper/"$map_name"
	
	uuid=$(blkid -s UUID -o value "$ptt")
	if [ "$uuid" = "" ]; then
        printf "${red}%s${endc}\n"  "[ failed ] There's no UUID, exited..." >&2
        exit 1
    fi
	
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "UUID $ptt $map_name: $uuid"
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Backup crypttab file to /etc/crypttab.old"
	cp /etc/crypttab /etc/crypttab.old
	
	cek_swap=$(grep "$map_name" /etc/crypttab | wc -l)
	if [ "$cek_swap" -gt 1 ]; then
        printf "${yellow}%s${endc}" "[ warning ]" "${green} There's more than one entries in /etc/crypttab, Are you sure you want to replace this? [YES]${endc}"
		read -p "${green}:${endc} " yn
		case $yn in
			YES)
				printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Replacing..."
				;;
			*)
				exit 1
				;;
		esac
    fi
    
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Writing Swap UUID to /etc/crypttab"
	write_crypttab="$map_name UUID=$uuid none luks,swap,offset=8,discard"
	
    #sed -i "/$map_name/c $write_crypttab" /home/ekojs/Documents/my_program/matikan/tes.txt
    sed -i "/$map_name/c $write_crypttab" /etc/crypttab
	
	
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Backup fstab file to /etc/fstab.old"
	cp /etc/fstab /etc/fstab.old
	
	cek_fstab=$(grep "swap" /etc/fstab | wc -l)
	if [ "$cek_fstab" -ge 1 ]; then
        printf "${yellow}%s${endc}" "[ warning ]" "${green} There's swap entries in /etc/fstab, Are you sure you want to replace this? [YES]${endc}"
		read -p "${green}:${endc} " yn
		case $yn in
			YES)
				printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Replacing..."
				;;
			*)
				exit 1
				;;
		esac
    fi
	
	write_fstab="/dev/mapper/$map_name none            swap    sw              0       0"
	
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Writing Swap into /etc/fstab"
	#sed -i "/swap/c $write_fstab" /home/ekojs/Documents/my_program/matikan/tes.txt
	sed -i "/swap/c $write_fstab" /etc/fstab
    
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "$write_fstab"
	printf "${blue}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Updating Your initramfs..."
	update-initramfs -u -k all
}

# display program and version then exit
function print_version {
    printf "\n${white}%s${endc}\n" "$program version $version"
    exit 0
}


# print help message and exit
function help_menu {
	banner

    printf "\n${white}%s${endc}\n" "Usage:"
    printf "${white}%s${endc}\n\n"   "******"
    printf "${white}%s${endc} ${red}%s${endc} ${white}%s${endc} ${red}%s${endc}\n" "┌─╼" "$USER" "╺─╸" "$(hostname)"
    printf "${white}%s${endc} ${green}%s${endc}\n" "└───╼" "./$program --argument"

    printf "\n${white}%s${endc}\n\n" "Arguments:"
    printf "${green}%s${endc}\n" "--help      show this help message and exit"
    printf "${green}%s${endc}\n" "--swapon    turn on luks swap manually"
    printf "${green}%s${endc}\n" "--swapoff   turn off luks swap manually"
    printf "${green}%s${endc}\n" "--shutdown  turn off swap and luks then shutdown"
    printf "${green}%s${endc}\n" "--reboot    turn off swap and luks then reboot"
    printf "${green}%s${endc}\n" "--rebuild   rebuild the swap"
    printf "${green}%s${endc}\n" "--version   display program and version then exit"
    exit 0
}


# cases user input
case "$1" in
    --swapon)
        swap_on
        ;;
    --swapoff)
        swap_off
        ;;
    --shutdown)
        power_off
        ;;
    --reboot)
        power_on
        ;;
    --rebuild)
        rebuild
        ;;
    --version)
        print_version
        ;;
    --help)
        help_menu
        ;;
    *)
help_menu
exit 1

esac
