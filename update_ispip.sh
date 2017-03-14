#!/bin/sh
#检查是否已经存在chinaip
basepath=$(cd `dirname $0`; pwd)
#echo "当前目录：$basepath"

chinaip=$(ipset list -n|grep chinaip)
cmcc=$(ipset list -n|grep cmcc)
telecom=$(ipset list -n|grep telecom)
unicom=$(ipset list -n|grep unicom)

update_chinaip() {
	if [ -z $chinaip ]; then
		echo "添加chinaip IPSET Name"
		ipset create chinaip hash:net hashsize 8192
	else
		echo "清空chinaip IPSET List"
		ipset flush chinaip
	fi
	
	echo "下载chinaip列表..."
	wget -q --no-check_certificate https://github/monokoo/mwan3/chinaip -O $basepath/chinaip

	[ -f "$basepath/chinaip" ] && { 
		echo "开始添加chinaip IPSET List,请稍候..."
		source $basepath/chinaip
	}
	if [ "$?" == "0" ]; then
		echo "添加chinaip IPSET列表成功"
	else
		echo "添加chinaip IPSET列表失败，请重试！"
	fi
}

update_cmcc() {
	if [ -z $cmcc ]; then
	        echo "添加cmcc IPSET Name"
	        ipset create cmcc hash:net hashsize 1024
	else
	        echo "清空cmcc IPSET List"
	        ipset flush cmcc
	fi
	
	echo "下载cmcc列表..."
	wget -q --no-check_certificate https://github/monokoo/mwan3/cmcc -O $basepath/cmcc
	
	[ -f "$basepath/cmcc" ] && {
	        echo "开始添加cmcc IPSET List,请稍候..."
		source $basepath/cmcc
	}
	if [ "$?" == "0" ]; then
	        echo "添加cmcc IPSET列表成功"
	else
	        echo "添加cmcc IPSET列表失败，请重试！"
	fi
}

update_telecom() {
	if [ -z $telecom ]; then
	        echo "添加telecom IPSET Name"
	        ipset create telecom hash:net hashsize 2048
	else
	        echo "清空telecom IPSET List"
	        ipset flush telecom
	fi

	echo "下载telecom列表..."
	wget -q --no-check_certificate https://github/monokoo/mwan3/telecom -O $basepath/telecom

	[ -f "$basepath/telecom" ] && {
		echo "开始添加telecom IPSET List,请稍候..."
		source $basepath/telecom
	}
	if [ "$?" == "0" ]; then
		echo "添加telecom IPSET列表成功"
	else
		echo "添加telecom IPSET列表失败，请重试！"
	fi
}

update_unicom() {
	if [ -z $unicom ]; then
	        echo "添加unicom IPSET Name"
	        ipset create unicom hash:net hashsize 1024
	else
	        echo "清空unicom IPSET List"
	        ipset flush unicom
	fi

	echo "下载unicom列表..."
	wget -q --no-check_certificate https://github/monokoo/mwan3/unicom -O $basepath/unicom

	[ -f "$basepath/unicom" ] && {
		echo "开始添加unicom IPSET List,请稍候..."
		source $basepath/unicom
	}
	if [ "$?" == "0" ]; then
		echo "添加unicom  IPSET列表成功"
	else
		echo "添加unicom  IPSET列表失败，请重试！"
	fi
}

del_selfipset() {
	if [ -n "$chinaip" ]; then
		ipset destroy chinaip
	fi
	if [ -n "$cmcc" ]; then
		ipset destroy cmcc
	fi
	if [ -n "$telecom" ]; then
		ipset destroy telecom
	fi
	if [ -n "$unicom" ]; then
		ipset destroy unicom
	fi
}

help()
{
echo "Available commands:       
		update <setname>   {chinaip|cmcc|telecom|unicom}  
		         	      Create the specified ipset.        
		del                Delete all selfipset"
}
[  -z $1 ]
case $1 in
	update)
		case $2 in
			chinaip)
				update_chinaip
			;;
			cmcc)
				update_cmcc
			;;
			telecom)
				update_telecom
			;;
			unicom)
				update_unicom
			;;
			*)
				echo "Arguments error! [$1]"
				echo "Usage: ./`basename $0` $1 {chinaip|cmcc|telecom|unicom}"
			;;
				
		esac
	;;
	del)
		del_selfipset
	;;
	*)
		help
	;;
esac
