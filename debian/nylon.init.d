#! /bin/sh
### BEGIN INIT INFO
# Provides:          nylon
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: SOCKS (v4 and v5) proxy daemon (nylon)
### END INIT INFO
#
# dante SOCKS server init.d file. Based on /etc/init.d/skeleton:
# Version:	@(#)skeleton  1.8  03-Mar-1998  miquels@cistron.nl

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/nylon
NAME=nylon
DESC="Nylon SOCKS daemon"
PIDFILE=/var/run/$NAME.pid
CONFFILE=/etc/$NAME.conf

test -f $DAEMON || exit 0

set -e

# This function makes sure that the Dante server can write to the pid-file.
touch_pidfile ()
{
  if [ -r $CONFFILE ]; then
    uid="`sed -n -e 's/[[:space:]]//g' -e 's/#.*//' -e '/^user\.privileged/{s/[^:]*://p;q;}' $CONFFILE`"
    if [ -n "$uid" ]; then
      touch $PIDFILE
      chown $uid $PIDFILE
    fi
  fi
}
		
case "$1" in
  start)
	if ! egrep -cve '^ *(#|$)' \
	    -e '^(logoutput|user\.((not)?privileged|libwrap)):' \
	    $CONFFILE > /dev/null
	then
		echo "Not starting $DESC: not configured."
		exit 0
	fi
	echo -n "Starting $DESC: "
	touch_pidfile
	start-stop-daemon --start --quiet --oknodo --pidfile $PIDFILE \
		--exec $DAEMON -- 
	echo "$NAME."
	;;
  stop)
	echo -n "Stopping $DESC: "
	start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE \
		--exec $DAEMON
	echo "$NAME."
	;;
  reload|force-reload)
	#
	#	If the daemon can reload its config files on the fly
	#	for example by sending it SIGHUP, do it here.
	#
	#	If the daemon responds to changes in its config file
	#	directly anyway, make this a do-nothing entry.
	#
	 echo "Reloading $DESC configuration files."
	 start-stop-daemon --stop --signal 1 --quiet --pidfile \
		$PIDFILE --exec $DAEMON -- -D
  ;;
  restart)
	#
	#	If the "reload" option is implemented, move the "force-reload"
	#	option to the "reload" entry above. If not, "force-reload" is
	#	just the same as "restart".
	#
	echo -n "Restarting $DESC: "
	start-stop-daemon --stop --quiet --pidfile $PIDFILE --exec $DAEMON
	sleep 1
	touch_pidfile
	start-stop-daemon --start --quiet --pidfile $PIDFILE \
	  --exec $DAEMON --
	echo "$NAME."
	;;
  *)
	N=/etc/init.d/$NAME
	# echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $N {start|stop|restart|force-reload}" >&2
	exit 1
	;;
esac

exit 0
