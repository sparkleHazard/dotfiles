xrandr --output DP-2 --primary --mode 1920x1080 --rate 144.00 --output HDMI-2 --mode 1920x1080 --rate 60.00 --above DP-2 &
feh --bg-scale /home/alan1/Downloads/11427.jpg &
export PATH=/home/alan1/.scripts:$PATH
picom &
exec dwm
