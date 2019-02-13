#!/bin/sh
#检查是否已经存在chinaip
basepath=$(cd `dirname $0`; pwd)
#echo "当前目录：$basepath"

chinaip=$(ipset list -n|grep chinaip)
cmcc=$(ipset list -n|grep cmcc)
telecom=$(ipset list -n|grep telecom)
unicom=$(ipset list -n|grep unicom)

selfipset_path="/usr/share/selfipset"
[ ! -d "/usr/share/selfipset" ] && mkdir -p /usr/share/selfipset

add_ipset(){
    ipset_name=$1
    ipset_file=$2
    sed -e "s/^/add $ipset_name &/g" $ipset_file | awk '{print $0} END{print "COMMIT"}' | ipset -R
    [ -z "$(cat /etc/sysupgrade.conf | grep -w selfipset)" ] && sed -i "\$a\\$selfipset_path" /etc/sysupgrade.conf
}

update_chinaip() {
	echo "下载chinaip列表..."
	wget --no-check-certificate https://ispip.clang.cn/all_cn_cidr.txt -O $basepath/chinaip
    
	if [ -z $chinaip ]; then
		echo "添加chinaip IPSET Name"
		ipset create chinaip hash:net hashsize 8192
	else
		echo "清空chinaip IPSET List"
		ipset flush chinaip
	fi    

	[ -f "$basepath/chinaip" ] && { 
		echo "开始添加chinaip IPSET List,请稍候..."
		add_ipset chinaip $basepath/chinaip
	}
	if [ "$?" == "0" ]; then
		echo "添加chinaip IPSET列表成功"
        ipset save chinaip -f $selfipset_path/chinaip        
        [ -z $(cat /etc/rc.local | grep -w chinaip) ] && sed -i "/exit 0/i\ipset restore -f $selfipset_path/chinaip" /etc/rc.local
	else
		echo "添加chinaip IPSET列表失败，请重试！"
	fi
    rm -f $basepath/chinaip
}

update_cmcc() {
	echo "下载cmcc列表..."
	wget --no-check-certificate https://ispip.clang.cn/cmcc_cidr.txt -O $basepath/cmcc_cidr.txt
    wget --no-check-certificate https://ispip.clang.cn/crtc_cidr.txt -O $basepath/crtc_cidr.txt
    
    cat $basepath/cmcc_cidr.txt $basepath/crtc_cidr.txt > $basepath/cmcc
    
	if [ -z $cmcc ]; then
	        echo "添加cmcc IPSET Name"
	        ipset create cmcc hash:net hashsize 1024
	else
	        echo "清空cmcc IPSET List"
	        ipset flush cmcc
	fi
	
	[ -f "$basepath/cmcc" ] && {
	        echo "开始添加cmcc IPSET List,请稍候..."
		add_ipset cmcc $basepath/cmcc
	}
	if [ "$?" == "0" ]; then
	        echo "添加cmcc IPSET列表成功"
            ipset save cmcc -f $selfipset_path/cmcc        
            [ -z $(cat /etc/rc.local | grep -w cmcc) ] && sed -i "/exit 0/i\ipset restore -f $selfipset_path/cmcc" /etc/rc.local            
	else
	        echo "添加cmcc IPSET列表失败，请重试！"
	fi
    rm -f $basepath/cmcc_cidr.txt $basepath/crtc_cidr.txt $basepath/cmcc
}

update_telecom() {
	echo "下载telecom列表..."
	wget --no-check-certificate https://ispip.clang.cn/chinatelecom_cidr.txt -O $basepath/telecom
    
	if [ -z $telecom ]; then
	        echo "添加telecom IPSET Name"
	        ipset create telecom hash:net hashsize 2048
	else
	        echo "清空telecom IPSET List"
	        ipset flush telecom
	fi

	[ -f "$basepath/telecom" ] && {
		echo "开始添加telecom IPSET List,请稍候..."
		add_ipset telecom $basepath/telecom
	}
	if [ "$?" == "0" ]; then
		echo "添加telecom IPSET列表成功"
        ipset save telecom -f $selfipset_path/telecom        
        [ -z $(cat /etc/rc.local | grep -w telecom) ] && sed -i "/exit 0/i\ipset restore -f $selfipset_path/telecom" /etc/rc.local        
	else
		echo "添加telecom IPSET列表失败，请重试！"
	fi
    rm -f $basepath/telecom
}

update_unicom() {
	echo "下载unicom列表..."
	wget --no-check-certificate https://ispip.clang.cn/unicom_cnc_cidr.txt -O $basepath/unicom
    
	if [ -z $unicom ]; then
	        echo "添加unicom IPSET Name"
	        ipset create unicom hash:net hashsize 1024
	else
	        echo "清空unicom IPSET List"
	        ipset flush unicom
	fi

	[ -f "$basepath/unicom" ] && {
		echo "开始添加unicom IPSET List,请稍候..."
		add_ipset unicom $basepath/unicom
	}
	if [ "$?" == "0" ]; then
		echo "添加unicom  IPSET列表成功"
        ipset save unicom -f $selfipset_path/unicom
        [ -z $(cat /etc/rc.local | grep -w unicom) ] && sed -i "/exit 0/i\ipset restore -f $selfipset_path/unicom" /etc/rc.local
	else
		echo "添加unicom  IPSET列表失败，请重试！"
	fi
    rm -f $basepath/unicom
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
