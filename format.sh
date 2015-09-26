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
	printf "${RED}Which USB drive will you use ?${NC}\n"
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
	printf "${RED}Are you sure you want to format this usb drive %s %s ?[y/n]${NC}\n" $file_sys $mounted_on
    	read yn
    	case $yn in
        	[yY]* ) break;;
       		[nN]* ) exit;;
   	esac
done

# Umouting USB drive
printf "Umounting %s \n" $mounted_on
sleep 2
umount $mounted_on

#Format USB drive
printf "Formating %s \n" $file_sys
mkfs.vfat -F 32 $file_sys
printf "Done formating \n"
