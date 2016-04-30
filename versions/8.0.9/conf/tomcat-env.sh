#!/bin/sh
#  $Id$
#  $Revision$
#  $Date$
#  $Author$
#  $HeadURL$

APP_ENV="/opt/repo/versions/8.0.9/conf/tomcat-env.sh"
JAVA_HOME="/usr/java/latest"
CATALINA_HOME="/opt/repo/versions/8.0.9"
JASPER_HOME="/opt/repo/versions/8.0.9"
CATALINA_TMPDIR="/opt/repo/versions/8.0.9/temp"
CATALINA_BASE="/opt/repo/versions/8.0.9"
JVM_ID="tomcat"
VTUNIP=""
MAGICPORT=""
#ON_ERRORS_OPTS="-XX:OnOutOfMemoryError=/opt/tomcat/OnOutOfMemoryError.sh -XX:OnError=/opt/tomcat/OnError.sh"
ON_ERRORS_OPTS=""
#JAVA_OPTS="-Xmn50M  -Xminf0.1 -Xmaxf0.3 -XX:+UseG1GC -XX:-UseAdaptiveSizePolicy -XX:+UseCompressedOops -server 
JVM_SUFFIX=`hostname | awk -F "." '{ print $6 }'`
JAVA_OPTS="-DReceiverIp=$VTUNIP -DMagicPort=$MAGICPORT $ON_ERRORS_OPTS -Xminf0.1 -Xmaxf0.3 -XX:-UseAdaptiveSizePolicy -XX:+UseCompressedOops -server -Djvm=$JVM_ID -Xms64M -Xmx989M -Djava.awt.headless=true -XX:MaxPermSize=256m -Djava.net.preferIPv4Stack=true $JPDA_OPTS $JMX_OPTS -DjvmRid=$JVM_SUFFIX -Dorg.apache.catalina.SESSION_COOKIE_NAME=JELSESSIONID  -Dorg.apache.catalina.SESSION_PARAMETER_NAME=jelsessionid"
TOMCAT_USER="jelastic"
let SHUTDOWN_WAIT=2

