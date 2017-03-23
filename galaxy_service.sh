#!/bin/sh
# vi: fdm=marker

### BEGIN INIT INFO
# Provides:          galaxy
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Galaxy
### END INIT INFO

SCRIPT=/home/vagrant/galaxy/run.sh
RUNAS=vagrant

PIDFILE=/var/run/galaxy.pid
LOGFILE=/var/log/galaxy.log

# Start {{{1
################################################################

start() {
	if [ -f $PIDFILE ] && kill -0 $(cat $PIDFILE); then
		echo 'Service already running' >&2
		return 1
	fi
	echo 'Starting service…' >&2
	local CMD="$SCRIPT --daemon --log-file=\"$LOGFILE\" --pid-file=\"$PIDFILE\""
	su -c "$CMD" $RUNAS
	echo 'Service started' >&2
}

# Stop {{{1
################################################################

stop() {
	if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
		echo 'Service not running' >&2
		return 1
	fi
	echo 'Stopping service…' >&2
	$SCRIPT --stop-daemon
	echo 'Service stopped' >&2
}

# Main {{{1
################################################################

case "$1" in
	start) start ;;
	stop) stop ;;
	retart) stop ; start ;;
	*) echo "Usage: $0 {start|stop|restart}"
esac
