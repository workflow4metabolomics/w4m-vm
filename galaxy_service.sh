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

PIDFILE=/home/vagrant/galaxy/paster.pid
LOGFILE=/home/vagrant/galaxy/paster.log

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

# Status {{{1
################################################################

status() {
	if [ -f $PIDFILE ] && kill -0 $(cat $PIDFILE); then
		echo 'Service is currently running with PID '$(cat $PIDFILE)'.' >&2
	else
		echo 'Service is stopped.' >&2
	fi
}

# Main {{{1
################################################################

case "$1" in
	start) start ;;
	stop) stop ;;
	restart) stop ; start ;;
	status) status ;;
	*) echo "Usage: $0 {start|stop|restart|status}"
esac
