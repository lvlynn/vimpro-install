#!/bin/bash

linux_system_type=0
need_backup_vim=1
ycm_python_use=3
use_dl_tar_file=0
# 获取日期
function get_datetime()
{
    time=$(date "+%Y%m%d%H%M%S")
    echo $time
}

#配置前先询问
function prepare_ask()
{
    read -n 1 -p "是否备份旧的vim配置? 默认备份 [Y/N] " ch
    if [[ $ch == "N" ]] || [[ $ch == "n" ]]; then
        need_backup_vim=0
    else
        need_backup_vim=1
    fi

#    read  -p "是否使用编译好了的压缩包进行下载安装? 可加快下载速度和安装速度，但不一定兼容，若安装失败可以重新运行本脚本，并选择不使用 默认不使用 [Y/N] " dl
#    if [[ $dl == "Y" ]] || [[ $dl == "y" ]]; then
#        use_dl_tar_file=1
#    fi
    echo -e  "\n"

    read  -p "请选择使用ycm的编译版本。默认使用python3 [2/3]" version
    if [ "$version" == "2" ]; then
        ycm_python_use=2
    fi
    echo -e "\n\n"
}

# 备份原有的vim及配置
function backup_old_vim()
{
    [ "x$need_backup_vim" == "x1" ] && {
        echo "正在备份vim旧配置..."
            mkdir ./vim_bak > /dev/null

            time=$(get_datetime)
            tar -zcPf ./vim_bak/vim_$time.tgz  ~/.vim*
            echo "备份vim旧配置完成!"
        }
    #删除旧配置
    rm -rf ~/.vim*
}


# 获取centos版本
function get_system_version()
{
    version=0
    case $linux_system_type in
        1)
            #ubuntu
            line=$(cat /etc/lsb-release | grep "DISTRIB_RELEASE")
            arr=(${line//=/ })
            version=(${arr[1]//./ })
            version=${version[0]}
            ;;
        2)
            #centos
            version=`cat /etc/redhat-release | awk '{print $4}' | awk -F . '{printf "%s",$1}'`
            ;;
    esac
    echo $version
}

######################################[vim源码 安装函数]###################################################
function check_vim_version()
{
    version=$(vim --version | grep 'Vi IMproved' | cut -d ' ' -f 5 | cut -d '.' -f 1)
    [ "$version" == "" ] && version=0
    echo $version

}

function compile_vim_common()
{
    rm -rf ~/vim82
    git clone https://gitee.com/lahnelin/vim82.git ~/vim82
    cd ~/vim82
    ./configure --with-features=huge \
        --enable-multibyte \
        --enable-rubyinterp \
        --enable-pythoninterp=yes \
        --with-python-config-dir=/usr/lib64/python2.7/config \
        --enable-python3interp=yes \
        --with-python3-config-dir=/usr/lib64/python3.6/config-3.6m-x86_64-linux-gnu \
        --enable-perlinterp \
        --enable-luainterp \
        --enable-tclinterp \
        --enable-gui=gtk2 \
        --enable-cscope \
        --prefix=/usr

    make -j16
    sudo make install

    rm -rf ~/vim82
    cd -
}

# 在ubuntu上源代码安装vim
function compile_vim_on_ubuntu()
{
    version=$(check_vim_version)
    [ $version -lt 8 ] && {

        sudo apt-get install -y libncurses5-dev libncurses5 libgnome2-dev libgnomeui-dev \
        libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
        libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev python3-dev ruby-dev lua5.1 lua5.1-dev

        compile_vim_common
    }
}


# 在centos上源代码安装vim
function compile_vim_on_centos()
{
    version=$(check_vim_version)
    [ $version -lt 8 ] && {
        sudo yum install -y python3-devel  ncurses-devel \
        perl-devel perl-ExtUtils-Embed \
        ruby-devel \
        lua-devel \
        tcl-devel

    compile_vim_common
}
}

#编译astyle
function compile_atyle()
{
    version=$(astyle --version | cut -d ' ' -f 4 | cut -d '.' -f 1 )

    [ "x$version" == "x" ] || [ $version -lt 3 ] && {
        git clone https://gitee.com/lahnelin/vimpro-astyle.git ~/vimpro-astyle
            cd ~/vimpro-astyle/build/gcc
            make -j4
            make install
            cd -
            rm -rf ~/vimpro-astyle
        }
}
######################################[vim源码 安装函数 end]###################################################

######################################[安装必备软件]###################################################
# 安装centos必备软件
function install_prepare_software_on_centos()
{
    version=$(get_system_version)
    if [ $version -ge 8 ];then
        sudo dnf install -y epel-release
        sudo dnf install -y vim ctags automake gcc gcc-c++  make cmake python2  python2-devel python3  python3-devel fontconfig ack git
    else
        #编译ycm用
        sudo yum install -y ctags automake gcc gcc-c++ cmake python-devel python3 python3-devel fontconfig ack git
        compile_vim_on_centos
        compile_atyle
    fi
}

# 安装ubuntu必备软件
function install_prepare_software_on_ubuntu()
{
    sudo apt-get update

    version=$(get_system_version)
    if [ $version -eq 14 ];then
        sudo apt-get install -y cmake3
    else
        sudo apt-get install -y cmake
    fi

    sudo apt-get install -y exuberant-ctags build-essential python python-dev python3-dev fontconfig libfile-next-perl ack-grep git tar

    if [ $version -ge 18 ];then
        sudo apt-get install -y vim
    else
        compile_vim_on_ubuntu
        compile_atyle
    fi
}

#下载php格式工具
function install_php-cs-fixer()
{
    ln -s /home/vimpro/vim/bin/php-cs-fixer /usr/local/bin/php-cs-fixer
}

function begin_install_vimpro
{

    git clone https://gitee.com/lahnelin/vimpro.git /home/vimpro
    ln -s  /home/vimpro/vim ~/.vim
    ln -s  /home/vimpro/vimrc ~/.vimrc
    ln -s  /home/vimpro/vimrc.plugins ~/.vimrc.plugins
    ln -s  /home/vimpro/vimrc.config ~/.vimrc.config
    ln -s  /home/vimpro/vimrc.own.config ~/.vimrc.own.config

    install_ycm
    install_php-cs-fixer
    mkidr ~/vim.swap
}

# 在centos上安装vimpro
function dispatch_linux_distro()
{
    prepare_ask
    case $linux_system_type in
        1)
            #ubuntu
            install_prepare_software_on_ubuntu
            ;;
        2)
            #centos
            install_prepare_software_on_centos
            ;;
    esac

    backup_old_vim
    begin_install_vimpro
}
######################################centos end###################################################



