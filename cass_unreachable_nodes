#! /bin/bash

#This Plug-in monitors the Unreachable nodes in Cassandra Ring; using nodetool ring command

# Author - Juned Memon



#########THIS part is for Nagios ################################
PROGNAME=`/usr/bin/basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION=`echo '$Revision: 1749 $' | sed -e 's/[^0-9.]//g'`
#. $PROGPATH/utils.sh
.  /usr/local/nagios/libexec/utils.sh


######################################################################

#Function to print Usage
function usage
{
usage1="Usage: $0  [-w <WARN>] [-c <CRIT>] -H <HOST> -P <PORT>"
usage2="<WARN> is Number of Unreachable Nodes for WARNing state   Default is 1."
usage3="<CRIT> is Number of Unreachable Nodes   state  Default is 2.\n <HOST> of cassandra node; Default is localhost \n <PORT>  JMX port ; Default is 7199 "
echo $usage1
echo""
echo $usage2
echo""
echo "$usage3"


exit $STATE_UNKNOWN
}


WARN=5
CRIT=10
HOST="localhost"
PORT=7199
#####################################################################
# get parameter values in Variables

while test -n "$1"; do
    case "$1" in
        -c )
            CRIT=$2
            shift
            ;;
        -w )
            WARN=$2
            shift
            ;;
        -h)
            usage
            ;;
         -H)
            HOST=$2
            shift
            ;;
         -P)
            PORT=$2
            shift
            ;;

         *)
            echo "Unknown argument: $1"
            usage
            ;;
    esac
    shift
done

#####################################################################

DOWN=$( nodetool -h $HOST -p $PORT ring | grep Down | wc -l )
#DOWN=$( nodetool -h $HOST -p $PORT ring | grep Up | wc -l )
IP=$( nodetool -h $HOST -p $PORT ring | grep Down | awk '{printf $1 ";"}' )
#IP=$( nodetool -h $HOST -p $PORT ring |  grep Up | awk '{printf $1 " ; "}' )

echo "$DOWN Unreachable node in Cassandra Ring. [$IP] "

#if CRIT > DOWN >WARN then WARNing
if [ $DOWN -ge $WARN ]; then
if [ $DOWN -lt $CRIT ]; then
exitstatus=$STATE_WARNING
exit $exitstatus
fi
fi
# DOWN>CRIT then CRITical
if [ $DOWN -ge $CRIT ]; then
exitstatus=$STATE_CRITICAL
exit $exitstatus
fi

# 0<=DOWN <WARN
if [ $DOWN -le $WARN ]; then
exitstatus=$STATE_OK
exit $exitstatus
fi

