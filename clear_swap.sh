#!/bin/bash

## check for root rights
[ "$(whoami)" != "root" ] && { echo "You need to be root to run this script"; exit 1; }

## calculate difference between swap used and free memory (hint: if swap used is larger than freemem, the system might get unstable on swap deactivation)
MEM_AFTER_SWAPOFF=$(awk 'BEGIN {LN=0}; $1 ~ /(MemFree|SwapTotal|SwapFree)/ { mem += (LN==0 ? $2 : (LN==1 ? -($2) : $2 ) );  if(LN==2) print mem; LN++; }' /proc/meminfo)

CONT=1

## if swap used is larger than freemem, we should ask the user to be sure about continuation !
[ $MEM_AFTER_SWAPOFF -lt 0 ] && { 
	tput setaf 1 ; 
	echo -e "\nThe free memory is less than the used swap (memory after swapoff = $MEM_AFTER_SWAPOFF KB)!"
	echo -e "If we continue, the system might get unstable (beyond usability).\n"; 
	tput sgr0; 

	CONT=0
	read -p $'Continue anyways ? (Y|n) default: n\n' RE;
	{ [ "$RE" == "Y" ] && { echo -e '\nOkay we will continue, but you have been warned.\n'; CONT=1; } || { echo "Canceling due to lack of free memory."; exit 1; }; }
}



swapoff -a
sudo swapon -a

