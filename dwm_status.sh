# To set Mouse map to Left-Hand mouse

id=$(xinput | grep -Eo "Mouse.*id=[0-9]+" | grep -Eo "[0-9]+")
xinput set-button-map $id 3 2 1 4 5 6 7 8 9 10 11 12 13 14 15 16

DWM_RENEW_INT=30;

while true; do

	if [ "$( cat /sys/class/power_supply/AC/online )" -eq "1" ]; then
		TYPE="AC"
	else
		TYPE="B"
	fi

	UPTIME=$(uptime | awk '{ print $3 $4}')
	LOCALTIME=$(date "+W:%U | %F  %a  %H:%M")
	CHARGE=$(acpi -b | awk '{ print $4 }')

	xsetroot -name "$TYPE:$CHARGE  |  U:$UPTIME  |  $LOCALTIME"

	sleep $DWM_RENEW_INT;

done &
