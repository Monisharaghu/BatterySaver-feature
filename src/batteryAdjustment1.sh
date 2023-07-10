#!/bin/bash

state=$(upower -i `upower -e  | grep BAT`| grep -i "state")
per=$(upower -i `upower -e  | grep BAT`| grep -i "percentage"| sed 's/^.* //')
curr_level=${per//[%]/}
bat_level=50
cpu=5;
echo $state

if [[ $state == "discharging"  ]];
	echo "currentLevel : $curr_level"
then

  if [[ $curr_level -lt $bat_level ]];
  then
    notify-send "Battery Warning" "Your battery is low Please connect your charger"
  fi
fi

cur_b=$(xrandr --current --verbose | grep -i "Brightness" | sed 's/^.* //')
temp1=$(echo "$cur_b*100"|bc)
temp=$( printf "%0.f" $temp1 )

LEVEL=$(($temp))

if [[ $curr_level -lt $bat_level ]];
then
      echo "currLevel lesser than batLevel"
			bat_level=$(($curr_level))
fi

#Printing bat_level and curr_level
echo "The bat level : $bat_level"
echo "The current level : $curr_level"

#Sets Screen Brightness
while [[ $curr_level != 10 && $state == *"discharging"* ]];
do
	if [[ $bat_level -eq $curr_level ]];
	then
		echo "The current battery percentage is: $bat_level"
		brightness_level=$(( $LEVEL / 100)).$(( $LEVEL % 100 ))
		screenname=$(xrandr | grep " connected" | cut -f1 -d" ")
		xrandr --output $screenname --brightness $brightness_level;
		echo -e "[info]: Screen Brightness level set to" $LEVEL"%"
		LEVEL=$(($LEVEL-5))
		bat_level=$((bat_level-1))

		CPU=$(sar 1 5 | grep "Average" | sed 's/^.* //')
		CPU=$( printf "%.0f" $CPU )
		CPUO=$((100-$CPU))
		if [[ $CPUO -ge $cpo ]];
		then
	               python3 cpu_occupancy.py3
			#echo "CPU is occupied.Close background applications"
		fi
	fi

	#updating current state
	state=$(upower -i `upower -e  | grep BAT`| grep -i "state")
	if [[ $state != *"discharging"* ]];
	then
		break
	fi

	curr_level1=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -i "percentage" | sed 's/^.* //')
	curr_level=${curr_level1//[%]/}

	if [[ $bat_level -gt $curr_level ]];
	then

					 bat_level=$(($curr_level))
	fi
done

state_d=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -i "state")
screenname=$(xrandr | grep " connected" | cut -f1 -d" ")

if [[ $state_d != "discharging" ]];
then
	xrandr --output $screenname --brightness $cur_b;
fi

exit 0
