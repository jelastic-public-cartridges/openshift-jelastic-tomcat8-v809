#!/bin/bash

inherit tomcat-ssl
function _enableSSL(){
   enableSSL $@
}

function _disableSSL(){
   disableSSL $@
}

