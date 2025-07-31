#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi


if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# default stuff above; custom stuff below

# disable builtin screensaver and powermanagment
xset s off -dpms

# start various demons in background if installed
command -v xscreensaver && xscreensaver -nosplash &
command -v nm-applet && nm-applet &
command -v udiskie && udiskie &
command -v keepassxc && keepassxc &
command -v nitrogen && nitrogen --restore &

# source local config
[ -f ~/.xprofile ] && . ~/.xprofile

# awesome!
exec awesome
