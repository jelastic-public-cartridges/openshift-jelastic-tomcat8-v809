#!/bin/bash
CONFFILE='/opt/repo/versions/8.0.30/conf/variables.conf'
JELASTIC_GC_AGENT="jelastic-gc-agent.jar"

SED=`which sed`
AWK=`which awk`
GREP=`which grep`
DEBUG=0
GC=""

if [ "$1" == "debug" ]
then
    DEBUG=1
fi
confresult=" "
if [ -f $CONFFILE ]
then
    confdata=`$SED '/^#/d' $CONFFILE | $AWK -F# '{print $1}' |$SED 's/\s/\n/g'`
    for i in $confdata
    do
        if `echo $i | grep -q '#'`; then continue;fi
            [ "$DEBUG" -eq 1 ] && echo "Ok    : $i" 1>&2;
	    if `echo $i | $GREP -qiE '\-Xmx[[:digit:]]{1,}[mgkMGK]$'`; then XMX="${i}";fi
            confresult=$confresult" $i"
        done
fi

[ -z "$XMX" ] && XMX=`echo $JAVA_OPTS | sed -nre  's/.*(-Xmx[[:digit:]]{1,}[mgkMGK]?).*/\1/p' 2>/dev/null`
export XMX

if `echo $confresult | grep -q ${JELASTIC_GC_AGENT}`;
then
    if ! `echo $confresult | grep -q 'UseAdaptiveSizePolicy'`;
    then
	confresult=$confresult" -XX:-UseAdaptiveSizePolicy"
    fi
fi 

export JAVA_OPTS="$JAVA_OPTS $confresult"

source /opt/tomcat/conf/memoryConfig.sh

[ "$DEBUG" -eq 1 ] && {
    echo "confresult=$confresult"
    echo "XMX=$XMX"
    echo "XMS=$XMS"
    echo "XMN=$XMN"
    echo "GC=$GC"
}
