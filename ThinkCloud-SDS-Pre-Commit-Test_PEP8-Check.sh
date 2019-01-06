Branch="tcs_nfvi_centos7.5"
TAG="2.0.2"
BUILD_TYPE="daily"

tmp_path="/tmp/pep8_tests/"

mkdir ${BUILD_NUMBER}
cd ${BUILD_NUMBER}
repo init -u ssh://zhouyf6@gerrit.lenovo.com:29418/thinkcloud-sds/manifests -m thinkcloud_sds_tcs_nfvi_centos7.5.xml
repo sync
PROJECT=`echo $GERRIT_PROJECT |cut -d '/' -f2`
cd $PROJECT
git remote set-url origin http://gerrit.lenovo.com/$GERRIT_PROJECT
cd ..

repo download $PROJECT $GERRIT_CHANGE_NUMBER/$GERRIT_PATCHSET_NUMBER
    

function copy_files() {

	array1=(`git diff HEAD~1 | awk '/diff/ {print $4}'| grep .py | awk -F '/' '{for(i=2;i<NF;i++){printf("%s/", $i);}printf("%s ", $NF)}'`)
    for((i=0;i<${#array1[@]};i++)) do
        echo $tmp_path${array1[i]}
        cp ${array1[i]} $tmp_path
    done;
}

cd $PROJECT

rm -rf $tmp_path
mkdir -p $tmp_path
copy_files

pycodestyle --ignore=E501,E228,E226,E261,E266,E128,E402,W503 $tmp_path. | tee ${WORKSPACE}/pep8_result.html

array2=(`cat ${WORKSPACE}/pep8_result.html`)

sed -i 's|$|<br>|g' ${WORKSPACE}/pep8_result.html

check=true
if [ ${#array2[@]} -gt 0 ]; then
    check=false
fi
echo "check val is "$check

rm -rf $tmp_path

cd ..
cd ..
pwd
rm -rf ${BUILD_NUMBER}

if [ $check == false ]; then
    echo "PEP8 check failed!"
    exit 1
else
    echo "PEP8 check successful!"
    exit 0
fi    


