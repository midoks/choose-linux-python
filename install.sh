#!/bin/bash

## Author: midoks
## Modified: 2023-06-12
## License: Apache License
## Github: https://github.com/midoks/choose-linux-python

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PLAIN='\033[0m'
BOLD='\033[1m'
SUCCESS='[\033[32mOK\033[0m]'
COMPLETE='[\033[32mDONE\033[0m]'
WARN='[\033[33mWARN\033[0m]'
ERROR='[\033[31mERROR\033[0m]'
WORKING='[\033[34m*\033[0m]'

DebianVersion=/etc/debian_version
DebianSourceList=/etc/apt/sources.list
DebianSourceListBackup=/etc/apt/sources.list.bak
DebianExtendListDir=/etc/apt/sources.list.d
DebianExtendListDirBackup=/etc/apt/sources.list.d.bak

SYSTEM_UBUNTU="Ubuntu"
SYSTEM_DEBIAN="Debian"

LinuxRelease=/etc/os-release
RedHatRelease=/etc/redhat-release

ARCH=$(uname -m)

SYSTEM_NAME=$(cat $LinuxRelease | grep -E "^NAME=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")
SYSTEM_VERSION_NUMBER=$(cat /etc/os-release | grep -E "VERSION_ID=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")
SOURCE_BRANCH=${SYSTEM_JUDGMENT,,}


declare -A PY_VERSION

PY_VERSION["3.10.10"]="3.10.10"
PY_VERSION["3.11.3"]="3.10.3"

SOURCE_LIST_KEY_SORT_TMP=$(echo ${!PY_VERSION[@]} | tr ' ' '\n' | sort -n)
SOURCE_LIST_KEY=(${SOURCE_LIST_KEY_SORT_TMP//'\n'/})
SOURCE_LIST_LEN=${#PY_VERSION[*]}


## 环境判定
function PermissionJudgment() {
    ## 权限判定
    if [ $UID -ne 0 ]; then
        echo -e "\n$ERROR 权限不足，请使用 Root 用户\n"
        exit
    fi
}

## 系统判定变量
function EnvJudgment() {
    ## 判定系统处理器架构
    case ${ARCH} in
    x86_64)
        SYSTEM_ARCH="x86_64"
        ;;
    aarch64)
        SYSTEM_ARCH="ARM64"
        ;;
    armv7l)
        SYSTEM_ARCH="ARMv7"
        ;;
    armv6l)
        SYSTEM_ARCH="ARMv6"
        ;;
    i686)
        SYSTEM_ARCH="x86_32"
        ;;
    *)
        SYSTEM_ARCH=${ARCH}
        ;;
    esac

    SYSTEM_JUDGMENT=$(cat $RedHatRelease | sed 's/ //g' | cut -c1-6)
    if [[ ${SYSTEM_JUDGMENT} = ${SYSTEM_CENTOS} || ${SYSTEM_JUDGMENT} = ${SYSTEM_RHEL} ]]; then
        CENTOS_VERSION=$(echo ${SYSTEM_VERSION_NUMBER} | cut -c1)
    else
        CENTOS_VERSION=""
    fi
}

function AutoSizeStr(){
	NAME_STR=$1
	NAME_NUM=$2

	NAME_STR_LEN=`echo "$NAME_STR" | wc -L`
	NAME_NUM_LEN=`echo "$NAME_NUM" | wc -L`

	fix_len=35
	remaining_len=`expr $fix_len - $NAME_STR_LEN - $NAME_NUM_LEN`
	FIX_SPACE=' '
	for ((ass_i=1;ass_i<=$remaining_len;ass_i++))
	do 
		FIX_SPACE="$FIX_SPACE "
	done
	echo -e " ❖   ${1}${FIX_SPACE}${2})"
}

function ChooseVersion(){
	clear
    echo -e '+---------------------------------------------------+'
    echo -e '|                                                   |'
    echo -e '|   =============================================   |'
    echo -e '|                                                   |'
    echo -e '|       欢迎使用 Linux 一键安装Python源码版本       |'
    echo -e '|                                                   |'
    echo -e '|   =============================================   |'
    echo -e '|                                                   |'
    echo -e '+---------------------------------------------------+'
    echo -e ''
    echo -e '#####################################################'
    echo -e ''
    echo -e '            提供以下版本可供选择：'
    echo -e ''
    echo -e '#####################################################'
    echo -e ''
    cm_i=0
    for V in ${SOURCE_LIST_KEY[@]}; do
    num=`expr $cm_i + 1`
	AutoSizeStr "${V}" "$num"
	cm_i=`expr $cm_i + 1`
	done
    echo -e ''
    echo -e '#####################################################'
    echo -e ''
    echo -e "        运行环境  ${BLUE}${SYSTEM_NAME} ${SYSTEM_VERSION_NUMBER} ${SYSTEM_ARCH}${PLAIN}"
    echo -e "        系统时间  ${BLUE}$(date "+%Y-%m-%d %H:%M:%S")${PLAIN}"
    echo -e ''
    echo -e '#####################################################'
    CHOICE_A=$(echo -e "\n${BOLD}└─ 请选择并输入你想使用的软件版本 [ 1-${SOURCE_LIST_LEN} ]：${PLAIN}")

    read -p "${CHOICE_A}" INPUT
    echo $INPUT

    if [ "$INPUT" == "" ];then
        INPUT=1
        TMP_INPUT=`expr $INPUT - 1`
        INPUT_KEY=${SOURCE_LIST_KEY[$TMP_INPUT]}
        echo -e "\n 默认选择[${BLUE}${INPUT_KEY}${PLAIN}]安装！"
    fi

    INPUT=`expr $INPUT - 1`
    INPUT_KEY=${SOURCE_LIST_KEY[$INPUT]}
    CHOICE_VERSION=${PY_VERSION[$INPUT_KEY]}
}

function DownloadFile(){

	url="https://www.python.org/ftp/python/${CHOICE_VERSION}/Python-${CHOICE_VERSION}.tar.xz"
	echo $url
	tmp_file=/tmp/Python-${CHOICE_VERSION}.tar.xz
	if [ ! -f $tmp_file ];then
		wget -O $tmp_file $url
	fi

	cd /tmp
	if [ ! -d /tmp/Python-${CHOICE_VERSION} ];then
		tar -xvJf Python-${CHOICE_VERSION}.tar.xz
	fi

	mkdir python-build
	cd python-build

	/tmp/Python-${CHOICE_VERSION}/configure --prefix=/usr/local/python${CHOICE_VERSION} \
		--enable-optimizations \
		--with-openssl-rpath=auto  \
		--with-openssl=/usr/include/openssl  \
		OPENSSL_LDFLAGS=-L/usr/include/openssl  \
		OPENSSL_LIBS=-l/usr/include/openssl/ssl \
		OPENSSL_INCLUDES=-I/usr/include/openssl 

	make -j2
	make install
}

function RunMain(){
	EnvJudgment
	PermissionJudgment
	ChooseVersion
    DownloadFile
    # InstallScript
    # RemoveScript
    # AuthorMessage
}
# 执行
RunMain