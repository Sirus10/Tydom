#!/usr/bin/ksh
# Just a simple way to play with tydom main.py file
# Ref : https://domotique.web2diz.net/
# 
# You can use same arguiment than in main.py
# The only difference is a status.txt file willbe generated each time 
# This file can be used to update domoticz for exemple
#
#  Usage : 
#   Only get latest update from devices : 
#   ./manage_tydom.sh
#   
#   Send action to Tydom 
#    Ex1 : move device 1234123 to 10%
#    ./manage_tydom.sh put_devices_data 1234123 10
#
#	
DOMOTICZ=localhost:8080
DIR=/root/Tydom

# Step 1 Run the command to get latest input and manage devices 
python $DIR/main.py $1 $2 $3 $4 >  $DIR/config.json


# Step 2 Merge config/status generated
grep -v DEB $DIR/config.json  |grep ":" > $DIR/status.txt


# Step x Display the file / just for fun
cat $DIR/status.txt


# Update one by one each devices in domoticz
if [ -f $DIR/config.txt ] ; then 
while IFS="|" read -r TYDOM_ID DOMO_ID_VAL DOMO_ID_CMD NAME
do 
	# On recuperer la valeur dans le fichier status.txt pour cet ID
	VALUDOMO=`grep $TYDOM_ID $DIR/status.txt |grep : | cut -d':' -f2 | sed 's/ //'`

	# On met a jour le compteur % dans domoticz
	curl --silent --max-time 5 "http://$DOMOTICZ/json.htm?type=command&param=udevice&idx=$DOMO_ID_VAL&nvalue=0&svalue=$VALUDOMO" >>/dev/null

	# On recupere le nom du selecteur correspondant 
	# NAMEONLY=`curl --max-time 5 -s  "http://192.168.1.103:8080/json.htm?type=devices&rid=$DOMO_ID_CMD" |grep '"Name"' |cut -d'"' -f4 |cut -d'-' -f1`
	
	# if [ "$NAMEONLY" != '' ] ; then 
		#On le renmone en modifiant le % 
		NewName=`echo "$NAME+-+$VALUDOMO%25" |sed "s/ /+/g"`
		echo " "		
		echo NAMEONLY : $NAME
		echo NewName: $NewName
		echo VALUDOMO: $VALUDOMO

		curl --silent --max-time 5 "http://$DOMOTICZ/json.htm?type=setused&idx=$DOMO_ID_CMD&name=$NewName&used=true" >>/dev/null
	# fi

	#On modifi la valeur du selecteur pour ne pas qu'il affiche la derniere valeur (undefined) 
	curl --silent --max-time 5 "http://$DOMOTICZ/json.htm?type=command&param=udevice&idx=$DOMO_ID_CMD&nvalue=100&svalue=5" >>/dev/null

done < $DIR/config.txt
else 
	echo " "
	echo "#### Initialisation config file creation :" 
	echo "#### CONFIG ####"
	grep 1600 $DIR/config.json |grep -v ":" |sed 's/ /|ID_DOMO_SWITCH|ID_DOMO_UTILITY|/'  > $DIR/config.txt

	cat $DIR/config.txt
	echo "#### CONFIG ####"
	echo "#### Please update $DIR/config.txt now" 
fi 

# clear info
rm $DIR/config.json
# rm $DIR/config.txt












