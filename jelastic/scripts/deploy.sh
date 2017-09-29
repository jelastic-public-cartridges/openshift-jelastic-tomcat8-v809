#!/bin/bash

# Copyright 2015 Jelastic, Inc.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[ -n "${TOMCATDEPLOYLIB_VERSION:-}" ] && return 0;
TOMCATDEPLOYLIB_VERSION="0.1";

include os;

TOMCAT_HOME='/opt/tomcat/'

function ensureFileCanBeDownloaded(){
    local resource_url=$1;
    resource_data_dize=$($CURL -s --head $resource_url | $GREP "Content-Length" | $AWK -F ":" '{ print $2 }'| $SED 's/[^0-9]//g');
    freebytesleft=$(( 1024 *  $(df  | $GREP "/$" | $AWK '{ print $4 }' | head -n 1)-1024*1024));
    [ -z ${resource_data_dize} ] && return 0;
    [ ${resource_data_dize} -lt  ${freebytesleft} ] || { writeJSONResponseErr "result=>4075" "message=>No free diskspace"; die -q; }
    return 0;
}

function getPackageName() {
    if [ -f "$package_url" ]; then
        package_name=$(basename "${package_url}")
        package_path=$(dirname "${package_url}")
    elif [[ "${package_url}" =~ file://* ]]; then
        package_name=$(basename "${package_url:7}")
        package_path=$(dirname "${package_url:7}")
        [ -f "${package_path}/${package_name}" ] || { writeJSONResponseErr "result=>4078" "message=>Error loading file from URL"; die -q; }
    else
        ensureFileCanBeDownloaded $package_url;
        $WGET --no-check-certificate --content-disposition --directory-prefix="$DOWNLOADS" $package_url >> $ACTIONS_LOG 2>&1 || { writeJSONResponseErr "result=>4078" "message=>Error loading file from URL"; die -q; }
        package_name="$(ls ${DOWNLOADS})";
        package_path=${DOWNLOADS};
        [ ! -s "${package_path}/${package_name}" ] && {
            set -f
            rm -f "${package_name}";
            set +f
            writeJSONResponseErr "result=>4078" "message=>Error loading file from URL";
            die -q;
        }
    fi
}

function _applyPreDeploy(){
    
    if [ -e "$TOMCAT_HOME/work/Catalina" ]
    then 
        rm -fr $TOMCAT_HOME/work/Catalina
    fi
}

function _applyPostDeploy(){

        if [ ! -d "$TOMCAT_HOME/temp" ]
    then 
        mkdir -p "$TOMCAT_HOME/temp";
        $CHOWN -R  $DATA_OWNER "$TOMCAT_HOME/temp" 2>>"$JEM_CALLS_LOG";
    fi
}

function _applyPreUndeploy(){
        return 0;
}

function _applyPostUndeploy(){
        [ -d "${APPS_DIR}" ] && rm -rf ${APPS_DIR}/${context}
        rm -rf ${WEBROOT}/${context}
}

function _applyPreRename(){

        if [ -e "$TOMCAT_HOME/work/Catalina" ]
        then 
                rm -fr $TOMCAT_HOME/work/Catalina;
        fi
        if [ -e "$TOMCAT_HOME/conf/Catalina" ]
        then 
                rm -fr $TOMCAT_HOME/conf/Catalina;
        fi
        if [ -e "${WEBROOT}/$newContext" ]
        then
            rm -fr ${WEBROOT}/$newContext;
        fi
}

function _applyPostRename(){
        shopt -s dotglob;
        [ -d ${WEBROOT}/$oldContext ] && mv ${WEBROOT}/$oldContext ${WEBROOT}/$newContext;
        [ -d ${APPS_DIR}/$oldContext ] && mv ${APPS_DIR}/$oldContext ${APPS_DIR}/$newContext;
    shopt -u dotglob; 
}

function verifyUnpackedContent(){
    local context=$1
    local pull_inverval_for_content=2s;
    local pull_inverval_for_directory=2s;
    local content_size_step1 content_size_step2;
    local attempt_amount=450;
    local attempt_num=0;

    while [ true ] 
    do

        local content_path;

        content_path="${WEBROOT}/${context}";
        

        [ -d $content_path ] && {

            content_size_step1=$(du -s $content_path);
            sleep $pull_inverval_for_content;
            content_size_step2=$(du -s $content_path);
            [[ $content_size_step1 == $content_size_step2 ]] && return 0;
        } || let $(( attempt_num ++ ));
    sleep $pull_inverval_for_directory;
    [ $attempt_num -gt $attempt_amount ] && writeJSONResponceErr "result=>4071" "message=>Cannot unpack pakage" && exit 4071;
    done
}

function _clearCache(){
        if [[ -d "$DOWNLOADS" ]]
        then
                shopt -s dotglob;
                rm -Rf ${DOWNLOADS}/*;
                shopt -u dotglob;
        fi
}

function _deploy(){

    if [[ -z "$package_url" || -z "$context" ]]
    then
        echo "Wrong arguments for deploy" 1>&2;
        exit 1;
    fi
    _clearCache; 
    getPackageName;
    ensureFileCanBeUncompressed ${package_name};
    stopService ${SERVICE} > /dev/null 2>&1;

    if [ -e "${WEBROOT}/$context" ]
    then
        set -f
        rm -fr ${WEBROOT}/$context;
        set +f
    fi

    _applyPreDeploy;

    echo $package_name | $GREP -qP "ear$" && ext="ear" || ext="war";

    if [[ ${ext} == "ear" ]]
    then
        [ ! -d  $APPS_DIR ] && mkdir -p $APPS_DIR && chown -R  $DATA_OWNER  ${APPS_DIR} 2>>"$JEM_CALLS_LOG";
        /usr/bin/cp "${package_path}/${package_name}" "${APPS_DIR}/${context}.${ext}";
    else
        /usr/bin/cp "${package_path}/${package_name}" "${WEBROOT}/${context}.${ext}";
    fi

    _applyPostDeploy;
    _clearCache; 
    startService ${SERVICE} > /dev/null 2>&1;
    verifyUnpackedContent "${context}";
}

function _undeploy(){
    if [[ -z "$context" ]]
    then
        echo "Wrong arguments for undeploy" 1>&2
        exit 1
    fi
    
    _applyPreUndeploy;

    [ -f ${WEBROOT}/${context}.war ] && rm -f ${WEBROOT}/${context}.war
    [ -f ${APPS_DIR}/${context}.ear ] && rm -f ${APPS_DIR}/${context}.ear

    _applyPostUndeploy;

}   

function _renameContext(){

    if [[ -z "newContext" || -z "$oldContext" ]]
    then
        echo "Wrong arguments for rename" 1>&2
        exit 1
    fi

    stopService ${SERVICE} > /dev/null 2>&1;

    _applyPreRename;

    shopt -s dotglob;


    [ -e ${WEBROOT}/${oldContext}.war ] && mv ${WEBROOT}/${oldContext}.war  ${WEBROOT}/${newContext}.war && war_deploy_result=0 || war_deploy_result=1;
    [ -e ${APPS_DIR}/${oldContext}.ear ] && mv ${APPS_DIR}/${oldContext}.ear  ${APPS_DIR}/${newContext}.ear && ear_deploy_result=0 || ear_deploy_result=1;

    [ $(( $war_deploy_result & $ear_deploy_result )) -ne 0  ] && {

        shopt -u dotglob;
                startService ${SERVICE} > /dev/null 2>&1;
                writeJSONResponceErr "result=>4052" "message=>Context does not exist";
                die -q;
        }

    shopt -u dotglob;   

    _applyPostRename;

    startService ${SERVICE} > /dev/null 2>&1;

    verifyUnpackedContent "${newContext}";
 
}

function describeDeploy(){
    echo "deploy java application \n\t\t -p \t <package URL> \n\t\t -c
\t <context> \n\t\t ";
}

function describeUndeploy(){
    echo "undeploy java application \n\t\t -c \t <context>";
}

function describeRename(){
    echo "rename java context \n\t\t -n \t <new context> \n\t\t -o \t
<old context>\n\t\t";
}
