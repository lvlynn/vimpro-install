#!/bin/bash


#提示开始行
function t_sl()
{
	echo "===================开始安装vimpro========================="
}

#提示警告行
function t_jl()
{
	echo "=========================oops!============================"
}



#提示分割行
function t_fl()
{
	echo "=========================================================="
}

#提示空行
function t_bl()
{
	echo  -e -n "\n"
}


function check_vimpro()
{
    [ ! -f /home/vimpro/vimrc ] && {
    t_bl
    t_jl
        echo "vimpro未安装！请使用root身份【执行root.install.sh】安装vimpro。"
    t_fl
    t_bl
            exit
    }

}

function root_install_tips()
{
    t_bl
    t_jl
        echo "root安装vimpro请执行【root.install.sh】"
    t_fl
    t_bl
            exit
}

function go_install()
{
    check_vimpro

	echo "===================正在安装go扩展========================="
    cd /home/vimpro
    git submodule init extra/go
    git submodule update

    [ !  -f /home/vimpro/extra/go/root/bin/go ] && { 
        echo "--> go扩展下载失败，请稍后重试"
        return
    }
    #开启vimrc.plugins中的go插件
    sed -i "s#\"Plug 'Blackrush/vim-gocode'#Plug 'Blackrush/vim-gocode'#" /home/vimpro/vimrc.plugins
    sed -i "s#\"Plug 'fatih/vim-go'#Plug 'fatih/vim-go'#" /home/vimpro/vimrc.plugins

    #设置环境变量
    [ ! -f /etc/profile.d/vim-env.sh ] && echo "" > /etc/profile.d/vim-env.sh

    #sed 对空文件无效
    sed -i '/#!\/bin\/bash/d' /etc/profile.d/vim-env.sh
    sed -i  '1i\\#\!\/bin\/bash' /etc/profile.d/vim-env.sh

    sed -i '/#GOENV/d' /etc/profile.d/vim-env.sh
    sed -i  '$a\##########################GOENV#############################' /etc/profile.d/vim-env.sh
    sed -i  '$a\export GOROOT=/home/vimpro/extra/go/root              #GOENV' /etc/profile.d/vim-env.sh
    sed -i  '$a\export GOPATH=/home/vimpro/extra/go/path              #GOENV' /etc/profile.d/vim-env.sh
    sed -i  '$a\export GOBIN=\$GOROOT/bin                              #GOENV' /etc/profile.d/vim-env.sh
    sed -i  '$a\path_have_go=\`echo \$PATH | grep go\/root | wc -l`      #GOENV' /etc/profile.d/vim-env.sh
    sed -i  '$a\     export PATH=\$PATH:\$GOBIN                         #GOENV' /etc/profile.d/vim-env.sh

    sed -i '/vim-env.sh/d' /etc/profile
    echo ". /etc/profile.d/vim-env.sh">> /etc/profile

    echo "--> go扩展安装成功"
    cd -
#    go env -w GOROOT=/home/vimpro/extra/go/root
#    go env -w GOPATH=/home/vimpro/extra/go/path
#    go env -w GOBIN=$GOROOT/bin
    t_fl
    t_bl
}   

function js_install()
{
    check_vimpro

    echo "===================正在安装node( js,css,html )扩展========================="
    cd /home/vimpro
    git submodule init extra/node
    git submodule update

    [ !  -f /home/vimpro/extra/node/bin/node ] && { 
        echo "--> [node]js扩展下载失败，请稍后重试"
        return
    }

    yum -y remove nodejs
    apt-get -y remove nodejs

    #设置环境变量
    [ ! -f /etc/profile.d/vim-env.sh ] && echo "" > /etc/profile.d/vim-env.sh

    sed -i '/#!\/bin\/bash/d' /etc/profile.d/vim-env.sh
    sed -i  '1i\\#\!\/bin\/bash' /etc/profile.d/vim-env.sh

    sed -i '/#NODEENV/d' /etc/profile.d/vim-env.sh
    sed -i  '$a\############################NODEENV#############################' /etc/profile.d/vim-env.sh
    sed -i  '$a\export NODEBIN=/home/vimpro/extra/node/bin              #NODEENV' /etc/profile.d/vim-env.sh
    sed -i  '$a\path_have_node=\`echo \$PATH | grep node\/bin | wc -l`     #NODEENV' /etc/profile.d/vim-env.sh
    sed -i  '$a\[ $path_have_node == 0 ] &&                             #NODEENV' /etc/profile.d/vim-env.sh
    sed -i  '$a\     export PATH=\$PATH:\$NODEBIN                         #NODEENV' /etc/profile.d/vim-env.sh


    sed -i '/vim-env.sh/d' /etc/profile
    echo ". /etc/profile.d/vim-env.sh">> /etc/profile

    echo "--> node扩展安装成功"
    echo -

    t_fl
    t_bl
}   

function tips_run_source(){
    if [ $extra_func_all == 1 -o $extra_func_js == 1 -o $extra_func_go ]; then
        echo "请执行[ source /etc/profile ] 来启用go和node命令"
    fi
}


#==========================extra function===========================================
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

build_python_use=3

#配置前先询问
function extra_prepare_ask()
{
    t_bl
	echo "=================YouCompleteMe配置==================="

    read  -p "-->请选择python的编译版本。默认使用python3 [2/3]" version
    if [ "$version" == "2" ]; then
        build_python_use=2
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
function extra_install_ycm()
{

    if [ $extra_func_all == 1 ]; then
        install_args="--all"
    else
        
        install_args="--clang-completer"

        [ $extra_func_go == 1 ] && install_args="$install_args --go-completer"
        [ $extra_func_js == 1 ] && install_args="$install_args --ts-completer"
        [ $extra_func_java == 1 ] && install_args="$install_args --java-completer"
        [ $extra_func_cs == 1 ] && install_args="$install_args --cs-completer"
        [ $extra_func_rust == 1 ] && install_args="$install_args --rust-completer"


        echo "-->当前编译选项如下："
        echo "$install_args"

        if [  -f /home/vimpro/vim/plugged/YouCompleteMe/third_party/ycmd/ycm_core.so ]; then
            read   -p "-->请确认是否重新编译YCM？默认编译 [y/n]" ch
            [[ $ch == "N" ]] || [[ $ch == "n" ]] && exit 
        fi
    fi

    if [ $extra_func_all == 1 -o $extra_func_go == 1 ]; then
        go_install
    fi

    if [ $extra_func_all == 1 -o $extra_func_js == 1 ]; then
        js_install
    fi
    
    echo $PATH
    source  /etc/profile
    echo $PATH

    cd /home/vimpro/vim/plugged/YouCompleteMe
    if [[ $build_python_use == "2" ]]; then
        echo "-->Compile ycm with python2."
        python2.7 ./install.py $install_args
    else
        echo "-->Compile ycm with python3."
        python3 ./install.py $install_args
    fi

    cd -
}
#==========================extra function end=======================================