######################################[安装ycm自动补全插件 ycm]###################################################
# 安装ycm插件
function install_ycm()
{
    #    git clone https://gitee.com/lahnelin/YouCompleteMe-clang.git ~/.vim/plugged/YouCompleteMe
    #    /root/vimpro/vim/plugged/YouCompleteMe/third_party/ycmd/ycm_core.so
    #   /root/vimpro/vim/plugged/YouCompleteMe/third_party/ycmd/third_party/cregex/regex_3/_regex.so

    [ ! -f /home/vimpro/vim/plugged/YouCompleteMe/third_party/ycmd/ycm_core.so ] && {
        cd ~/.vim/plugged/YouCompleteMe
            if [[ $ycm_python_use == "2" ]]; then
                echo "Compile ycm with python2."
                python2.7 ./install.py --clang-completer
            else
                echo "Compile ycm with python3."
                python3 ./install.py --clang-completer
            fi
            cd -
        }
}
######################################[安装ycm自动补全插件 end]###################################################



######################################[for common]###################################################
# 获取linux发行版名称
function get_linux_distro()
{
    if grep -Eq "Ubuntu" /etc/*-release; then
        echo "Ubuntu"
    elif grep -Eq "Deepin" /etc/*-release; then
        echo "Deepin"
    elif grep -Eq "LinuxMint" /etc/*-release; then
        echo "LinuxMint"
    elif grep -Eq "elementary" /etc/*-release; then
        echo "elementaryOS"
    elif grep -Eq "Debian" /etc/*-release; then
        echo "Debian"
    elif grep -Eq "Kali" /etc/*-release; then
        echo "Kali"
    elif grep -Eq "CentOS" /etc/*-release; then
        echo "CentOS"
    elif grep -Eq "fedora" /etc/*-release; then
        echo "fedora"
    elif grep -Eq "openSUSE" /etc/*-release; then
        echo "openSUSE"
    elif grep -Eq "Arch Linux" /etc/*-release; then
        echo "ArchLinux"
    elif grep -Eq "ManjaroLinux" /etc/*-release; then
        echo "ManjaroLinux"
    else
        echo "Unknow"
    fi
}


# 在linux平上台安装vimpro
function install_vimpro_on_linux()
{
    distro=`get_linux_distro`
    echo "Linux distro: "${distro}

    if [ ${distro} == "Ubuntu" ]; then
        linux_system_type=1
    elif [ ${distro} == "CentOS" ]; then
        linux_system_type=2
    fi

    if [ "$linux_system_type" == 0 ];then
        echo "Not support linux distro: "${distro}
    else
        dispatch_linux_distro
    fi
}

# 获取当前时间戳
function get_now_timestamp()
{
    cur_sec_and_ns=`date '+%s-%N'`
    echo ${cur_sec_and_ns%-*}
}

# main函数
function main()
{
    begin=`get_now_timestamp`

    type=$(uname)
    echo "Platform type: "${type}

    if [ ${type} == "Darwin" ]; then
        install_vimpro_on_mac
    elif [ ${type} == "Linux" ]; then
        tp=$(uname -a)
        if [[ $tp =~ "Android" ]]; then
            echo "Android"
            install_vimpro_on_android
        else
            install_vimpro_on_linux
        fi
    else
        echo "Not support platform type: "${type}
    fi

end=`get_now_timestamp`
second=`expr ${end} - ${begin}`
min=`expr ${second} / 60`
echo "It takes "${min}" minutes."
}

main
