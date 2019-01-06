#!/bin/bash


Branch="tcs_nfvi_centos7.5"
TAG="2.0.2"
BUILD_TYPE="daily"
branch_dir=/build/ThinkCloud-SDS/${Branch}/
repo_dir=/root/build/thinkcloud-sds/

cd ${repo_dir}
pwd
repo sync

./package_on_SH.sh --mode=${BUILD_TYPE} --tag=${TAG} --number=${BUILD_NUMBER}

mv *.tar.gz /var/www/html${branch_dir}
