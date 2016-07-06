#!/bin/sh

APP_ENV="/opt/repo/versions/8.5.3/conf/tomcat-env.sh"
JAVA_HOME="/usr/java/latest"
CATALINA_HOME="/opt/repo/versions/8.5.3"
JASPER_HOME="/opt/repo/versions/8.5.3"
CATALINA_TMPDIR="/opt/repo/versions/8.5.3/temp"
CATALINA_BASE="/opt/repo/versions/8.5.3"
JVM_ID="jelastic"
JAVA_OPTS="-DReceiverIp=$VTUNIP -DMagicPort=$MAGICPORT $ON_ERRORS_OPTS -server -Djvm=$JVM_ID -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true $JPDA_OPTS $JMX_OPTS -DjvmRid=$JVM_SUFFIX"
TOMCAT_USER="jelastic"
let SHUTDOWN_WAIT=2

if [ -x /opt/tomcat/bin/variablesparser.sh ]; then
    . /opt/tomcat/bin/variablesparser.sh
fi

