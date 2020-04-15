#!/bin/bash

function check_vimpro()
{
    [ ! -f /home/vimpro/vimrc ] && {
        echo "vimpro未安装，请使用root安装vimpro"
            exit
    }

}

function re_ask()
{
    #test_label
    read  -p "请选择要安装的用户。默认为$USER。 " usr

    if [ "$usr" == "" ]; then
        U=$USER
    else
        U=$usr
    fi

    if [  "$U"  == "root" ]; then
        install_path="/root"
    else

        if [ ! -d "/home/$U" ]; then
            echo  -e "/home/$U目录不存在，请重新选择!\n"
            re_ask
        fi

        install_path="/home/$U"
    fi
    echo -e "\n"
}

function remove_old_config()
{
    rm -f -r $install_path/.vim 
    rm -f -r $install_path/vim.swap
    rm -f -r $install_path/.vimrc* 
}

function install_new_config()
{
    ln -s  /home/vimpro/vim $install_path/.vim
    ln -s  /home/vimpro/vimrc $install_path/.vimrc
    ln -s  /home/vimpro/vimrc.plugins $install_path/.vimrc.plugins
    ln -s  /home/vimpro/vimrc.config $install_path/.vimrc.config
    cp  /home/vimpro/vimrc.own.config $install_path/.vimrc.own.config
    mkdir $install_path/vim.swap
}

check_vimpro
re_ask
remove_old_config
install_new_config
