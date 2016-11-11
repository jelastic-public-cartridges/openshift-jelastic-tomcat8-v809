#!/bin/bash

inherit tomcat-ssl
function _enableSSL(){
   enableSSL $@
}

