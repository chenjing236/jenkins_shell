cd /root/

echo "product_build_number=${product_build_number}" > ${WORKSPACE}/build_info.properties
echo "branch_name=${branch_name}" >> ${WORKSPACE}/build_info.properties
echo "manifest_file=${manifest_file}" >> ${WORKSPACE}/build_info.properties
echo "product_version=${product_version}" >> ${WORKSPACE}/build_info.properties

# Env on ESXi
#python vmware_revert_snapshot.py -s 10.100.109.113 -u root -p 1234567 -v node1 -v node2 -v node3 -v node4 -v controller
#sleep 180

# Env on C1
cd /home/houtf/control/houtf/rebuild46env
sh -x rebuild_script_sce.sh
