#!/bin/bash
# Script to download google apps and install over adb tcp
#
# Requires:
# - android device is running adb in tcp mode
# - 'adb' binary is available globally (in $PATH)
# - url for gapps zip, default is http://cmw.22aaf3.com/gapps/gapps-ics-20120317-signed.zip
#
# Usage:
# - $ ./install_gapps.sh [device ip] [url of gapps zip]

error(){
  printf "\n\033[31m$*\033[00m\n"
    echo -e "Error: ${1}\n" >> install_gapps.log
}
log(){
    printf "\n\033[32m$*\033[00m\n"
    echo -e "Log: ${1}\n" >> install_gapps.log
}
check_if_ip_specified(){
    device_ip=""
    if [ "${1}" == "" ]
    then
        error "You must specify the IP of your device!\n\nExiting..."
        exit 0
    else
        device_ip="${1}"
        adb connect ${device_ip}
        adb devices
        adb remount
    fi
}
get_gapps(){
    if [[ -f "gapps.zip" ]]
        then
        extract_and_install
    else
        log "Downloading ${1}"
        if curl -C -L "${1}" -o "gapps.zip"
            then
            log "${1} downloaded to gapps.zip"
            extract_and_install
        else
            error "Failed to download ${1} to gapps.zip"
        fi
    fi
}
extract_and_install(){
    log "Extracting..."
    if unzip -o gapps.zip -d "gapps" >> install_gapps.log
        then
            # clean up bits
            cd "${root_dir}"
            rm "gapps/install-optional.sh"
            rm -rf "gapps/META-INF"
            rm -rf "gapps/optional"

            # push files with adb
            push_files "gapps/system/framework" "/system/framework"
            push_files "gapps/system/lib" "/system/lib"
            push_files "gapps/system/etc/permissions" "/system/etc/permissions"
            push_files "gapps/system/app" "/system/app"
    else
        error "Failed to extract gapps.zip"
    fi
}
push_files(){
    push_source="${1}"
    push_target="${2}"
    root_dir="${PWD}"

    cd "${push_source}"
    for file in `ls -1 .`
    do
        log "Pushing ${file} to ${push_target}"
        adb push "${file}" "${push_target}"
    done
    cd $root_dir
}
remove_chinese_apps(){
    log "Do you want to remove any bundled Chinese applications? [y/n]"
    read user_choice
    choice_made="false"
    echo -e "Input: ${user_choice}\n" >> install_gapps.log
    while [[ "${choice_made}" == "false" ]]; do
        case "${user_choice}" in
            "y")
                choice_made="true"
                log "Removing bundled Chinese applications..."

                adb shell rm /system/app/BaiDuShuRuFaPAD.apk
                adb shell rm /system/app/Development.apk
                adb shell rm /system/app/GfanMobile.apk
                adb shell rm /system/app/HaiZhuoLiuLanQiHD.apk
                adb shell rm /system/app/KuaiTuLiuLan.apk
                adb shell rm /system/app/KuWoYinYueHD.apk
                adb shell rm /system/app/OuPengLiuLanQi.apk
                adb shell rm /system/app/QQ.apk
                adb shell rm /system/app/UCBrowser.apk
                adb shell rm /system/app/ZuiHouDeFangXianHD.apk
                adb shell rm /system/app/ESRenWuGuanLiQi.apk
                adb shell rm /system/app/ESWenJianLiuLanQi.apk
                adb shell rm /system/app/CifsManager.apk
                adb shell rm /system/app/BaiduInputPad.apk
                adb shell rm /system/app/ShuiGuoFenZhe.apk
                adb shell rm /system/app/AngryBirdsRio.apk
                adb shell rm /system/app/PinyinIME.apk
                adb shell rm /system/app/ONDA_v2.3.apk
                adb shell rm /system/preinstall/AnZhi_Onda_Pad_VER_3_1.apk
                adb shell rm /system/preinstall/cn.com.fetion_125377.apk
                adb shell rm /system/preinstall/com.jingdong.app.mall_122408
                adb shell rm /system/preinstall/com.qq.reader_119302.apk
                adb shell rm /system/preinstall/com.youdao.dict_152975.apk
                adb shell rm /system/preinstall/meituxiuxiu.apk
                adb shell rm /system/preinstall/MSN7.apk
                adb shell rm /system/preinstall/onda_73_0.7.2.1_v1845.apk
                adb shell rm /system/preinstall/PPTV.apk
                adb shell rm /system/preinstall/QQgame.apk
                adb shell rm /system/preinstall/QQHD_mini_v1.6.apk
                adb shell rm /system/preinstall/sina_weibo.apk
                adb shell rm /system/preinstall/UCBrowser.apk
                adb shell rm /system/preinstall/wangyixinwen.apk
                adb shell rm /system/preinstall/WeiXin.apk
                adb shell rm /system/preinstall/WPS_Office_4.3.1.apk
                adb shell rm /system/preinstall/youxididai.apk

                log "All bundled Chinese applications removed!"
            ;;
            "n")
                choice_made="true"
                log "Okay then, we'll keep any bundled Chinese applications"
            ;;
            *)
                error "Please enter 'y' or 'n'"
                read user_choice
                echo -e "Input: ${user_choice}\n" >> install_gapps.log
            ;;
        esac
    done
}
finish_up(){    
    log "All done!"
    log "Please reboot your device"
}

check_if_ip_specified "${1}"
if [ "${2}" == "" ]
    then
    gapps_url="http://cmw.22aaf3.com/gapps/gapps-ics-20120317-signed.zip"
    if [[ -f "gapps.zip" ]]
        then
        log "No gapps url specified, but local gapps.zip found!"
    else
        log "No gapps url specified, using default: ${gapps_url}"
    fi
else
    gapps_url="${2}"
    log "Using gapps url: ${gapps_url}"
fi
date > install_gapps.log
get_gapps "${gapps_url}"
remove_chinese_apps
finish_up