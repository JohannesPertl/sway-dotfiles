#!/bin/bash
## Base on http://www.nicknorton.net/mousewheel.sh
### see if imwheel config exists, if not create it ###
if [ ! -f ~/.imwheelrc ]
then

cat >~/.imwheelrc<<EOF
".*"
None,      Up,   Button4, 1
None,      Down, Button5, 1
Control_L, Up,   Control_L|Button4
Control_L, Down, Control_L|Button5
Shift_L,   Up,   Shift_L|Button4
Shift_L,   Down, Shift_L|Button5
EOF

fi
##########################################################

CURRENT_VALUE=$(awk -F 'Button4,' '{print $2}' ~/.imwheelrc)

NEW_VALUE=$1

if [ -z "$NEW_VALUE" ]
then
    SCRIPT_NAME=`basename "$0"`
    echo "Usage: $SCRIPT_NAME <speed>"
    exit 1
fi

sed -i "s/\($TARGET_KEY *Button4, *\).*/\1$NEW_VALUE/" ~/.imwheelrc # find the string Button4, and write new value.
sed -i "s/\($TARGET_KEY *Button5, *\).*/\1$NEW_VALUE/" ~/.imwheelrc # find the string Button5, and write new value.

cat ~/.imwheelrc
imwheel --kill --buttons "4 5"

