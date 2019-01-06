#ntpdate cn.ntp.org.cn
#avoid authenticatiion error because of different time between slave and controller.
cd /root/avocado-cloudtest
#sh /home/houtf/control/houtf/start_jenkins_vm.sh

BUILD_DOWNLOAD_URL=http://10.120.16.212/build/ThinkCloud-SDS

git pull
#git checkout -b tcs_nfvi origin/tcs_nfvi
#git fetch
make install
rm -f /tmp/sds_token
cp -rf /root/tests.cfg_htf_license_218  /usr/share/avocado-cloudtest/config/tests.cfg
avocado run ceph_management_api.api.license.update_license --job-results-dir=${WORKSPACE} --product-build-number="update license" --jenkins-build-url=$BUILD_URL

echo "================================================="
echo "Successfully updated license, start running test"
echo "================================================="

cp -rf /root/tests.cfg_htf_scenario_218  /usr/share/avocado-cloudtest/config/tests.cfg
sed -i "/CephMgmtScenarioTest/i\        branch_name = ${branch_name}\n        manifest_file = ${manifest_file}" /usr/share/avocado-cloudtest/config/tests.cfg
echo "        branch_name = ${branch_name}" >> /usr/share/avocado-cloudtest/config/tests.cfg
echo "        manifest_file_path = ${manifest_file}" >> /usr/share/avocado-cloudtest/config/tests.cfg
echo "        daily_build_location = ${BUILD_DOWNLOAD_URL}/${branch_name}/" >> /usr/share/avocado-cloudtest/config/tests.cfg
echo "        product_version = ${product_version}" >> /usr/share/avocado-cloudtest/config/tests.cfg

rm -rf latest_changes.txt && wget -c -q ${BUILD_DOWNLOAD_URL}/${branch_name}/latest_changes.txt
avocado run ceph_management_api --job-results-dir=${WORKSPACE} --product-build-number=$product_build_number --jenkins-build-url=$BUILD_URL --new-patch-file=/root/avocado-cloudtest/latest_changes.txt