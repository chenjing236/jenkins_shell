
#!/bin/bash


Branch="tcs_nfvi_centos7.5"
TAG="2.0.2"
BUILD_TYPE="daily"
branch_dir=/home/build/ThinkCloud-SDS/${Branch}/
repo_dir=/root/build/thinkcloud-sds/

cd ${repo_dir}
repo sync

./package_on_SH.sh --mode=${BUILD_TYPE} --tag=${TAG} --number=${BUILD_NUMBER}

product_build_number="deployment-standalone-daily_`date +'%Y%m%d'`_${BUILD_NUMBER}.tar.gz"
echo "product_build_number=${product_build_number}" > ${WORKSPACE}/build_info.properties
echo "branch_name=${Branch}" >> ${WORKSPACE}/build_info.properties

if [ ! -d ${branch_dir} ]; then
    mkdir -p ${branch_dir}
fi
mv *.tar.gz ${branch_dir}
#chown -R apache:apache ${branch_dir}/*
find ${branch_dir} -mtime 3 -name "*.tar.gz" -exec rm -rf {} \;