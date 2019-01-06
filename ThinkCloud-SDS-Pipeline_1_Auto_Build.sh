#########################################################
#
# Pipeline Job for auto packaging for ThinkCloud-SDS
#
# Author: Yingfu Zhou
# Last Modified: 2018-06-20
#########################################################

#!/bin/bash


Branch="tcs_nfvi_centos7.5"
TAG="2.0.2"
BUILD_TYPE="daily"
branch_dir=/builds/ThinkCloud-SDS/${Branch}/
repo_dir=/root/thinkcloud-sds/

cd ${repo_dir}
repo sync

TZ='Asia/Shanghai'; export TZ

build_number=`python setup/get_latest_number.py ${BUILD_TYPE} ${Branch}`

BUILD_DATE="daily_`date +'%Y%m%d'`_${build_number}"

manifest_file="thinkcloud_sds_${BUILD_DATE}.xml"



function do_package() {

    #previous_manifest_file="thinkcloud_sds_daily_`date +'%Y%m%d'`_`expr $build_number - 1`.xml"
    last_build_number="*`expr $build_number - 1`.xml"
    previous_manifest_file=`find ${repo_dir}/.repo/manifests/${Branch}/daily/ -name ${last_build_number} -print`
    previous_manifest_file=`echo ${previous_manifest_file}`
    
    sh ./generate_manifest.sh -m daily -n ${build_number} -b ${Branch}
    
    repo sync -m ${repo_dir}/.repo/manifests/${Branch}/daily/${manifest_file}
    
    #branch_exists=`repo forall -c "git show-ref --verify --quiet refs/heads/${Branch}"`
    #repo forall -c "git checkout -b ${Branch} origin/${Branch}"
    #repo sync
    
    
    product_build_number="deployment-standalone-daily_`date +'%Y%m%d'`_${build_number}.tar.gz"
    #latest_changes=`repo diffmanifests ${repo_dir}/.repo/manifests/${Branch}/daily/${previous_manifest_file} ${repo_dir}/.repo/manifests/${Branch}/daily/${manifest_file}`
    latest_changes=`repo diffmanifests ${previous_manifest_file} ${repo_dir}/.repo/manifests/${Branch}/daily/${manifest_file}`
    
    echo "$latest_changes" > ${branch_dir}/latest_changes.txt
    echo '============='
    echo "Latest Changes of this build:"
    echo "$latest_changes"
    echo '============='
    
    latest_changes=`echo "$latest_changes" |sed ':a;N;$!ba;s/\n/#/g'`
    
    
    product_build_number="deployment-standalone-daily_`date +'%Y%m%d'`_${build_number}.tar.gz"
    build_server=`echo ${NODE_NAME} | grep -Po '([0-9]{1,3}(\.\b|$)){4}'`
    build_download_url="http://${build_server}/build/ThinkCloud-SDS/${Branch}/${product_build_number}"
    echo "build successfully: ${product_build_number}"
    echo "product_build_number=${product_build_number}" > ${WORKSPACE}/build_info.properties
    echo "branch_name=${Branch}" >> ${WORKSPACE}/build_info.properties
    # echo "manifest_file=${manifest_file}" >> ${WORKSPACE}/build_info.properties
    manifest_file_link="https://gitlab.lenovo.com/thinkcloud-sds/manifests/tree/master/${Branch}/daily/${manifest_file}"
    echo "manifest_file=${manifest_file_link}" >> ${WORKSPACE}/build_info.properties
    echo "product_download_link=${build_download_url}" >> ${WORKSPACE}/build_info.properties
    echo "product_version=${TAG}" >> ${WORKSPACE}/build_info.properties
    echo "latest_changes=${latest_changes}" >> ${WORKSPACE}/build_info.properties
    
    
    echo 
    echo "Start automatically packaging for branch ${Branch}..."
    echo 
    
    
    if [ "${BUILD_TYPE}" = "daily" ]; then
        ./package_on_SH.sh --mode=${BUILD_TYPE} --tag=${TAG} --number=${build_number} -k true
    else
        ./package_on_SH.sh --mode=${BUILD_TYPE} --tag=${TAG} --number=${build_number}
    fi
    
    mv deployment-standalone-daily* ${branch_dir}
    chown apache:apache ${branch_dir}/*
    
    echo "Start push manifest file to the gerrit ..."
    cd ${repo_dir}/.repo/manifests/${Branch}/daily/ 
    git push gerrit HEAD:master
}


function cleanup() {
    echo "Build failed, deleting manifest file and tag..."
    rm -f ${repo_dir}/.repo/manifests/${Branch}/daily/${manifest_file}
    repo forall -c "git tag -d ${BUILD_DATE}"
}


trap "cleanup" ERR
do_package
