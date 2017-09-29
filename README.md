env-utils
=========

Set of utities for environment settings.. for dwm, bash, vim etc..

Setting dwm as the dm:
------------------------
cat > /etc/lightdm/lightdm.conf.d/50-dwm.conf
[SeatDefaults]
session-setup-script=/usr/share/qparbhu_init.sh

display-setup-script=xrandr --output HDMI1 --primary

origin  git://git.suckless.org/dwm (fetch)
origin  git://git.suckless.org/dmenu (fetch)


default dm for the user:
------------------------
cat ~/.dmrc
[Desktop]
Session=dwm

