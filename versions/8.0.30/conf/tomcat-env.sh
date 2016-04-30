#!/bin/sh
#  $Id$
#  $Revision$
#  $Date$
#  $Author$
#  $HeadURL$

APP_ENV="/opt/repo/versions/8.0.30/conf/tomcat-env.sh"
JAVA_HOME="/usr/java/latest"
CATALINA_HOME="/opt/repo/versions/8.0.30"
JASPER_HOME="/opt/repo/versions/8.0.30"
CATALINA_TMPDIR="/opt/repo/versions/8.0.30/temp"
CATALINA_BASE="/opt/repo/versions/8.0.30"
JVM_ID="jelastic"
JAVA_OPTS="-Xmn30M -server -Djvm=$JVM_ID -Xms32M -Xmx1501M -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses $JPDA_OPTS $JMX_OPTS -Dorg.apache.catalina.SESSION_COOKIE_NAME=JELSESSIONID -Dorg.apache.catalina.SESSION_PARAMETER_NAME=jelsessionid"
TOMCAT_USER="jelastic"
let SHUTDOWN_WAIT=2

