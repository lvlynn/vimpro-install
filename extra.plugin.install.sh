#!/bin/bash
source common.sh

#是否安装全部语言插件的支持
extra_func_all=0

#是否安装go语言插件的支持
extra_func_go=0
#是否安装JaveScript语言插件的支持
extra_func_js=0
#是否安装java语言插件的支持
extra_func_java=0
#是否安装c#语言插件的支持
extra_func_cs=0
#是否安装rust语言插件的支持
extra_func_rust=0






#配置前先询问
function prepare_ask()
{
    t_bl
	echo "=======================安装前配置========================="

    read  -p "-->请选择使用ycm的编译版本。默认使用python3 [2/3]" version
    if [ "$version" == "2" ]; then
        ycm_python_use=2
    fi
    t_bl

    read   -p "-->是否安装《全语言》自动补全？默认不安装 [y/n]" ch
    if [[ $ch == "Y" ]] || [[ $ch == "y" ]]; then
        extra_func_all=1
    fi

    [ $extra_func_all == 0 ] && {
        t_bl
        read   -p "-->是否安装《go语言》自动补全？默认不安装 [y/n]" ch
        [[ $ch == "Y" ]] || [[ $ch == "y" ]] && extra_func_go=1

        read   -p "-->是否安装《js语言》自动补全？默认不安装 [y/n]" ch
        [[ $ch == "Y" ]] || [[ $ch == "y" ]] && extra_func_js=1

        read   -p "-->是否安装《java语言》自动补全？默认不安装 [y/n]" ch
        [[ $ch == "Y" ]] || [[ $ch == "y" ]] && extra_func_java=1

        read   -p "-->是否安装《c#语言》自动补全？默认不安装 [y/n]" ch
        [[ $ch == "Y" ]] || [[ $ch == "y" ]] && extra_func_cs=1

        read   -p "-->是否安装《rust语言》自动补全？默认不安装 [y/n]" ch
        [[ $ch == "Y" ]] || [[ $ch == "y" ]] && extra_func_rust=1
    }


    t_bl
    t_fl
}

# 安装ycm插件
function install_ycm()
{

    if [ $extra_func_all == 1 ]; then
        install_args="--all-completer"
    else
        
        install_args="--clang-completer"

        [ $extra_func_go == 1 ] && install_args="$install_args --go-completer"
        [ $extra_func_js == 1 ] && install_args="$install_args --ts-completer"
        [ $extra_func_java == 1 ] && install_args="$install_args --java-completer"
        [ $extra_func_cs == 1 ] && install_args="$install_args --cs-completer"
        [ $extra_func_rust == 1 ] && install_args="$install_args --rust-completer"


        if [ $extra_func_js == 1 ]; then
            version=`npm --version | wc -l ` 
            [ $version == 0 ] && {
                echo "启用js自动补全需安装npm，请安装后重试！"
            }

        fi


        echo "-->当前编译选项如下："
        echo "$install_args"

        read   -p "-->请确认是否向下安装YCM？默认安装 [y/n]" ch
        [[ $ch == "N" ]] || [[ $ch == "n" ]] && exit 
    fi

    if [ $extra_func_all == 1 -o $extra_func_go == 1 ]; then
        go_install
    fi

    cd /home/vimpro/vim/plugged/YouCompleteMe
    if [[ $ycm_python_use == "2" ]]; then
        echo "-->Compile ycm with python2."
        python2.7 ./install.py $install_args
    else
        echo "-->Compile ycm with python3."
        python3 ./install.py $install_args
    fi

    cd -
}

prepare_ask
install_ycm
