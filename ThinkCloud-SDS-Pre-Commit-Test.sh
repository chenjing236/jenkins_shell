Branch="tcs_nfvi_centos7.5"
TAG="2.0.2"
BUILD_TYPE="daily"

mkdir ${BUILD_NUMBER}
cd ${BUILD_NUMBER}
repo init -u ssh://zhouyf6@gerrit.lenovo.com:29418/thinkcloud-sds/manifests -m thinkcloud_sds_tcs_nfvi_centos7.5.xml
repo sync
PROJECT=`echo $GERRIT_PROJECT |cut -d '/' -f2`
cd $PROJECT
git remote set-url origin http://gerrit.lenovo.com/$GERRIT_PROJECT
cd ..

repo download $PROJECT $GERRIT_CHANGE_NUMBER/$GERRIT_PATCHSET_NUMBER
    
# Start build test
./package_on_SH.sh --mode=${BUILD_TYPE} --tag=${TAG} --number=${BUILD_NUMBER}

cd ..
rm -rf ${BUILD_NUMBER}