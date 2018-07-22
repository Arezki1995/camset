#!/bin/bash

buffer=$(mktemp -qt buffer.XXXXX)
temp=$(mktemp -qt temporary.XXXXX)
#---------------------------------------------------------------------------------
function getDevices(){
	v4l2-ctl --list-devices > $buffer
	response=$(cat $buffer)
	echo "$response"
	dialog --title "Devices" \
	       --aspect 16 \
	       --infobox "$response" 0 0
	DEVICES=$(echo "$response" | grep "/dev/")	
	sleep 1  
		 
}

function getSettings(){
	SETTINGS=$(v4l2-ctl -l | cut -d"0" -f 1 | sed 's/ //g' | tr '\n' ' ')
	SETTINGS_NUM=$(v4l2-ctl -l | wc -l)	
}

function settings_menu(){
	count=1
	for element in $SETTINGS; do 
		menuLine[$count]=$(echo "$count $element")
		((count++))
	done
	echo ${menuLine[@]}
	
	dialog --menu "MENU" 0 0 $SETTINGS_NUM ${menuLine[@]} 2>temp
	index=$(cat temp)
	SEL_SETTING=$(echo ${menuLine[$index]} | sed 's/[0-9]* //g')
		
}


function setSettings(){
	while [ true ]; do		
	INFO=$(v4l2-ctl -l | grep "$SEL_SETTING" | cut -d: -f2)
	dialog --title "$SEL_SETTING" --inputbox "$INFO" 0 0 2>$temp
	
	VAL=$(cat $temp)
	if echo "$VAL" | grep "[a-z]"; then
		dialog --title "BAD INPUT" \
	       	       --aspect 16 \
	               --infobox "Put a correct value and try again." 0 0
			sleep 2s
	else
		break
	fi	
	done
	v4l2-ctl --set-ctrl=$SEL_SETTING=$VAL 
}

function installPackages(){
	echo "Installing webcam driver..."
}

function main_menu(){
while [ true ]; do
dialog --title "MY WEBCAM" \
       --menu "OPTIONS" 0 0 4 \
	 1 "Set settings" \
	 2 "Install Required Packages" \
	 3 "Restore Default"\
 	 4 "Quit" 2> $temp
OPT=$(cat $temp)

case $OPT in 

1)
	getSettings
	settings_menu
	setSettings
	;;
2)
	installPackages
	;;
3)
	clear
	echo "RESTORING DEFAULT..."
	sleep 2s
	;;
4)	
	dialog --aspect 16 \
               --infobox " GOODBYE !" 0 0
	sleep 1
	exit
	break;;
*)
	dialog --title "Devices" \
	--aspect 16 \
        --infobox " Wrong selection" 0 0
esac
done

}

#----------------------------------------------------------------------------------

getDevices
if [ $(echo "$DEVICES" | wc -l) == 1 ]; then
	clear	
	echo "Default device selected..."
	echo -e "\t$DEVICES"	
	sleep 1
fi

if [ $(echo "$DEVICES" | wc -l) == 0 ]; then
	clear	
	echo "NO VIDEO DEVICE DETECTED !"
	sleep 2
	exit
fi

main_menu






