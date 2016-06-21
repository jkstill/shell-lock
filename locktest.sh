#!/bin/bash

LOCKFILE=/tmp/testlock.lock

function script_lock  {
	typeset MY_LOCKFILE
	MY_LOCKFILE=$1
	SCRIPTNAME=$(basename $0)
	#echo SCRIPTNAME: $SCRIPTNAME
	SCRIPTPFX=$(echo $SCRIPTNAME|cut -b1)
	LB='['; RB=']'
	SCRIPTSFX=$(echo $SCRIPTNAME|cut -b2-)
	SCRIPTCHK='\['"${SCRIPTPFX}"'\]'"${SCRIPTSFX}"
	#echo SCRIPTCHK: $SCRIPTCHK

	# remove stale lockfile
	[ -r "$MY_LOCKFILE" ] && {
		PID=$(cat $MY_LOCKFILE)
		ACTIVE=$(ps --no-headers -p $PID | grep $SCRIPTNAME)
		#ACTIVE=$(ps --no-headers -p $PID )
		if [ -z "$ACTIVE" ]; then
			rm -f $MY_LOCKFILE
		fi
	}

	# set lock

	if (set -o noclobber; echo "$$" > "$MY_LOCKFILE") 2> /dev/null; then
		trap 'rm -f "$MY_LOCKFILE"; exit $?' INT TERM EXIT
		return 0
	else
		echo "Failed to acquire $LOCKFILE. Held by $(cat $LOCKFILE)"
		exit 1
	fi
}

function script_unlock {
	rm -f "$LOCKFILE"
	trap - INT TERM EXIT
}

script_lock $LOCKFILE

echo press '<ENTER>...'
read dummy 

script_unlock

