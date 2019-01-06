#########################################################
#
# Pipeline Job for automation test for ThinkCloud-SDS
#
# Author: Yingfu Zhou
# Last Modified: 2018-06-21
#########################################################

#!/bin/bash

sudo auditctl -b 8192
#ntpdate cn.ntp.org.cn
#avoid authenticatiion error because of different time between slave and controller.

BUILD_URL="http://10.120.16.212/build/ThinkCloud-SDS/${branch_name}"

auditctl -b 8192
#ntpdate cn.ntp.org.cn
#avoid authenticatiion error because of different time between slave and controller.

function clear_env() {
    echo "Uninstalling old RPM packages"
    rpm -qa | grep storagemgmt | xargs rpm -e
    rpm -qa | grep horizon | xargs yum remove
    rpm -qa | grep zabbix | xargs rpm -e
    
    echo "Dropping legacy databases..."
    mysql -ustorage -pSDS_Passw0rd -Bse "DROP DATABASE storagemgmt;"
    mysql -ustorage -pSDS_Passw0rd -Bse "DROP DATABASE zabbix;"
    mysql -ustorage -pSDS_Passw0rd -Bse "DROP DATABASE keystone;"
}

function add_key_to_host() {
    add_key='echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCY7x4Eih0ur8TWUNIeIpRWZRp8L2+E0RN20fN5cbfcmd9vCUyapNau2teNU+AT0s6+qAJPJLSXK+4SSLoCSCUUrG5Pk+AaWJgmf9q9omj3HfxILgSRlEhBrPmmlbET6+kgkYBHcgCHqnOAdSGY+VXQy5MKtTjJ+nzOpV2oWBFT7+krBag9N35+vQjWavpSod33n31cPkBexXZVXmbfw7PKoUPsUG64s+aNoyBeZnGBOWDmDwMvx7UkjMRgN8OMfwzjNJ52jmCYpyDZ+sGYFnnDiHHtbyMUS6rnTD9ctlDTst/WajENEHvQ1UOe55zfxwxTax5PG61Tw0IPWhwZoi5 root@controller" >> /root/.ssh/authorized_keys'
    server_ip_list=('192.168.0.16' '192.168.0.167' '192.168.0.166' '192.168.0.30')
    for server_ip in ${server_ip_list[@]}
        do
            sshpass -p lenovo ssh -o 'StrictHostKeyChecking no' root@${server_ip} ${add_key}
        done

}

function download_and_install() {
    cd /root/build
        
    echo "Try to download build: ${product_build_number}"
    wget -q -c --no-check-certificate ${BUILD_URL}/${product_build_number}
    rm -rf deployment
    tar zxvf ${product_build_number}

    #clear_env

    echo "Try to install build: ${product_build_number}"

    pushd deployment
    echo "Installing build..."
    sh standalone-setup.sh install -s -mp SDS_Passw0rd| tee deploy_sds.log 2>&1
    grep "Installed ceph storage management platform successfully" deploy_sds.log
    ret=$?
    popd
    
    echo "product_build_number=${product_build_number}" > ${WORKSPACE}/build_info.properties
    echo "manifest_file=${manifest_file}" >> ${WORKSPACE}/build_info.properties
    echo "branch_name=${branch_name}" >> ${WORKSPACE}/build_info.properties
    echo "product_version=${product_version}" >> ${WORKSPACE}/build_info.properties
    
    sleep 30
    #source ~/localrc; cephmgmtclient update-cluster-conf -c 1 -z 192.168.0.78 -u admin -p zabbix
    add_key_to_host
    exit $ret
}


function batch_audit(){
    server_ip_list=('192.168.1.2' '192.168.1.3' '192.168.1.4' '192.168.1.5')
    cmd_audit="auditctl -b 8192"
    for server_ip in ${server_ip_list[@]}
    do
        echo "--------------------Start execute clear.sh--------------"
        sshpass -p 123456 ssh -tt -o "StrictHostKeyChecking no" root@${server_ip} <<EOF
${cmd_audit}
exit
EOF
    done
}


download_and_install
batch_audit


