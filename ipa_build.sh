#使用方法
#证书名
# 这个是去proj文件去搜索
# CODE_SIGN_IDENTITY="iPhone Distribution: Hefei Yougao Technology Co., Ltd. (74PKN5V6V2)"
CODE_SIGN_IDENTITY="iPhone Distribution: Hefei Yougao Technology Co., Ltd."
#描述文件
PROVISIONING_PROFILE_NAME="nero.test_adhoc"


#工程绝对路径
project_path=$(cd `dirname $0`; pwd)
#工程名
project_name="CITest"
#scheme名
scheme_name="CITest"
#build文件夹路径
build_path=${project_path}/build



# info.plist路径
project_infoplist_path="${project_path}/${project_name}/Info.plist"

#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")

#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")
DATE="$(date +%Y%m%d)"

IPAPrefix="${build_path}/${project_name}_V${bundleShortVersion}_${DATE}"
IPANAME="${build_path}/${project_name}_V${bundleShortVersion}_${DATE}.ipa"
echo "----------------------------------buildexportOption--------------------------------------------------------"
#exportOptions文件所在路径 || adhoc
exportOptionsPlistPath=${project_path}/ExportOptionsPlist.plist
function buildOptionforadhoc() {

  #.plist文件里method的取值有app-store、enterprise、ad-hoc、development
  exportOptions="ad-hoc"

  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> ${exportOptionsPlistPath}
  echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"  >> ${exportOptionsPlistPath}
  echo "<plist version=\"1.0\">" >> ${exportOptionsPlistPath}
  echo "<dict>" >> ${exportOptionsPlistPath}
  echo "<key>method</key>" >> ${exportOptionsPlistPath}
  echo "<string>${exportOptions}</string>" >> ${exportOptionsPlistPath}
  echo "<key>compileBitcode</key>" >> ${exportOptionsPlistPath}
  echo "<false/>" >> ${exportOptionsPlistPath}
  echo "</dict>" >> ${exportOptionsPlistPath}

}
function buildOptionforappstore() {

  #.plist文件里method的取值有app-store、enterprise、ad-hoc、development
  exportOptions="app-store"

  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> ${exportOptionsPlistPath}
  echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"  >> ${exportOptionsPlistPath}
  echo "<plist version=\"1.0\">" >> ${exportOptionsPlistPath}
  echo "<dict>" >> ${exportOptionsPlistPath}
  echo "<key>method</key>" >> ${exportOptionsPlistPath}
  echo "<string>${exportOptions}</string>" >> ${exportOptionsPlistPath}
  echo "<key>compileBitcode</key>" >> ${exportOptionsPlistPath}
  echo "<false/>" >> ${exportOptionsPlistPath}
  echo "<key>uploadSymbols</key>" >> ${exportOptionsPlistPath}
  echo "<true/>" >> ${exportOptionsPlistPath}
  echo "</dict>" >> ${exportOptionsPlistPath}

}


function cleanOption() {
  rm -rf ${exportOptionsPlistPath}
}





echo "------------------------------------------------------------------------------------------"
function exportIPA() {
  # 打印scheme
  xcodebuild \
  -list \
  -project ${project_path}/${project_name}.xcodeproj || exit

  #清理工程
  xcodebuild -workspace "${project_name}.xcworkspace" -scheme "${scheme_name}"  -configuration 'Release' clean


  #编译工程
  xcodebuild \
  archive -workspace "${project_name}.xcworkspace" -scheme "${scheme_name}"  \
  CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
  PROVISIONING_PROFILE="${PROVISIONING_PROFILE_NAME}" \
  -archivePath ${build_path}/${project_name}.xcarchive

  # 打包
  # xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
  # -exportOptionsPlist ADHOCExportOptionsPlist.plist \
  # -exportPath ${IPANAME}
  xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
  -exportPath ${IPAPrefix} -exportFormat ipa -exportProvisioningProfile ${PROVISIONING_PROFILE_NAME}

}

echo "------------------------------------------------------------------------------------------"
function publishToFirIm() {

  commit_msg="fir message"
  FirToken="f107a0ed74a1588f48cf2782010c124e"
  fir publish ${IPANAME} -T ${FirToken} -c "${commit_msg}"
}
echo "----------------------------------------------------"
function publishToPGY() {
  #蒲公英上的User Key
  uKey="XX"
  #蒲公英上的API Key
  apiKey="XX"
  #要上传的ipa文件路径




  #执行上传至蒲公英的命令
  echo "++++++++++++++upload+++++++++++++"
  curl -F "file=@${IPANAME}" -F "uKey=${uKey}" -F "_api_key=${apiKey}" http://www.pgyer.com/apiv1/app/upload
}
echo "------------------------------------------------------------------------------------------"
buildOptionforadhoc
exportIPA
cleanOption
if [ -e $IPANAME ]; then
  echo "\n-=-=-=-=-=-=-=\n\n\n"
  echo "Build Success!"
  publishToFirIm

else
  echo "\n-=-=-=-=-=-=-=\n\n"
  echo "error: Create IPA failed!"
fi
