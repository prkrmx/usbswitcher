#!/bin/bash 



set -e


printf "TMSI\t\tKc\t\t\tLAI\t\tT3212\tLUS\tDATE\t\t\tNOTES\n"
prev_kc=""
prev_tmsi=""


while true; do
	

	
	# Getting Kc
	value="$(echo -ne "AT+CRSM=176,28448,0,0,9\r\n" | busybox microcom -X -t 200 /dev/ttyACM0)"
	IFS=' ' read -ra chunks <<< $value
	value=${chunks[5]}

	if [ ! -z "$value" ];then
		Kc=${value:1:-4}
		if [ "$Kc" != "$prev_kc" ]; then
			NOTES="!!!"
		else
			NOTES=""
		fi
		prev_kc=$Kc	
	fi




	# echo $value
	# echo $Kc
	
	sleep 5

	# Getting TMSI and LAI
    value="$(echo -ne "AT+CRSM=176,28542,0,0,11\r\n" | busybox microcom -X -t 200 /dev/ttyACM0)"
	IFS=' ' read -ra chunks <<< $value
	value=${chunks[5]}
	if [ ! -z "$value" ];then
		TMSI=${value:1:8}
		if [ "$TMSI" != "$prev_tmsi" ]; then
			NOTES="!!!"
		else
			NOTES=""
		fi
		prev_tmsi=$TMSI
		LAI=${value:9:-6}
		T3212=${value:19:-4}
		LUS=${value:21:-2}
		# echo $value
		# echo $TMSI
		# echo $LAI
		# echo $T3212
		# echo $LUS	
	fi
	

	printf "%s\t%s\t%s\t%s\t%s\t%s %s\t%s\n" $TMSI $Kc $LAI $T3212 $LUS $(date '+%d/%m/%Y %H:%M:%S') $NOTES
done