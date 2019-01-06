Branch="tcs_nfvi_centos7.5"
TAG="2.0.2"
BUILD_TYPE="daily"

tmp_path="/tmp/security_tests/"
unchange_tmp_path="/tmp/unchange_security_tests/"

mkdir ${BUILD_NUMBER}
cd ${BUILD_NUMBER}
repo init -u ssh://zhouyf6@gerrit.lenovo.com:29418/thinkcloud-sds/manifests -m thinkcloud_sds_tcs_nfvi_centos7.5.xml
repo sync
PROJECT=`echo $GERRIT_PROJECT |cut -d '/' -f2`
cd $PROJECT
git remote set-url origin http://gerrit.lenovo.com/$GERRIT_PROJECT
cd ..

repo download $PROJECT $GERRIT_CHANGE_NUMBER/$GERRIT_PATCHSET_NUMBER
    
cd $PROJECT

array2=()
function copy_files() {

	array2=(`git diff HEAD~1 | awk '/diff/ {print $4}'| grep .py | awk -F '/' '{for(i=2;i<NF;i++){printf("%s/", $i);}printf("%s ", $NF)}'`)
    for((i=0;i<${#array2[@]};i++)) do
        echo $tmp_path${array2[i]}
        cp ${array2[i]} $tmp_path
    done;
}
rm -rf $tmp_path
mkdir -p $tmp_path
copy_files

bandit -r $tmp_path | tee /tmp/bandit_result.txt

git reset --hard

function copy_unchange_files() {

    for((i=0;i<${#array2[@]};i++)) do
        echo $unchange_tmp_path${array2[i]}
        cp ${array2[i]} $unchange_tmp_path
    done;
}
rm -rf $unchange_tmp_path
mkdir -p $unchange_tmp_path
copy_unchange_files

bandit -r $unchange_tmp_path | tee /tmp/unchange_bandit_result.txt

diff /tmp/bandit_result.txt /tmp/unchange_bandit_result.txt | tee ${WORKSPACE}/diff_bandit_result.html


array3=(`cat ${WORKSPACE}/diff_bandit_result.html | awk '/High/ {print $3}'`)
sed -i 's|$|<br>|g' ${WORKSPACE}/diff_bandit_result.html

check=true
length=${#array3[@]}
if [[ $length -ne 0 ]]; then
	echo ${array3[1]}
	echo ${array3[0]}
	if [ ${array3[1]} -gt ${array3[0]} ]; then
    	check=false
	fi
fi

echo "check val is" $check


rm -rf $tmp_path
rm -rf $unchange_tmp_path
rm -f /tmp/bandit_result.txt
rm -f /tmp/unchange_bandit_result.txt

cd ..
cd ..
rm -rf ${BUILD_NUMBER}

if [ $check == false ]; then
	echo "Security-bandit check failed!"
    exit 1
else
	echo "Security-bandit check successful!"
    exit 0
fi
