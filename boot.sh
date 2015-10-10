#!/bin/bash

# Define colors
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get list of drives with the name contains /dev/sdd AND/OR  /dev/sdb
usb_arr=($(df | grep "/dev/sd[db]"))

# Number of valide lines
usb_arr_size=0

# A list for the user to choose from
for (( i=0; i<${#usb_arr[*]}; i+=6 ))
do
	printf "%4d %s %s\n" $((i/6)) ${usb_arr[$i]} ${usb_arr[$((i+5))]}
	((usb_arr_size++))
done

# Test if any USB drives exists
if((usb_arr_size == 0))
then
	printf "No USB devices exists, please plug-in one !\n"
	exit
fi

# Number's regex
number_regex='^[0-9]+$' 

# Read the user's input and test if it is valide
while true
do
	printf "${RED}Ach t7eb taw nti ? ?${NC}\n"
	read usb_choice
	# Test if it's a number
	if ! [[ $usb_choice =~ $number_regex ]]
	then
		printf "%s is not a valid number, try again \n" $usb_choice
	else
		# Test if the choice exists 
		if((usb_choice < usb_arr_size))
                then
                        break
                else
                        printf "%d is not a valide number, try again \n" $usb_choice  
                fi
	fi
done

# Details of chosen USB drive
file_sys=${usb_arr[(($usb_choice*6))]}
mounted_on=${usb_arr[$(($usb_choice*6+5))]}

# Warning message
while true; do
	printf "${RED}Are you sure you want to make this usb drive bootable %s %s ?[y/n]${NC}\n" $file_sys $mounted_on
    	read yn
    	case $yn in
        	[yY]* ) break;;
       		[nN]* ) exit;;
   	esac
done

distros_dir="/home/firefly/gnu-linux-distros"

distros=($(ls "$distros_dir" | grep iso))

# List available distros
for (( i=0; i<${#distros[*]}; i++ ))
do
        printf  "%d) %s \n" $i ${distros[$i]}
done

# Choose a distribution from list
while true
do
        printf "${RED}Which distro you wish to install ?${NC}\n"
        read distro_choice
        # Test if it's a number
        if ! [[ $distro_choice =~ $number_regex ]]
        then
                printf "%s is not a valid number, try again \n" $distro_choice
        else
                # Test if the choice exists 
                if((distro_choice < ${#distros[*]}))
                then
                        break
                else
                        printf "%d is not a valide number, try again \n" $distro_choice
                fi
        fi
done

# Save user's choice
distro=${distros[$distro_choice]}

# Make a directory where the distro will be mounted (only if dir doesn't exist already)
mkdir -p "/media/iso"
mkdir -p "/media/iso/$distro"
mount -o loop "$distros_dir/$distro" "/media/iso/$distro"

#Coping files from the mounted ISO to USB drive
printf "Copying files... \n"
cp -rv "/media/iso/$distro/." "$mounted_on"
printf "Done copying file \n"

#install some staff (if necessary)
printf "Check and install syslinux and mtools \n"
dnf -y install syslinux mtools

#Make USB bootable
printf "Making USB bootable \n"
sleep 2
syslinux -s "$file_sys"

#Rename isolinux to syslinux
printf "Renaming some files \n"
sleep 2
mv "$mounted_on/isolinux" "$mounted_on/syslinux"

#Rename isolinux.cfg to syslinux.cfg
mv "$mounted_on/syslinux/isolinux.cfg" "$mounted_on/syslinux/syslinux.cfg"

#Umout ISO mounted file
printf "Umount ISI \n"
sleep 2
umount "/media/iso/$distro"

printf "${RED}All done !${NC}\n"
