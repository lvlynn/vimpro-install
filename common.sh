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
    echo "#!/bin/bash
    
export GOROOT=/home/vimpro/extra/go/root
export GOPATH=/home/vimpro/extra/go/path
export GOBIN=\$GOROOT/bin
    
path_have_go=`echo \$PATH | grep go\/root | wc -l`
[ \$path_have_go == 0 ] && 
    export PATH=\$PATH:\$GOBIN" > /etc/profile.d/vim-go.sh

    sed -i '/vim-go.sh/d' /etc/profile
    echo ". /etc/profile.d/vim-go.sh">> /etc/profile

    echo "--> go扩展安装成功"
#    go env -w GOROOT=/home/vimpro/extra/go/root
#    go env -w GOPATH=/home/vimpro/extra/go/path
#    go env -w GOBIN=$GOROOT/bin
    t_fl
    t_bl
}   


