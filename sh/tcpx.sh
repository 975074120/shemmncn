#!/usr/bin/env bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================
#	System Required: CentOS 7/8,Debian/ubuntu,oraclelinux
#	Description: BBR+BBRplus+Lotserver
#	Version: 100.0.4.15
#	Author: 千影,cx9208,YLX
#	更新内容及反馈:  https://blog.ylx.me/archives/783.html
#=================================================

# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[0;33m'
# SKYBLUE='\033[0;36m'
# PLAIN='\033[0m'

sh_ver="100.0.4.15"
github="raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master"

imgurl=""
headurl=""
github_network=1

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

if [ -f "/etc/sysctl.d/bbr.conf" ]; then
	rm -rf /etc/sysctl.d/bbr.conf
fi

# 检查当前用户是否为 root 用户
if [ "$EUID" -ne 0 ]; then
	echo "请使用 root 用户身份运行此脚本"
	exit
fi

#优化系统配置
optimizing_system_old() {
	if [ ! -f "/etc/sysctl.d/99-sysctl.conf" ]; then
		touch /etc/sysctl.d/99-sysctl.conf
	fi
	sed -i '/net.ipv4.tcp_retries2/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.conf
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf

	echo "net.ipv4.tcp_retries2 = 8
net.ipv4.tcp_slow_start_after_idle = 0
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
#net.ipv4.ip_forward = 1" >>/etc/sysctl.d/99-sysctl.conf
	sysctl -p
	echo "*               soft    nofile           1000000
*               hard    nofile          1000000" >/etc/security/limits.conf
	echo "ulimit -SHn 1000000" >>/etc/profile
	read -p "需要重启VPS后，才能生效系统优化配置，是否现在重启 ? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} VPS 重启中..."
		reboot
	fi
}

optimizing_system_johnrosen1() {
	if [ ! -f "/etc/sysctl.d/99-sysctl.conf" ]; then
		touch /etc/sysctl.d/99-sysctl.conf
	fi
	sed -i '/net.ipv4.tcp_fack/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_early_retrans/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.neigh.default.unres_qlen/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.netfilter.nf_conntrack_buckets/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/kernel.pid_max/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/vm.nr_hugepages/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.optmem_max/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.all.route_localnet/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.all.forwarding/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.default.forwarding/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.all.forwarding/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.default.forwarding/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.lo.forwarding/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.all.accept_ra/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.default.accept_ra/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.netdev_budget/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.netdev_budget_usecs/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/fs.file-max /d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.rmem_max/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.wmem_max/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.rmem_default/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.wmem_default/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.icmp_echo_ignore_all/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.icmp_echo_ignore_broadcasts/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.icmp_ignore_bogus_error_responses/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.all.accept_redirects/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.default.accept_redirects/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.all.secure_redirects/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.default.secure_redirects/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.all.send_redirects/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.default.send_redirects/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.default.rp_filter/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.all.rp_filter/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_keepalive_intvl/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_keepalive_probes/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_rfc1337/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.udp_rmem_min/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.udp_wmem_min/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.all.arp_ignore /d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.default.arp_ignore/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.all.arp_announce/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.conf.default.arp_announce/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_autocorking/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_notsent_lowat/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_no_metrics_save/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_ecn_fallback/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_frto/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.all.accept_redirects/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.default.accept_redirects/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/vm.swappiness/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.ip_unprivileged_port_start/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/vm.overcommit_memory/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.neigh.default.gc_thresh3/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.neigh.default.gc_thresh2/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.neigh.default.gc_thresh1/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.neigh.default.gc_thresh3/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.neigh.default.gc_thresh2/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.neigh.default.gc_thresh1/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.netfilter.nf_conntrack_max/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.nf_conntrack_max/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.netfilter.nf_conntrack_tcp_timeout_fin_wait/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.netfilter.nf_conntrack_tcp_timeout_time_wait/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.netfilter.nf_conntrack_tcp_timeout_close_wait/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.netfilter.nf_conntrack_tcp_timeout_established/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/fs.inotify.max_user_watches/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_low_latency/d' /etc/sysctl.d/99-sysctl.conf

	cat >'/etc/sysctl.d/99-sysctl.conf' <<EOF
net.ipv4.tcp_fack = 1
net.ipv4.tcp_early_retrans = 3
net.ipv4.neigh.default.unres_qlen=10000  
net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.default.forwarding = 1
#net.ipv6.conf.all.forwarding = 1  #awsipv6问题
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.lo.forwarding = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2
net.core.netdev_max_backlog = 100000
net.core.netdev_budget = 50000
net.core.netdev_budget_usecs = 5000
#fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 67108864
net.core.wmem_default = 67108864
net.core.optmem_max = 65536
net.core.somaxconn = 1000000
net.ipv4.icmp_echo_ignore_all = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 2
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 0
net.ipv4.tcp_fin_timeout = 15
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_autocorking = 0
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_max_syn_backlog = 819200
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_no_metrics_save = 0
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_ecn_fallback = 1
net.ipv4.tcp_frto = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv4.neigh.default.gc_thresh2=4096
net.ipv4.neigh.default.gc_thresh1=2048
net.ipv6.neigh.default.gc_thresh3=8192
net.ipv6.neigh.default.gc_thresh2=4096
net.ipv6.neigh.default.gc_thresh1=2048
net.ipv4.tcp_orphan_retries = 1
net.ipv4.tcp_retries2 = 5
vm.swappiness = 1
vm.overcommit_memory = 1
kernel.pid_max=64000
net.netfilter.nf_conntrack_max = 262144
net.nf_conntrack_max = 262144
## Enable bbr
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_low_latency = 1
EOF
	sysctl -p
	sysctl --system
	echo always >/sys/kernel/mm/transparent_hugepage/enabled

	cat >'/etc/systemd/system.conf' <<EOF
[Manager]
#DefaultTimeoutStartSec=90s
DefaultTimeoutStopSec=30s
#DefaultRestartSec=100ms
DefaultLimitCORE=infinity
DefaultLimitNOFILE=infinity
DefaultLimitNPROC=infinity
DefaultTasksMax=infinity
EOF

	cat >'/etc/security/limits.conf' <<EOF
root     soft   nofile    1000000
root     hard   nofile    1000000
root     soft   nproc     unlimited
root     hard   nproc     unlimited
root     soft   core      unlimited
root     hard   core      unlimited
root     hard   memlock   unlimited
root     soft   memlock   unlimited
*     soft   nofile    1000000
*     hard   nofile    1000000
*     soft   nproc     unlimited
*     hard   nproc     unlimited
*     soft   core      unlimited
*     hard   core      unlimited
*     hard   memlock   unlimited
*     soft   memlock   unlimited
EOF

	sed -i '/ulimit -SHn/d' /etc/profile
	sed -i '/ulimit -SHu/d' /etc/profile
	echo "ulimit -SHn 1000000" >>/etc/profile

	if grep -q "pam_limits.so" /etc/pam.d/common-session; then
		:
	else
		sed -i '/required pam_limits.so/d' /etc/pam.d/common-session
		echo "session required pam_limits.so" >>/etc/pam.d/common-session
	fi
	systemctl daemon-reload
	echo -e "${Info}优化方案2应用结束，可能需要重启！"
}

#处理传进来的参数 直接优化
err() {
	echo "错误: $1"
	exit 1
}

while [ $# -gt 0 ]; do
	case $1 in
	op0)
		optimizing_system_old # 调用函数
		exit
		;;
	op1)
		optimizing_system_johnrosen1 # 调用函数
		exit
		;;
	op2)
		update_sysctl_interactive # 调用函数
		exit
		;;
	op3)
		etit_sysctl_interactive # 调用函数
		exit
		;;
	*)
		err "未知选项: \"$1\""
		;;
	esac
	shift # 移动到下一个参数
done

# 检查github网络
check_github() {
	# 检测域名的可访问性函数
	check_domain() {
		local domain="$1"
		if ! curl --max-time 5 --head --silent --fail "$domain" >/dev/null; then
			echo -e "${Error}无法访问 $domain，请检查网络或者本地DNS 或者访问频率过快而受限"
			github_network=0
		fi
	}

	# 检测所有域名的可访问性
	check_domain "https://raw.githubusercontent.com"
	check_domain "https://api.github.com"
	check_domain "https://github.com"

	if [ "$github_network" -eq 0 ]; then
		echo -e "${Error}github网络访问受限，将影响内核的安装以及脚本的检查更新，1秒后继续运行脚本"
		sleep 1
	else
		# 所有域名均可访问，打印成功提示
		echo -e "${Green_font_prefix}github可访问${Font_color_suffix}，继续执行脚本..."
	fi
}

#检查连接
checkurl() {
	local url="$1"
	local maxRetries=3
	local retryDelay=2

	if [[ -z "$url" ]]; then
		echo "错误：缺少URL参数！"
		exit 1
	fi

	local retries=0
	local responseCode=""

	while [[ -z "$responseCode" && $retries -lt $maxRetries ]]; do
		responseCode=$(curl --max-time 6 -s -L -m 10 --connect-timeout 5 -o /dev/null -w "%{http_code}" "$url")

		if [[ -z "$responseCode" ]]; then
			((retries++))
			sleep $retryDelay
		fi
	done

	if [[ -n "$responseCode" && ("$responseCode" == "200" || "$responseCode" =~ ^3[0-9]{2}$) ]]; then
		echo "下载地址检查OK，继续！"
	else
		echo "下载地址检查出错，退出！"
		exit 1
	fi
}

#cn处理github加速
check_cn() {
	# 检查是否安装了jq命令，如果没有安装则进行安装
	if ! command -v jq >/dev/null 2>&1; then
		if command -v yum >/dev/null 2>&1; then
			sudo yum install epel-release -y
			sudo yum install -y jq
		elif command -v apt-get >/dev/null 2>&1; then
			sudo apt-get update
			sudo apt-get install -y jq
		else
			echo "无法安装jq命令。请手动安装jq后再试。"
			exit 1
		fi
	fi

	# 获取当前IP地址，设置超时为3秒
	#current_ip=$(curl -s --max-time 3 https://ip.im -4)

	# 使用ip-api.com查询IP所在国家，设置超时为3秒
	response=$(curl -s --max-time 3 ip.im/info -4 | sed -n '/CountryCode/s/.*://p')

	# 检查国家是否为中国
	country=$(echo "$response" | jq -r '.countryCode')
	if [[ "$country" == "CN" ]]; then
		local suffixes=(
			"https://gh-proxy.com/"
			"https://ghfast.top"
			"https://down.npee.cn/?"
			"https://hub.gitmirror.com/"
			"https://gh.ddlc.top/"
		)

		# 循环遍历每个后缀并测试组合的链接
		for suffix in "${suffixes[@]}"; do
			# 组合后缀和原始链接
			combined_url="$suffix$1"

			# 使用 curl -I 获取头部信息，提取状态码
			local response_code=$(curl --max-time 2 -sL -w "%{http_code}" -I "$combined_url" | head -n 1 | awk '{print $2}')

			# 检查响应码是否表示成功 (2xx)
			if [[ $response_code -ge 200 && $response_code -lt 300 ]]; then
				echo "$combined_url"
				return 0 # 返回可用链接，结束函数
			fi
		done

	# 如果没有找到有效链接，返回原始链接
	else
		echo "$1"
		return 1

	fi
}

#下载
download_file() {
	url="$1"
	filename="$2"

	wget "$url" -O "$filename"
	status=$?

	if [ $status -eq 0 ]; then
		echo -e "\e[32m文件下载成功或已经是最新。\e[0m"
	else
		echo -e "\e[31m文件下载失败，退出状态码: $status\e[0m"
		exit 1
	fi
}

#檢查賦值
check_empty() {
	local var_value=$1

	if [[ -z $var_value ]]; then
		echo "$var_value 是空值，退出！"
		exit 1
	fi
}

#检查磁盘空间
check_disk_space() {
	# 检查是否存在 bc 命令
	if ! command -v bc &>/dev/null; then
		echo "安装 bc 命令..."
		# 检查系统类型并安装相应的 bc 包
		if [ -f /etc/redhat-release ]; then
			yum install -y bc
		elif [ -f /etc/debian_version ]; then
			apt-get update
			apt-get install -y bc
		else
			echo "无法确定系统类型，请手动安装 bc 命令。"
			return 1
		fi
	fi

	# 获取当前磁盘剩余空间
	available_space=$(df -h / | awk 'NR==2 {print $4}')

	# 移除单位字符，例如"GB"，并将剩余空间转换为数字
	available_space=$(echo "$available_space" | sed 's/G//')

	# 如果剩余空间小于等于0，则输出警告信息
	if [ $(echo "$available_space <= 0" | bc) -eq 1 ]; then
		echo "警告：磁盘空间已用尽，请勿重启，先清理空间。建议先卸载刚才安装的内核来释放空间，仅供参考。"
	else
		echo "当前磁盘剩余空间：$available_space GB"
	fi
}

#安装BBR内核
installbbr() {
	kernel_version="5.9.6"
	bit=$(uname -m)
	rm -rf bbr
	mkdir bbr && cd bbr || exit

	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "7" ]]; then
			if [[ ${bit} == "x86_64" ]]; then
				echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"

				headurl=https://github.com/ylx2016/kernel/releases/download/Centos_Kernel_6.1.35_latest_bbr_2023.06.22-0855/kernel-headers-6.1.35-1.x86_64.rpm
				imgurl=https://github.com/ylx2016/kernel/releases/download/Centos_Kernel_6.1.35_latest_bbr_2023.06.22-0855/kernel-6.1.35-1.x86_64.rpm

				check_empty $imgurl
				headurl=$(check_cn $headurl)
				imgurl=$(check_cn $imgurl)

				download_file "$headurl" kernel-headers-c7.rpm
				download_file "$imgurl" kernel-c7.rpm
				yum install -y kernel-c7.rpm
				yum install -y kernel-headers-c7.rpm
			else
				echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
			fi
		fi

	elif [[ "${OS_type}" == "Debian" ]]; then
		if [[ ${bit} == "x86_64" ]]; then
			echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
			github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Debian_Kernel' | grep '_latest_bbr_' | head -n 1 | awk -F '"' '{print $4}' | awk -F '[/]' '{print $8}')
			github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep "${github_tag}" | grep 'deb' | grep 'headers' | awk -F '"' '{print $4}' | awk -F '[/]' '{print $9}' | awk -F '[-]' '{print $3}' | awk -F '[_]' '{print $1}')
			check_empty "$github_ver"
			echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
			kernel_version=$github_ver
			detele_kernel_head
			headurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep "${github_tag}" | grep 'deb' | grep 'headers' | awk -F '"' '{print $4}')
			imgurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep "${github_tag}" | grep 'deb' | grep -v 'headers' | grep -v 'devel' | awk -F '"' '{print $4}')
			readarray -t urls <<< "$imgurl"
			if [ ${#urls[@]} -gt 0 ] && [ -n "${urls[0]}" ]; then
				imgurl=${urls[0]}
				echo "✅ 找到匹配的URL，使用第一个：$imgurl"
			elif [ ${#urls[@]} -eq 0 ]; then
			echo "❌ 错误：没有找到匹配 ${github_tag} 的URL"
			 	exit 1
			else
				echo "❌ 错误：找到的URL为空，请检查github_tag或接口返回"
			 	exit 1
			fi
			echo "📌 最终使用的 URL: $imgurl"
			headurl=$(check_cn "$headurl")
			imgurl=$(check_cn "$imgurl")

			download_file "$headurl" linux-headers-d10.deb
			download_file "$imgurl" linux-image-d10.deb
			dpkg -i linux-image-d10.deb
			dpkg -i linux-headers-d10.deb
		elif [[ ${bit} == "aarch64" ]]; then
			echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
			github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Debian_Kernel' | grep '_arm64_' | grep '_bbr_' | head -n 1 | awk -F '"' '{print $4}' | awk -F '[/]' '{print $8}')
			github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep "${github_tag}" | grep 'deb' | grep 'headers' | awk -F '"' '{print $4}' | awk -F '[/]' '{print $9}' | awk -F '[-]' '{print $3}' | awk -F '[_]' '{print $1}')
			echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
			kernel_version=$github_ver
			detele_kernel_head
			headurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep "${github_tag}" | grep 'deb' | grep 'headers' | awk -F '"' '{print $4}')
			imgurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep "${github_tag}" | grep 'deb' | grep -v 'headers' | grep -v 'devel' | awk -F '"' '{print $4}')

			check_empty "$imgurl"
			headurl=$(check_cn "$headurl")
			imgurl=$(check_cn "$imgurl")

			download_file "$headurl" linux-headers-d10.deb
			download_file "$imgurl" linux-image-d10.deb
			dpkg -i linux-image-d10.deb
			dpkg -i linux-headers-d10.deb
		else
			echo -e "${Error} 不支持x86_64及arm64/aarch64以外的系统 !" && exit 1
		fi
	fi

	cd .. && rm -rf bbr

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
	check_kernel
}

#安装BBRplus内核 4.14.129
installbbrplus() {
	kernel_version="4.14.160-bbrplus"
	bit=$(uname -m)
	rm -rf bbrplus
	mkdir bbrplus && cd bbrplus || exit
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "7" ]]; then
			if [[ ${bit} == "x86_64" ]]; then
				kernel_version="4.14.129_bbrplus"
				detele_kernel_head
				headurl=https://github.com/cx9208/Linux-NetSpeed/raw/master/bbrplus/centos/7/kernel-headers-4.14.129-bbrplus.rpm
				imgurl=https://github.com/cx9208/Linux-NetSpeed/raw/master/bbrplus/centos/7/kernel-4.14.129-bbrplus.rpm

				headurl=$(check_cn $headurl)
				imgurl=$(check_cn $imgurl)

				download_file "$headurl" kernel-headers-c7.rpm
				download_file "$imgurl" kernel-c7.rpm
				yum install -y kernel-c7.rpm
				yum install -y kernel-headers-c7.rpm
			else
				echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
			fi
		fi

	elif [[ "${OS_type}" == "Debian" ]]; then
		if [[ ${bit} == "x86_64" ]]; then
			kernel_version="4.14.129-bbrplus"
			detele_kernel_head
			headurl=https://github.com/cx9208/Linux-NetSpeed/raw/master/bbrplus/debian-ubuntu/x64/linux-headers-4.14.129-bbrplus.deb
			imgurl=https://github.com/cx9208/Linux-NetSpeed/raw/master/bbrplus/debian-ubuntu/x64/linux-image-4.14.129-bbrplus.deb

			headurl=$(check_cn $headurl)
			imgurl=$(check_cn $imgurl)

			wget -O linux-headers.deb "$headurl"
			wget -O linux-image.deb "$imgurl"

			dpkg -i linux-image.deb
			dpkg -i linux-headers.deb
		else
			echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
		fi
	fi

	cd .. && rm -rf bbrplus
	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
	check_kernel
}

#安装Lotserver内核
installlot() {
	bit=$(uname -m)
	if [[ ${bit} != "x86_64" ]]; then
		echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	fi
	if [[ ${bit} == "x86_64" ]]; then
		bit='x64'
	fi
	if [[ ${bit} == "i386" ]]; then
		bit='x32'
	fi
	if [[ "${OS_type}" == "CentOS" ]]; then
		rpm --import http://${github}/lotserver/"${release}"/RPM-GPG-KEY-elrepo.org
		yum remove -y kernel-firmware
		yum install -y http://${github}/lotserver/"${release}"/"${version}"/"${bit}"/kernel-firmware-${kernel_version}.rpm
		yum install -y http://${github}/lotserver/"${release}"/"${version}"/"${bit}"/kernel-${kernel_version}.rpm
		yum remove -y kernel-headers
		yum install -y http://${github}/lotserver/"${release}"/"${version}"/"${bit}"/kernel-headers-${kernel_version}.rpm
		yum install -y http://${github}/lotserver/"${release}"/"${version}"/"${bit}"/kernel-devel-${kernel_version}.rpm
	fi

	if [[ "${OS_type}" == "Debian" ]]; then
		deb_issue="$(cat /etc/issue)"
		deb_relese="$(echo "$deb_issue" | grep -io 'Ubuntu\|Debian' | sed -r 's/(.*)/\L\1/')"
		os_ver="$(dpkg --print-architecture)"
		[ -n "$os_ver" ] || exit 1
		if [ "$deb_relese" == 'ubuntu' ]; then
			deb_ver="$(echo "$deb_issue" | grep -o '[0-9]*\.[0-9]*' | head -n1)"
			if [ "$deb_ver" == "14.04" ]; then
				kernel_version="3.16.0-77-generic" && item="3.16.0-77-generic" && ver='trusty'
			elif [ "$deb_ver" == "16.04" ]; then
				kernel_version="4.8.0-36-generic" && item="4.8.0-36-generic" && ver='xenial'
			elif [ "$deb_ver" == "18.04" ]; then
				kernel_version="4.15.0-30-generic" && item="4.15.0-30-generic" && ver='bionic'
			else
				exit 1
			fi
			url='archive.ubuntu.com'
			urls='security.ubuntu.com'
		elif [ "$deb_relese" == 'debian' ]; then
			deb_ver="$(echo "$deb_issue" | grep -o '[0-9]*' | head -n1)"
			if [ "$deb_ver" == "7" ]; then
				kernel_version="3.2.0-4-${os_ver}" && item="3.2.0-4-${os_ver}" && ver='wheezy' && url='archive.debian.org' && urls='archive.debian.org'
			elif [ "$deb_ver" == "8" ]; then
				kernel_version="3.16.0-4-${os_ver}" && item="3.16.0-4-${os_ver}" && ver='jessie' && url='archive.debian.org' && urls='archive.debian.org'
			elif [ "$deb_ver" == "9" ]; then
				kernel_version="4.9.0-4-${os_ver}" && item="4.9.0-4-${os_ver}" && ver='stretch' && url='archive.debian.org' && urls='archive.debian.org'
			else
				exit 1
			fi
		fi
		[ -n "$item" ] && [ -n "$urls" ] && [ -n "$url" ] && [ -n "$ver" ] || exit 1
		if [ "$deb_relese" == 'ubuntu' ]; then
			echo "deb http://${url}/${deb_relese} ${ver} main restricted universe multiverse" >/etc/apt/sources.list
			echo "deb http://${url}/${deb_relese} ${ver}-updates main restricted universe multiverse" >>/etc/apt/sources.list
			echo "deb http://${url}/${deb_relese} ${ver}-backports main restricted universe multiverse" >>/etc/apt/sources.list
			echo "deb http://${urls}/${deb_relese} ${ver}-security main restricted universe multiverse" >>/etc/apt/sources.list

			apt-get update || apt-get --allow-releaseinfo-change update
			apt-get install --no-install-recommends -y linux-image-"${item}"
		elif [ "$deb_relese" == 'debian' ]; then
			echo "deb http://${url}/${deb_relese} ${ver} main" >/etc/apt/sources.list
			echo "deb-src http://${url}/${deb_relese} ${ver} main" >>/etc/apt/sources.list
			echo "deb http://${urls}/${deb_relese}-security ${ver}/updates main" >>/etc/apt/sources.list
			echo "deb-src http://${urls}/${deb_relese}-security ${ver}/updates main" >>/etc/apt/sources.list

			if [ "$deb_ver" == "8" ]; then
				dpkg -l | grep -q 'linux-base' || {
					wget --no-check-certificate -qO '/tmp/linux-base_3.5_all.deb' 'http://snapshot.debian.org/archive/debian/20120304T220938Z/pool/main/l/linux-base/linux-base_3.5_all.deb'
					dpkg -i '/tmp/linux-base_3.5_all.deb'
				}
				wget --no-check-certificate -qO '/tmp/linux-image-3.16.0-4-amd64_3.16.43-2+deb8u5_amd64.deb' 'http://snapshot.debian.org/archive/debian/20171008T163152Z/pool/main/l/linux/linux-image-3.16.0-4-amd64_3.16.43-2+deb8u5_amd64.deb'
				dpkg -i '/tmp/linux-image-3.16.0-4-amd64_3.16.43-2+deb8u5_amd64.deb'

				if [ $? -ne 0 ]; then
					exit 1
				fi
			elif [ "$deb_ver" == "9" ]; then
				dpkg -l | grep -q 'linux-base' || {
					wget --no-check-certificate -qO '/tmp/linux-base_4.5_all.deb' 'http://snapshot.debian.org/archive/debian/20160917T042239Z/pool/main/l/linux-base/linux-base_4.5_all.deb'
					dpkg -i '/tmp/linux-base_4.5_all.deb'
				}
				wget --no-check-certificate -qO '/tmp/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb' 'http://snapshot.debian.org/archive/debian/20171224T175424Z/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb'
				dpkg -i '/tmp/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb'
				##备选
				#https://debian.sipwise.com/debian-security/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb
				#http://snapshot.debian.org/archive/debian/20171224T175424Z/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb
				#http://snapshot.debian.org/archive/debian/20171231T180144Z/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3_amd64.deb
				if [ $? -ne 0 ]; then
					exit 1
				fi
			else
				exit 1
			fi
		fi
		apt-get autoremove -y
		[ -d '/var/lib/apt/lists' ] && find /var/lib/apt/lists -type f -delete
	fi

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
	check_kernel
}

#安装xanmod内核  from xanmod.org
installxanmod() {
	echo -e "xanmod这个自编译版本不维护了，后续请用官方编译版本，知悉."
	#https://api.github.com/repos/ylx2016/kernel/releases?page=1&per_page=100
	#releases?page=1&per_page=100
	kernel_version="5.5.1-xanmod1"
	bit=$(uname -m)
	if [[ ${bit} != "x86_64" ]]; then
		echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	fi
	rm -rf xanmod
	mkdir xanmod && cd xanmod || exit
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "7" ]]; then
			if [[ ${bit} == "x86_64" ]]; then
				echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
				headurl=https://github.com/ylx2016/kernel/releases/download/Centos_Kernel_5.15.95-xanmod1_lts_latest_2023.02.24-2159/kernel-headers-5.15.95_xanmod1-1.x86_64.rpm
				imgurl=https://github.com/ylx2016/kernel/releases/download/Centos_Kernel_5.15.95-xanmod1_lts_latest_2023.02.24-2159/kernel-5.15.95_xanmod1-1.x86_64.rpm

				check_empty $imgurl
				headurl=$(check_cn $headurl)
				imgurl=$(check_cn $imgurl)

				download_file "$headurl" kernel-headers-c7.rpm
				download_file "$imgurl" kernel-c7.rpm
				yum install -y kernel-c7.rpm
				yum install -y kernel-headers-c7.rpm
			else
				echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
			fi
		elif [[ ${version} == "8" ]]; then
			echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
			headurl=https://github.com/ylx2016/kernel/releases/download/Centos_Kernel_5.15.81-xanmod1_lts_C8_latest_2022.12.06-1614/kernel-headers-5.15.81_xanmod1-1.x86_64.rpm
			imgurl=https://github.com/ylx2016/kernel/releases/download/Centos_Kernel_5.15.81-xanmod1_lts_C8_latest_2022.12.06-1614/kernel-5.15.81_xanmod1-1.x86_64.rpm

			check_empty $imgurl
			headurl=$(check_cn $headurl)
			imgurl=$(check_cn $imgurl)

			wget -O kernel-headers-c8.rpm "$headurl"
			wget -O kernel-c8.rpm "$imgurl"
			yum install -y kernel-c8.rpm
			yum install -y kernel-headers-c8.rpm
		fi

	elif [[ "${OS_type}" == "Debian" ]]; then

		if [[ ${bit} == "x86_64" ]]; then
			echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
			headurl=https://github.com/ylx2016/kernel/releases/download/Debian_Kernel_5.15.95-xanmod1_lts_latest_2023.02.24-2210/linux-headers-5.15.95-xanmod1_5.15.95-xanmod1-1_amd64.deb
			imgurl=https://github.com/ylx2016/kernel/releases/download/Debian_Kernel_5.15.95-xanmod1_lts_latest_2023.02.24-2210/linux-image-5.15.95-xanmod1_5.15.95-xanmod1-1_amd64.deb

			check_empty $imgurl
			headurl=$(check_cn $headurl)
			imgurl=$(check_cn $imgurl)

			download_file "$headurl" linux-headers-d10.deb
			download_file "$imgurl" linux-image-d10.deb
			dpkg -i linux-image-d10.deb
			dpkg -i linux-headers-d10.deb
		else
			echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
		fi
	fi

	#cd .. && rm -rf xanmod
	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
	check_kernel
}

#安装bbr2内核 集成到xanmod内核了
#安装bbrplus 新内核
#2021.3.15 开始由https://github.com/UJX6N/bbrplus-5.19 替换bbrplusnew
#2021.4.12 地址更新为https://github.com/ylx2016/kernel/releases
#2021.9.2 再次改为https://github.com/UJX6N/bbrplus
#2022.9.6 改为https://github.com/UJX6N/bbrplus-5.19
#2022.11.24 改为https://github.com/UJX6N/bbrplus-6.x_stable

installbbrplusnew() {
	github_ver_plus=$(curl -s https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases | grep /bbrplus-6.x_stable/releases/tag/ | head -1 | awk -F "[/]" '{print $8}' | awk -F "[\"]" '{print $1}')
	github_ver_plus_num=$(curl -s https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases | grep /bbrplus-6.x_stable/releases/tag/ | head -1 | awk -F "[/]" '{print $8}' | awk -F "[\"]" '{print $1}' | awk -F "[-]" '{print $1}')
	echo -e "获取的UJX6N的bbrplus-6.x_stable版本号为:${Green_font_prefix}${github_ver_plus}${Font_color_suffix}"
	echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
	echo -e "${Green_font_prefix}安装失败这边反馈，内核问题给UJX6N反馈${Font_color_suffix}"
	# kernel_version=$github_ver_plus

	bit=$(uname -m)
	#if [[ ${bit} != "x86_64" ]]; then
	#  echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	#fi
	rm -rf bbrplusnew
	mkdir bbrplusnew && cd bbrplusnew || exit
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "7" ]]; then
			if [[ ${bit} == "x86_64" ]]; then
				kernel_version=${github_ver_plus_num}-bbrplus
				detele_kernel_head
				headurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep "${github_ver_plus}" | grep 'rpm' | grep 'headers' | grep 'el7' | awk -F '"' '{print $4}' | grep 'http')
				imgurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep "${github_ver_plus}" | grep 'rpm' | grep -v 'devel' | grep -v 'headers' | grep -v 'Source' | grep 'el7' | awk -F '"' '{print $4}' | grep 'http')

				headurl=$(check_cn "$headurl")
				imgurl=$(check_cn "$imgurl")

				wget -O kernel-c7.rpm "$headurl"
				wget -O kernel-headers-c7.rpm "$imgurl"
				yum install -y kernel-c7.rpm
				yum install -y kernel-headers-c7.rpm
			else
				echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
			fi
		fi
		if [[ ${version} == "8" ]]; then
			if [[ ${bit} == "x86_64" ]]; then
				kernel_version=${github_ver_plus_num}-bbrplus
				detele_kernel_head
				headurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep "${github_ver_plus}" | grep 'rpm' | grep 'headers' | grep 'el8.x86_64' | grep 'https' | awk -F '"' '{print $4}' | grep 'http')
				imgurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep "${github_ver_plus}" | grep 'rpm' | grep -v 'devel' | grep -v 'headers' | grep -v 'Source' | grep 'el8.x86_64' | grep 'https' | awk -F '"' '{print $4}' | grep 'http')

				headurl=$(check_cn "$headurl")
				imgurl=$(check_cn "$imgurl")

				wget -O kernel-c8.rpm "$headurl"
				wget -O kernel-headers-c8.rpm "$imgurl"
				yum install -y kernel-c8.rpm
				yum install -y kernel-headers-c8.rpm
			else
				echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
			fi
		fi
	elif [[ "${OS_type}" == "Debian" ]]; then
		if [[ ${bit} == "x86_64" ]]; then
			kernel_version=${github_ver_plus_num}-bbrplus
			detele_kernel_head
			headurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep "${github_ver_plus}" | grep 'https' | grep 'amd64.deb' | grep 'headers' | awk -F '"' '{print $4}' | grep 'http')
			imgurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep "${github_ver_plus}" | grep 'https' | grep 'amd64.deb' | grep 'image' | awk -F '"' '{print $4}' | grep 'http')

			headurl=$(check_cn "$headurl")
			imgurl=$(check_cn "$imgurl")

			download_file "$headurl" linux-headers-d10.deb
			download_file "$imgurl" linux-image-d10.deb
			dpkg -i linux-image-d10.deb
			dpkg -i linux-headers-d10.deb
		elif [[ ${bit} == "aarch64" ]]; then
			kernel_version=${github_ver_plus_num}-bbrplus
			detele_kernel_head
			headurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep "${github_ver_plus}" | grep 'https' | grep 'arm64.deb' | grep 'headers' | awk -F '"' '{print $4}')
			imgurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep "${github_ver_plus}" | grep 'https' | grep 'arm64.deb' | grep 'image' | awk -F '"' '{print $4}')

			headurl=$(check_cn "$headurl")
			imgurl=$(check_cn "$imgurl")

			download_file "$headurl" linux-headers-d10.deb
			download_file "$imgurl" linux-image-d10.deb
			dpkg -i linux-image-d10.deb
			dpkg -i linux-headers-d10.deb
		else
			echo -e "${Error} 不支持x86_64及arm64/aarch64以外的系统 !" && exit 1
		fi
	fi

	cd .. && rm -rf bbrplusnew
	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
	check_kernel

}

#安装cloud内核
installcloud() {

	# 检查当前系统发行版
	local DISTRO=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
	local ARCH=$(uname -m)
	local VERSIONS=()
	local VERSION_MAP_FILE="/tmp/version_map.txt"

	# 检查架构并设置 IMAGE_URL 和 IMAGE_PATTERN
	local IMAGE_URL
	local IMAGE_PATTERN
	if [ "$ARCH" == "x86_64" ]; then
		IMAGE_URL="https://deb.debian.org/debian/pool/main/l/linux-signed-amd64/"
		IMAGE_PATTERN='linux-image-[^"]+cloud-amd64_[^"]+_amd64\.deb'
	elif [ "$ARCH" == "aarch64" ]; then
		IMAGE_URL="https://deb.debian.org/debian/pool/main/l/linux-signed-arm64/"
		IMAGE_PATTERN='linux-image-[^"]+cloud-arm64_[^"]+_arm64\.deb'
	else
		echo "不支持的架构：$ARCH，仅支持 x86_64 和 aarch64"
		exit 1
	fi

	echo "检测到架构 $ARCH，正在从官方源获取cloud内核版本..."

	# 获取 cloud 内核 .deb 文件列表
	local DEB_FILES_RAW=$(curl -s "$IMAGE_URL" | grep -oP "$IMAGE_PATTERN")

	# 清空临时映射文件
	>"$VERSION_MAP_FILE"

	# 提取 image 版本号并写入映射文件
	while IFS= read -r file; do
		if [[ "$file" =~ linux-image-([0-9]+\.[0-9]+(\.[0-9]+)?(-[0-9]+)?) ]]; then
			local ver="${BASH_REMATCH[1]}"
			echo "$ver:$file" >>"$VERSION_MAP_FILE"
		fi
	done <<<"$DEB_FILES_RAW"

	# 读取排序并去重后的版本号
	mapfile -t VERSIONS < <(cut -d':' -f1 "$VERSION_MAP_FILE" | sort -V -u)

	# 确保有可用版本
	if [ ${#VERSIONS[@]} -eq 0 ]; then
		echo "未找到可用的cloud内核版本，请检查网络或反馈。"
		exit 1
	fi

	echo "检测到 $DISTRO 系统（架构 $ARCH），以下是从 Debian 签名cloud内核列表中获取的版本（按从小到大排序，已去重）："
	for i in "${!VERSIONS[@]}"; do
		echo "  $i) [${VERSIONS[$i]}]"
	done

	# 默认选择最新版本
	local DEFAULT_INDEX=$((${#VERSIONS[@]} - 1))
	echo "请选择要安装的cloud内核版本（10秒后默认选择最新版本回车加速 ${VERSIONS[$DEFAULT_INDEX]}，输入'h'则使用apt安装非最新cloud及headers）："
	read -t 10 -p "输入选项编号或'h': " CHOICE

	# 检查是否使用 apt 安装 cloud 及 headers
	local USE_APT=false
	if [[ "$CHOICE" =~ ^[hH]$ ]]; then
		USE_APT=true
		if [ "$DISTRO" != "debian" ]; then
			echo "错误：使用 'h' 安装 headers 仅支持 Debian 系统，当前系统为 $DISTRO"
			exit 1
		fi
		CHOICE=$DEFAULT_INDEX
	else
		CHOICE=${CHOICE:-$DEFAULT_INDEX}
	fi

	# 验证输入
	if [[ ! "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 0 ] || [ "$CHOICE" -ge "${#VERSIONS[@]}" ]; then
		echo "无效选项，默认安装最新版本 ${VERSIONS[$DEFAULT_INDEX]}..."
		CHOICE=$DEFAULT_INDEX
	fi

	local SELECTED_VERSION="${VERSIONS[$CHOICE]}"
	local IMAGE_DEB_FILE=$(grep "^$SELECTED_VERSION:" "$VERSION_MAP_FILE" | tail -n 1 | cut -d':' -f2)

	kernel_version=$SELECTED_VERSION

	# 如果选择 'h'，使用 apt 安装 cloud 内核及 headers
	if [ "$USE_APT" = true ]; then
		echo "正在使用 apt 安装 linux-image-cloud-${ARCH} 及 headers..."
		sudo apt update
		if [ "$ARCH" == "x86_64" ]; then
			sudo apt install -y "linux-image-cloud-amd64" "linux-headers-cloud-amd64"
		elif [ "$ARCH" == "aarch64" ]; then
			sudo apt install -y "linux-image-cloud-arm64" "linux-headers-cloud-arm64"
		fi
	else
		# 下载并安装 image
		echo "正在下载 $IMAGE_URL$IMAGE_DEB_FILE ..."
		curl -O "$IMAGE_URL$IMAGE_DEB_FILE"
		echo "正在安装 $IMAGE_DEB_FILE ..."
		sudo dpkg -i "$IMAGE_DEB_FILE"
		sudo apt-get install -f -y # 解决可能的依赖问题
	fi

	# 清理下载的文件
	rm -f "$IMAGE_DEB_FILE" "$VERSION_MAP_FILE"

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
	check_kernel

}

#启用BBR+fq
startbbrfq() {
	remove_bbr_lotserver
	echo "net.core.default_qdisc=fq" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}BBR+FQ修改成功，重启生效！"
}

#启用BBR+fq_pie
startbbrfqpie() {
	remove_bbr_lotserver
	echo "net.core.default_qdisc=fq_pie" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}BBR+FQ_PIE修改成功，重启生效！"
}

#启用BBR+cake
startbbrcake() {
	remove_bbr_lotserver
	echo "net.core.default_qdisc=cake" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}BBR+cake修改成功，重启生效！"
}

#启用BBRplus
startbbrplus() {
	remove_bbr_lotserver
	echo "net.core.default_qdisc=fq" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbrplus" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}BBRplus修改成功，重启生效！"
}

#启用Lotserver
startlotserver() {
	remove_bbr_lotserver
	if [[ "${OS_type}" == "CentOS" ]]; then
		yum install ethtool -y
	else
		apt-get update || apt-get --allow-releaseinfo-change update
		apt-get install ethtool -y
	fi
	echo | bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/fei5seven/lotServer/master/lotServerInstall.sh) install
	sed -i '/advinacc/d' /appex/etc/config
	sed -i '/maxmode/d' /appex/etc/config
	echo -e "advinacc=\"1\"
maxmode=\"1\"" >>/appex/etc/config
	/appex/bin/lotServer.sh restart
	start_menu
}

#启用BBR2+FQ
startbbr2fq() {
	remove_bbr_lotserver
	echo "net.core.default_qdisc=fq" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr2" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}BBR2修改成功，重启生效！"
}

#启用BBR2+FQ_PIE
startbbr2fqpie() {
	remove_bbr_lotserver
	echo "net.core.default_qdisc=fq_pie" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr2" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}BBR2修改成功，重启生效！"
}

#启用BBR2+CAKE
startbbr2cake() {
	remove_bbr_lotserver
	echo "net.core.default_qdisc=cake" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr2" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}BBR2修改成功，重启生效！"
}

#开启ecn
startecn() {
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf

	echo "net.ipv4.tcp_ecn=1" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}开启ecn结束！"
}

#关闭ecn
closeecn() {
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf

	echo "net.ipv4.tcp_ecn=0" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}关闭ecn结束！"
}

#编译安装brutal
startbrutal() {
	# 如果 headers_status 为 "已匹配headers"，执行外部脚本
	if [[ "$headers_status" == "已匹配" ]]; then
		echo "Headers 已匹配，开始编译..."
		bash <(curl -fsSL https://tcp.hy2.sh/)
		# 检查 brutal 模块是否加载
		if lsmod | grep -q "brutal"; then
			echo "brutal 模块已加载，请重新运行脚本查看状态"
			exit 0 # 成功退出
		else
			echo "brutal 模块未加载，可能编译安装失败"
			exit 1 # 失败退出
		fi
	else
		echo "当前内核headers不匹配或者没有安装"
		exit 1
	fi
}

#卸载bbr+锐速
remove_bbr_lotserver() {
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sysctl --system

	rm -rf bbrmod

	if [[ -e /appex/bin/lotServer.sh ]]; then
		echo | bash <(wget -qO- https://raw.githubusercontent.com/fei5seven/lotServer/master/lotServerInstall.sh) uninstall
	fi
	clear
	# echo -e "${Info}:清除bbr/lotserver加速完成。"
	# sleep 1s
}

#卸载全部加速
remove_all() {
	rm -rf /etc/sysctl.d/*.conf
	#rm -rf /etc/sysctl.conf
	#touch /etc/sysctl.conf
	if [ ! -f "/etc/sysctl.conf" ]; then
		touch /etc/sysctl.conf
	else
		cat /dev/null >/etc/sysctl.conf
	fi
	sysctl --system
	sed -i '/DefaultTimeoutStartSec/d' /etc/systemd/system.conf
	sed -i '/DefaultTimeoutStopSec/d' /etc/systemd/system.conf
	sed -i '/DefaultRestartSec/d' /etc/systemd/system.conf
	sed -i '/DefaultLimitCORE/d' /etc/systemd/system.conf
	sed -i '/DefaultLimitNOFILE/d' /etc/systemd/system.conf
	sed -i '/DefaultLimitNPROC/d' /etc/systemd/system.conf

	sed -i '/soft nofile/d' /etc/security/limits.conf
	sed -i '/hard nofile/d' /etc/security/limits.conf
	sed -i '/soft nproc/d' /etc/security/limits.conf
	sed -i '/hard nproc/d' /etc/security/limits.conf

	sed -i '/ulimit -SHn/d' /etc/profile
	sed -i '/ulimit -SHn/d' /etc/profile
	sed -i '/required pam_limits.so/d' /etc/pam.d/common-session

	systemctl daemon-reload

	rm -rf bbrmod
	sed -i '/net.ipv4.tcp_retries2/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	if [[ -e /appex/bin/lotServer.sh ]]; then
		bash <(wget -qO- https://raw.githubusercontent.com/fei5seven/lotServer/master/lotServerInstall.sh) uninstall
	fi
	clear
	echo -e "${Info}:清除加速完成。"
	sleep 1s
}

optimizing_ddcc() {
	sed -i '/net.ipv4.conf.all.rp_filter/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.d/99-sysctl.conf

	echo "net.ipv4.conf.all.rp_filter = 1" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_syncookies = 1" >>/etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_max_syn_backlog = 1024" >>/etc/sysctl.d/99-sysctl.conf
	sysctl -p
	sysctl --system
}

#更新脚本
Update_Shell() {
	local shell_file
	shell_file="$(readlink -f "$0")"
	local shell_url="https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh"

	# 下载最新版本的脚本
	wget -O "/tmp/tcpx.sh" "$(check_cn $shell_url)" &>/dev/null

	# 比较本地和远程脚本的 md5 值
	local md5_local
	local md5_remote
	md5_local="$(md5sum "$shell_file" | awk '{print $1}')"
	md5_remote="$(md5sum /tmp/tcpx.sh | awk '{print $1}')"

	if [ "$md5_local" != "$md5_remote" ]; then
		# 替换本地脚本文件
		cp "/tmp/tcpx.sh" "$shell_file"
		chmod +x "$shell_file"

		echo "脚本已更新，请重新运行。"
		exit 0
	else
		echo "脚本是最新版本，无需更新。"
	fi
}

#切换到卸载内核版本
gototcp() {
	clear
	bash <(wget -qO- https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcp.sh)
}

#切换到秋水逸冰BBR安装脚本
gototeddysun_bbr() {
	clear
	bash <(wget -qO- https://github.com/teddysun/across/raw/master/bbr.sh)
}

#切换到一键DD安装系统脚本 新手勿入
gotodd() {
	clear
	echo DD使用git.beta.gs的脚本，知悉
	sleep 1.5
	bash <(wget -qO- https://github.com/fcurrk/reinstall/raw/master/NewReinstall.sh)
}

#切换到检查当前IP质量/媒体解锁/邮箱通信脚本
gotoipcheck() {
	clear
	sleep 1.5
	bash <(wget -qO- https://raw.githubusercontent.com/xykt/IPQuality/main/ip.sh)
	#bash <(wget -qO- https://IP.Check.Place)
}

#禁用IPv6
closeipv6() {
	clear
	sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
	sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
	sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf

	echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}禁用IPv6结束，可能需要重启！"
}

#开启IPv6
openipv6() {
	clear
	sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
	sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
	sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
	sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
	sed -i '/net.ipv6.conf.all.accept_ra/d' /etc/sysctl.conf
	sed -i '/net.ipv6.conf.default.accept_ra/d' /etc/sysctl.conf

	echo "net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2" >>/etc/sysctl.d/99-sysctl.conf
	sysctl --system
	echo -e "${Info}开启IPv6结束，可能需要重启！"
}

#开始菜单
start_menu() {
	clear
	echo && echo -e " TCP加速 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}] 不卸内核${Font_color_suffix} from blog.ylx.me 母鸡慎用
 ${Green_font_prefix}0.${Font_color_suffix} 升级脚本
 ${Green_font_prefix}9.${Font_color_suffix} 切换到卸载内核版本        ${Green_font_prefix}10.${Font_color_suffix} 切换到一键DD系统脚本
 ${Green_font_prefix}60.${Font_color_suffix} 切换到检查当前IP质量/媒体解锁/邮箱通信脚本
 ———————————————————————————— 内核安装 —————————————————————————————
 ${Green_font_prefix}1.${Font_color_suffix} 安装 BBR原版内核          ${Green_font_prefix}7.${Font_color_suffix} 安装 Zen官方版内核
 ${Green_font_prefix}2.${Font_color_suffix} 安装 BBRplus版内核        ${Green_font_prefix}5.${Font_color_suffix} 安装 BBRplus新版内核
 ${Green_font_prefix}3.${Font_color_suffix} 安装 Lotserver(锐速)内核  ${Green_font_prefix}8.${Font_color_suffix} 安装 官方cloud内核
 ${Green_font_prefix}30.${Font_color_suffix} 安装 官方稳定内核        ${Green_font_prefix}31.${Font_color_suffix} 安装 官方最新内核
 ${Green_font_prefix}32.${Font_color_suffix} 安装 XANMOD(main)        ${Green_font_prefix}33.${Font_color_suffix} 安装 XANMOD(LTS)
 ${Green_font_prefix}36.${Font_color_suffix} 安装 XANMOD(EDGE)        ${Green_font_prefix}37.${Font_color_suffix} 安装 XANMOD(RT)
 ———————————————————————————— 加速启用 —————————————————————————————
 ${Green_font_prefix}11.${Font_color_suffix} 使用BBR+FQ加速           ${Green_font_prefix}12.${Font_color_suffix} 使用BBR+FQ_PIE加速 
 ${Green_font_prefix}13.${Font_color_suffix} 使用BBR+CAKE加速         ${Green_font_prefix}14.${Font_color_suffix} 使用BBR2+FQ加速
 ${Green_font_prefix}15.${Font_color_suffix} 使用BBR2+FQ_PIE加速      ${Green_font_prefix}16.${Font_color_suffix} 使用BBR2+CAKE加速
 ${Green_font_prefix}19.${Font_color_suffix} 使用BBRplus+FQ版加速     ${Green_font_prefix}20.${Font_color_suffix} 使用Lotserver(锐速)加速
 ${Green_font_prefix}28.${Font_color_suffix} 编译安装brutal模块
 ———————————————————————————— 系统配置 —————————————————————————————
 ${Green_font_prefix}17.${Font_color_suffix} 开启ECN                  ${Green_font_prefix}18.${Font_color_suffix} 关闭ECN
 ${Green_font_prefix}21.${Font_color_suffix} 系统配置优化旧           ${Green_font_prefix}22.${Font_color_suffix} 系统配置优化新
 ${Green_font_prefix}23.${Font_color_suffix} 禁用IPv6                 ${Green_font_prefix}24.${Font_color_suffix} 开启IPv6
 ${Green_font_prefix}61.${Font_color_suffix} 手动提交合并内核参数     ${Green_font_prefix}62.${Font_color_suffix} 手动编辑内核参数
 ———————————————————————————— 内核管理 —————————————————————————————
 ${Green_font_prefix}51.${Font_color_suffix} 查看排序内核             ${Green_font_prefix}52.${Font_color_suffix} 删除保留指定内核
 ${Green_font_prefix}25.${Font_color_suffix} 卸载全部加速             ${Green_font_prefix}99.${Font_color_suffix} 退出脚本 
————————————————————————————————————————————————————————————————" &&
		check_status
	get_system_info
	echo -e " 信息： ${Font_color_suffix}$opsy ${Green_font_prefix}$virtual${Font_color_suffix} $arch ${Green_font_prefix}$kern${Font_color_suffix} "
	if [[ ${kernel_status} == "noinstall" ]]; then
		echo -e " 状态: ${Green_font_prefix}未安装${Font_color_suffix} 加速内核 ${Red_font_prefix}请先安装内核${Font_color_suffix}"
	else
		echo -e " 状态: ${Green_font_prefix}已安装${Font_color_suffix} ${Red_font_prefix}${kernel_status}${Font_color_suffix} 加速内核 , ${Green_font_prefix}${run_status}${Font_color_suffix} ${Red_font_prefix}${brutal}${Font_color_suffix}"

	fi
	echo -e " 拥塞控制算法:: ${Green_font_prefix}${net_congestion_control}${Font_color_suffix} 队列算法: ${Green_font_prefix}${net_qdisc}${Font_color_suffix} 内核headers：${Green_font_prefix}${headers_status}${Font_color_suffix}"

	read -p " 请输入数字 :" num
	case "$num" in
	0)
		Update_Shell
		;;
	1)
		check_sys_bbr
		;;
	2)
		check_sys_bbrplus
		;;
	3)
		check_sys_Lotsever
		;;
	5)
		check_sys_bbrplusnew
		;;
	7)
		check_sys_official_zen
		;;
	8)
		check_sys_cloud
		;;
	30)
		check_sys_official
		;;
	31)
		check_sys_official_bbr
		;;
	32)
		check_sys_official_xanmod_main
		;;
	33)
		check_sys_official_xanmod_lts
		;;
	36)
		check_sys_official_xanmod_edge
		;;
	37)
		check_sys_official_xanmod_rt
		;;
	9)
		gototcp
		;;
	10)
		gotodd
		;;
	60)
		gotoipcheck
		;;
	11)
		startbbrfq
		;;
	12)
		startbbrfqpie
		;;
	13)
		startbbrcake
		;;
	14)
		startbbr2fq
		;;
	15)
		startbbr2fqpie
		;;
	16)
		startbbr2cake
		;;
	17)
		startecn
		;;
	18)
		closeecn
		;;
	19)
		startbbrplus
		;;
	20)
		startlotserver
		;;
	21)
		optimizing_system_old
		;;
	22)
		optimizing_system_johnrosen1
		;;
	23)
		closeipv6
		;;
	24)
		openipv6
		;;
	25)
		remove_all
		;;
	26)
		optimizing_ddcc
		;;
	28)
		startbrutal
		;;
	51)
		BBR_grub
		;;
	52)
		detele_kernel_custom
		;;
	61)
		update_sysctl_interactive
		;;
	62)
		edit_sysctl_interactive
		;;
	99)
		exit 1
		;;
	*)
		clear
		echo -e "${Error}:请输入正确数字 [0-99]"
		sleep 5s
		start_menu
		;;
	esac
}
#############内核管理组件#############

#删除多余内核
detele_kernel() {
	if [[ "${OS_type}" == "CentOS" ]]; then
		rpm_total=$(rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | wc -l)
		if [ "${rpm_total}" ] >"1"; then
			echo -e "检测到 ${rpm_total} 个其余内核，开始卸载..."
			for ((integer = 1; integer <= ${rpm_total}; integer++)); do
				rpm_del=$(rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer})
				echo -e "开始卸载 ${rpm_del} 内核..."
				rpm --nodeps -e "${rpm_del}"
				echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
			done
			echo --nodeps -e "内核卸载完毕，继续..."
		else
			echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
		fi
	elif [[ "${OS_type}" == "Debian" ]]; then
		deb_total=$(dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | wc -l)
		if [ "${deb_total}" ] >"1"; then
			echo -e "检测到 ${deb_total} 个其余内核，开始卸载..."
			for ((integer = 1; integer <= ${deb_total}; integer++)); do
				deb_del=$(dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer})
				echo -e "开始卸载 ${deb_del} 内核..."
				apt-get purge -y "${deb_del}"
				apt-get autoremove -y
				echo -e "卸载 ${deb_del} 内核卸载完成，继续..."
			done
			echo -e "内核卸载完毕，继续..."
		else
			echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
		fi
	fi
}

detele_kernel_head() {
	if [[ "${OS_type}" == "CentOS" ]]; then
		rpm_total=$(rpm -qa | grep kernel-headers | grep -v "${kernel_version}" | grep -v "noarch" | wc -l)
		if [ "${rpm_total}" ] >"1"; then
			echo -e "检测到 ${rpm_total} 个其余head内核，开始卸载..."
			for ((integer = 1; integer <= ${rpm_total}; integer++)); do
				rpm_del=$(rpm -qa | grep kernel-headers | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer})
				echo -e "开始卸载 ${rpm_del} headers内核..."
				rpm --nodeps -e "${rpm_del}"
				echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
			done
			echo --nodeps -e "内核卸载完毕，继续..."
		else
			echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
		fi
	elif [[ "${OS_type}" == "Debian" ]]; then
		deb_total=$(dpkg -l | grep linux-headers | awk '{print $2}' | grep -v "${kernel_version}" | wc -l)
		if [ "${deb_total}" ] >"1"; then
			echo -e "检测到 ${deb_total} 个其余head内核，开始卸载..."
			for ((integer = 1; integer <= ${deb_total}; integer++)); do
				deb_del=$(dpkg -l | grep linux-headers | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer})
				echo -e "开始卸载 ${deb_del} headers内核..."
				apt-get purge -y "${deb_del}"
				apt-get autoremove -y
				echo -e "卸载 ${deb_del} 内核卸载完成，继续..."
			done
			echo -e "内核卸载完毕，继续..."
		else
			echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
		fi
	fi
}

detele_kernel_custom() {
	BBR_grub
	read -p " 查看上面内核输入需保留保留保留的内核关键词(如:5.15.0-11) :" kernel_version
	detele_kernel
	detele_kernel_head
	BBR_grub
}

#-----------------------------------------------------------------------
# 函数: update_sysctl_interactive (V4 - 增加错误忽略参数)
# 功能: 以交互方式安全地更新 sysctl 配置文件并应用。
#       命令执行失败时，将不会回滚文件更改。
#-----------------------------------------------------------------------
update_sysctl_interactive() {
	# 强制使用C语言环境，确保正则表达式的行为可预测且一致。
	local LC_ALL=C

	# --- 配置与参数解析 ---
	local CONF_FILE="/etc/sysctl.d/99-sysctl.conf"
	local TMP_FILE
	local BACKUP_FILE
	local ignore_apply_error=true

	# --- 帮助函数 ---
	log_info() {
		echo "[INFO] $1"
	}

	log_error() {
		echo "[ERROR] $1" >&2
	}

	log_warn() {
		echo "[WARN] $1" >&2
	}

	# --- 主逻辑 ---

	# 1. 权限检查
	if [[ $EUID -ne 0 ]]; then
		log_error "此函数必须以 root 权限运行，请使用 sudo。"
		return 1
	fi

	# 2. 交互式获取用户输入
	log_info "请输入或粘贴您要设置的 sysctl 参数 (格式: key = value)。"
	log_info "可参考TCP迷之调参，https://omnitt.com/"
	log_info "注释行(以 # 或 ; 开头)和空行将被忽略。"
	log_info "最后一行请以空行结束 可手动回车加一行空行"
	log_info "输入完成后，请按 Ctrl+D 结束输入。"

	readarray -t user_input

	if [ ${#user_input[@]} -eq 0 ]; then
		log_info "没有接收到任何输入，操作已取消。"
		return 0
	fi

	# 确保配置文件存在
	touch "$CONF_FILE"

	# 3. 创建临时文件
	TMP_FILE=$(mktemp) || {
		log_error "无法创建临时文件"
		return 1
	}
	trap 'rm -f "$TMP_FILE"' RETURN

	cp "$CONF_FILE" "$TMP_FILE"

	local -A params_to_add
	local all_params_valid=true

	# 4. 预处理所有输入，检查合法性
	log_info "正在校验所有输入参数..."
	for line in "${user_input[@]}"; do
		trimmed_line=$(echo "$line" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

		if [[ -z "$trimmed_line" ]] || [[ "$trimmed_line" =~ ^[[:space:]]*[#\;] ]]; then
			continue
		fi

		if ! [[ "$trimmed_line" =~ ^[[:space:]]*([a-zA-Z0-9._-]+)[[:space:]]*=[[:space:]]*(.*)[[:space:]]*$ ]]; then
			log_error "格式无效: '$trimmed_line'. 期望格式为 'key = value'."
			all_params_valid=false
			continue
		fi

		local key="${BASH_REMATCH[1]}"
		local value="${BASH_REMATCH[2]}"

		if ! sysctl -N "$key" >/dev/null 2>&1; then
			log_error "参数键名无效: '$key' 不是一个有效的内核参数。"
			all_params_valid=false
			continue
		fi

		local formatted_param="$key = $value"

		if grep -q -E "^[[:space:]]*${key//./\\.}([[:space:]]*)=.*" "$TMP_FILE"; then
			sed -i -E "s|^[[:space:]]*${key//./\\.}([[:space:]]*)=.*|$formatted_param|" "$TMP_FILE"
			log_info "已更新参数: $formatted_param"
		else
			if [[ -z "${params_to_add[$key]}" ]]; then
				params_to_add["$key"]="$formatted_param"
			fi
		fi
	done

	if ! $all_params_valid; then
		log_error "检测到无效参数，操作已中止。配置文件未做任何更改。"
		return 1
	fi

	# 5. 将所有新参数追加到临时文件末尾
	if [ ${#params_to_add[@]} -gt 0 ]; then
		log_info "正在添加新参数..."
		echo "" >>"$TMP_FILE"
		for key in "${!params_to_add[@]}"; do
			echo "${params_to_add[$key]}" >>"$TMP_FILE"
			log_info "已添加新参数: ${params_to_add[$key]}"
		done
	fi

	# 6. 原子替换与应用
	BACKUP_FILE="${CONF_FILE}.bak_$(date +%Y%m%d_%H%M%S)"
	cp "$CONF_FILE" "$BACKUP_FILE"
	log_info "原始文件已备份到 $BACKUP_FILE"

	mv "$TMP_FILE" "$CONF_FILE"
	chown root:root "$CONF_FILE"
	chmod 644 "$CONF_FILE"
	trap - RETURN

	# 7. 应用配置并进行错误处理
	log_info "正在应用新�� sysctl 设置..."
	if apply_output=$(sysctl -p "$CONF_FILE" 2>&1); then
		log_info "Sysctl 设置已成功应用。"
		echo "--- 应用输出 ---"
		echo "$apply_output"
		echo "------------------"
		rm -f "$BACKUP_FILE"
	else
		# 应用失败时的逻辑
		if [[ "$ignore_apply_error" == "true" ]]; then
			log_warn "应用 sysctl 设置失败，但根据指令已忽略错误。"
			log_warn "配置文件 '${CONF_FILE}' 已被更新，但部分设置可能未生效。"
			log_warn "--- 错误详情 ---"
			echo "$apply_output" >&2
			echo "------------------"
			rm -f "$BACKUP_FILE" # 忽略错误，所以也删除备份
			return 0             # 返回成功状态
		else
			log_error "应用 sysctl 设置失败！正在回滚..."
			log_error "--- 错误详情 ---"
			echo "$apply_output"
			echo "------------------"

			mv "$BACKUP_FILE" "$CONF_FILE"
			log_info "正在恢复到之前的设置..."
			sysctl -p "$CONF_FILE" >/dev/null 2>&1

			log_error "回滚完成。配置文件已恢复，问题备份文件保留在 $BACKUP_FILE"
			return 1
		fi
	fi

	return 0
}

edit_sysctl_interactive() {
	local target_file="/etc/sysctl.d/99-sysctl.conf"
	local editor_cmd=""

	# --- 1. 检查文件是否存在 ---
	if [ ! -f "$target_file" ]; then
		echo "文件 $target_file 不存在。"
		# (Y/n) 格式，n/N 以外的任何输入（包括回车）都将继续
		read -r -p "您想现在创建并编辑它吗？ (Y/n): " create_choice

		case "$create_choice" in
		[nN])
			echo "操作已取消。"
			return 0 # 0 表示成功（用户主动取消）
			;;
		*)
			echo "好的，准备创建并打开编辑器..."
			# 注意：我们不需要在这里 'touch' 文件。
			# 'sudo' 配合编辑器（如 nano 或 vi）在保存时会自动创建文件。
			;;
		esac
	fi

	# --- 2. 检查并选择编辑器 ---
	if command -v nano >/dev/null; then
		# 优先使用 nano
		editor_cmd="nano"
	else
		# nano 不存在，提示安装
		echo "首选编辑器 'nano' 未安装。"
		# (Y/n) 格式，n/N 以外的任何输入（包括回车）都将继续
		read -r -p "您想现在安装 'nano' 吗？ (Y/n): " install_choice

		case "$install_choice" in
		[nN])
			# 用户不安装，回退到 vi
			echo "好的，将使用 'vi' 编辑器。"
			echo "提示：'vi' 启动后，按 'i' 键进入插入模式，'Esc' 键退出插入模式，"
			echo "   然后输入 ':wq' 保存并退出，或 ':q!' 不保存退出。"
			editor_cmd="vi"
			;;
		*)
			# 这是一个安全的设计：函数不应该自己执行安装。
			# 它应该指导用户，然后退出，让用户安装后重试。
			echo "请在您的终端中运行:"
			echo "  sudo apt install nano  (适用于 Debian/Ubuntu)"
			echo "  sudo dnf install nano  (适用于 Fedora/RHEL 8+)"
			echo "  sudo yum install nano  (适用于 CentOS 7)"
			echo "安装完成后，请重新运行此函数。"
			echo "操作已取消。"
			return 1 # 1 表示一个非0的退出码，表示未完成
			;;
		esac
	fi

	# --- 3. 执行编辑 ---
	echo "正在使用 $editor_cmd 打开 $target_file..."
	echo "请注意：编辑系统文件需要管理员权限，您可能需要输入密码。"

	# 使用 sudo 来运行编辑器，以便有权限写入 /etc/sysctl.d/ 目录
	if ! sudo "$editor_cmd" "$target_file"; then
		echo "编辑器 '$editor_cmd' 启动失败或异常退出。"
		echo "请检查您的 sudo 权限或编辑器是否正确安装。"
		return 1
	fi

	# --- 4. (修改) 默认直接应用 ---
	echo ""
	echo "编辑完成。"
	echo "正在应用 $target_file 中的设置..."

	# -p 参数会从指定文件中加载设置
	sudo sysctl -p "$target_file"
	echo "已执行应用，部分可能需要重启生效"
}

#更新引导
BBR_grub() {
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "6" ]]; then
			if [ -f "/boot/grub/grub.conf" ]; then
				sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
			elif [ -f "/boot/grub/grub.cfg" ]; then
				grub-mkconfig -o /boot/grub/grub.cfg
				grub-set-default 0
			elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; then
				grub-mkconfig -o /boot/efi/EFI/centos/grub.cfg
				grub-set-default 0
			elif [ -f "/boot/efi/EFI/redhat/grub.cfg" ]; then
				grub-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
				grub-set-default 0
			else
				echo -e "${Error} grub.conf/grub.cfg 找不到，请检查."
				exit
			fi
		elif [[ ${version} == "7" ]]; then
			if [ -f "/boot/grub2/grub.cfg" ]; then
				grub2-mkconfig -o /boot/grub2/grub.cfg
				grub2-set-default 0
			elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; then
				grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
				grub2-set-default 0
			elif [ -f "/boot/efi/EFI/redhat/grub.cfg" ]; then
				grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
				grub2-set-default 0
			else
				echo -e "${Error} grub.cfg 找不到，请检查."
				exit
			fi
		elif [[ ${version} == "8" ]]; then
			if [ -f "/boot/grub2/grub.cfg" ]; then
				grub2-mkconfig -o /boot/grub2/grub.cfg
				grub2-set-default 0
			elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; then
				grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
				grub2-set-default 0
			elif [ -f "/boot/efi/EFI/redhat/grub.cfg" ]; then
				grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
				grub2-set-default 0
			else
				echo -e "${Error} grub.cfg 找不到，请检查."
				exit
			fi
			grubby --info=ALL | awk -F= '$1=="kernel" {print i++ " : " $2}'
		fi
	elif [[ "${OS_type}" == "Debian" ]]; then
		if _exists "update-grub"; then
			update-grub
		elif [ -f "/usr/sbin/update-grub" ]; then
			/usr/sbin/update-grub
		else
			apt install grub2-common -y
			update-grub
		fi
		#exit 1
	fi
	check_disk_space
}

#简单的检查内核
check_kernel() {
	if [[ -z "$(find /boot -type f -name 'vmlinuz-*' ! -name 'vmlinuz-*rescue*')" ]]; then
		echo -e "\033[0;31m警告: 未发现内核文件，请勿重启系统，不卸载内核版本选择30安装默认内核救急！\033[0m"
	else
		echo -e "\033[0;32m发现内核文件，看起来可以重启。\033[0m"
	fi
}

#############内核管理组件#############

#############系统检测组件#############

#检查系统
check_sys() {
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif grep -qi "debian" /etc/issue; then
		release="debian"
	elif grep -qi "ubuntu" /etc/issue; then
		release="ubuntu"
	elif grep -qi -E "centos|red hat|redhat" /etc/issue || grep -qi -E "centos|red hat|redhat" /proc/version; then
		release="centos"
	fi

	if [[ -f /etc/debian_version ]]; then
		OS_type="Debian"
		echo "检测为Debian通用系统，判断有误请反馈"
	elif [[ -f /etc/redhat-release || -f /etc/centos-release || -f /etc/fedora-release ]]; then
		OS_type="CentOS"
		echo "检测为CentOS通用系统，判断有误请反馈"
	else
		echo "Unknown"
	fi

	#from https://github.com/oooldking

	_exists() {
		local cmd="$1"
		if eval type type >/dev/null 2>&1; then
			eval type "$cmd" >/dev/null 2>&1
		elif command >/dev/null 2>&1; then
			command -v "$cmd" >/dev/null 2>&1
		else
			which "$cmd" >/dev/null 2>&1
		fi
		local rt=$?
		return ${rt}
	}

	get_opsy() {
		if [ -f /etc/os-release ]; then
			awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release
		elif [ -f /etc/lsb-release ]; then
			awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release
		elif [ -f /etc/system-release ]; then
			cat /etc/system-release | awk '{print $1,$2}'
		fi
	}

	get_system_info() {
		opsy=$(get_opsy)
		arch=$(uname -m)
		kern=$(uname -r)
		virt_check
	}
	# from LemonBench
	virt_check() {
		if [ -f "/usr/bin/systemd-detect-virt" ]; then
			Var_VirtType="$(/usr/bin/systemd-detect-virt)"
			# 虚拟机检测
			if [ "${Var_VirtType}" = "qemu" ]; then
				virtual="QEMU"
			elif [ "${Var_VirtType}" = "kvm" ]; then
				virtual="KVM"
			elif [ "${Var_VirtType}" = "zvm" ]; then
				virtual="S390 Z/VM"
			elif [ "${Var_VirtType}" = "vmware" ]; then
				virtual="VMware"
			elif [ "${Var_VirtType}" = "microsoft" ]; then
				virtual="Microsoft Hyper-V"
			elif [ "${Var_VirtType}" = "xen" ]; then
				virtual="Xen Hypervisor"
			elif [ "${Var_VirtType}" = "bochs" ]; then
				virtual="BOCHS"
			elif [ "${Var_VirtType}" = "uml" ]; then
				virtual="User-mode Linux"
			elif [ "${Var_VirtType}" = "parallels" ]; then
				virtual="Parallels"
			elif [ "${Var_VirtType}" = "bhyve" ]; then
				virtual="FreeBSD Hypervisor"
			# 容器虚拟化检测
			elif [ "${Var_VirtType}" = "openvz" ]; then
				virtual="OpenVZ"
			elif [ "${Var_VirtType}" = "lxc" ]; then
				virtual="LXC"
			elif [ "${Var_VirtType}" = "lxc-libvirt" ]; then
				virtual="LXC (libvirt)"
			elif [ "${Var_VirtType}" = "systemd-nspawn" ]; then
				virtual="Systemd nspawn"
			elif [ "${Var_VirtType}" = "docker" ]; then
				virtual="Docker"
			elif [ "${Var_VirtType}" = "rkt" ]; then
				virtual="RKT"
			# 特殊处理
			elif [ -c "/dev/lxss" ]; then # 处理WSL虚拟化
				Var_VirtType="wsl"
				virtual="Windows Subsystem for Linux (WSL)"
			# 未匹配到任何结果, 或者非虚拟机
			elif [ "${Var_VirtType}" = "none" ]; then
				Var_VirtType="dedicated"
				virtual="None"
				local Var_BIOSVendor
				Var_BIOSVendor="$(dmidecode -s bios-vendor)"
				if [ "${Var_BIOSVendor}" = "SeaBIOS" ]; then
					Var_VirtType="Unknown"
					virtual="Unknown with SeaBIOS BIOS"
				else
					Var_VirtType="dedicated"
					virtual="Dedicated with ${Var_BIOSVendor} BIOS"
				fi
			fi
		elif [ ! -f "/usr/sbin/virt-what" ]; then
			Var_VirtType="Unknown"
			virtual="[Error: virt-what not found !]"
		elif [ -f "/.dockerenv" ]; then # 处理Docker虚拟化
			Var_VirtType="docker"
			virtual="Docker"
		elif [ -c "/dev/lxss" ]; then # 处理WSL虚拟化
			Var_VirtType="wsl"
			virtual="Windows Subsystem for Linux (WSL)"
		else # 正常判断流程
			Var_VirtType="$(virt-what | xargs)"
			local Var_VirtTypeCount
			Var_VirtTypeCount="$(echo "$Var_VirtTypeCount" | wc -l)"
			if [ "${Var_VirtTypeCount}" -gt "1" ]; then # 处理嵌套虚拟化
				virtual="echo ${Var_VirtType}"
				Var_VirtType="$(echo "${Var_VirtType}" | head -n1)"                         # 使用检测到的第一种虚拟化继续做判断
			elif [ "${Var_VirtTypeCount}" -eq "1" ] && [ "${Var_VirtType}" != "" ]; then # 只有一种虚拟化
				virtual="${Var_VirtType}"
			else
				local Var_BIOSVendor
				Var_BIOSVendor="$(dmidecode -s bios-vendor)"
				if [ "${Var_BIOSVendor}" = "SeaBIOS" ]; then
					Var_VirtType="Unknown"
					virtual="Unknown with SeaBIOS BIOS"
				else
					Var_VirtType="dedicated"
					virtual="Dedicated with ${Var_BIOSVendor} BIOS"
				fi
			fi
		fi
	}

	#检查依赖
	if [[ "${OS_type}" == "CentOS" ]]; then
		# 检查是否安装了 ca-certificates 包，如果未安装则安装
		if ! rpm -q ca-certificates >/dev/null; then
			echo '正在安装 ca-certificates 包...'
			yum install ca-certificates -y
			update-ca-trust force-enable
		fi
		echo 'CA证书检查OK'

		# 检查并安装 curl、wget、dmidecode 和 redhat-lsb-core 包
		for pkg in curl wget dmidecode redhat-lsb-core; do
			if ! rpm -q "$pkg" >/dev/null 2>&1; then
				echo "未安装 $pkg，正在安装..."
				yum install -y "$pkg"
			else
				echo "$pkg 已安装。"
			fi
		done

		# 专门检查 lsb_release 命令
		if command -v lsb_release >/dev/null 2>&1; then
			echo "lsb_release 已安装。"
		else
			echo "lsb_release 未安装，尝试安装 redhat-lsb-core..."
			# 确保 epel-release 已安装（如果需要）
			if ! rpm -q epel-release >/dev/null 2>&1; then
				echo "安装 epel-release..."
				yum install -y epel-release
			fi
			# 再次尝试安装 redhat-lsb-core
			yum install -y redhat-lsb-core
			# 验证 lsb_release 是否安装成功
			if command -v lsb_release >/dev/null 2>&1; then
				echo "lsb_release 安装成功。"
			else
				echo "错误：无法安装 lsb_release，请检查 yum 存储库或包的可用性。"
			fi
		fi

	elif [[ "${OS_type}" == "Debian" ]]; then
		# 检查是否安装了 ca-certificates 包，如果未安装则安装
		if ! dpkg-query -W ca-certificates >/dev/null; then
			echo '正在安装 ca-certificates 包...'
			apt-get update || apt-get --allow-releaseinfo-change update && apt-get install ca-certificates -y
			update-ca-certificates
		fi
		echo 'CA证书检查OK'

		# 检查并安装 curl、wget 和 dmidecode 包
		for pkg in curl wget dmidecode; do
			if ! type $pkg >/dev/null 2>&1; then
				echo "未安装 $pkg，正在安装..."
				apt-get update || apt-get --allow-releaseinfo-change update && apt-get install $pkg -y
			else
				echo "$pkg 已安装。"
			fi
		done

		if [ -x "$(command -v lsb_release)" ]; then
			echo "lsb_release 已安装"
		else
			echo "lsb_release 未安装，现在开始安装..."
			apt-get install lsb-release -y
		fi

	else
		echo "不支持的操作系统发行版：${release}"
		exit 1
	fi
}

#检查Linux版本
check_version() {
	if [[ -s /etc/redhat-release ]]; then
		version=$(grep -oE "[0-9.]+" /etc/redhat-release | cut -d . -f 1)
	else
		version=$(grep -oE "[0-9.]+" /etc/issue | cut -d . -f 1)
	fi
	bit=$(uname -m)
	#check_github
}

#检查安装bbr的系统要求
check_sys_bbr() {
	check_version
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "7" ]]; then
			installbbr
		else
			echo -e "${Error} BBR内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${OS_type}" == "Debian" ]]; then
		apt-get --fix-broken install -y && apt-get autoremove -y
		installbbr
	else
		echo -e "${Error} BBR内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi
}

check_sys_bbrplus() {
	check_version
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "7" ]]; then
			installbbrplus
		else
			echo -e "${Error} BBRplus内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${OS_type}" == "Debian" ]]; then
		apt-get --fix-broken install -y && apt-get autoremove -y
		installbbrplus
	else
		echo -e "${Error} BBRplus内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi
}

check_sys_bbrplusnew() {
	check_version
	if [[ "${OS_type}" == "CentOS" ]]; then
		#if [[ ${version} == "7" ]]; then
		if [[ ${version} == "7" || ${version} == "8" ]]; then
			installbbrplusnew
		else
			echo -e "${Error} BBRplusNew内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${OS_type}" == "Debian" ]]; then
		apt-get --fix-broken install -y && apt-get autoremove -y
		installbbrplusnew
	else
		echo -e "${Error} BBRplusNew内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi
}

check_sys_xanmod() {
	check_version
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "7" || ${version} == "8" ]]; then
			installxanmod
		else
			echo -e "${Error} xanmod内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${OS_type}" == "Debian" ]]; then
		apt-get --fix-broken install -y && apt-get autoremove -y
		installxanmod
	else
		echo -e "${Error} xanmod内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi
}

check_sys_cloud() {
	check_version
	if [[ "${OS_type}" == "Debian" ]]; then
		apt-get --fix-broken install -y && apt-get autoremove -y
		installcloud
	else
		echo -e "${Error} cloud内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi
}

#检查安装Lotsever的系统要求
check_sys_Lotsever() {
	check_version
	bit=$(uname -m)
	if [[ ${bit} != "x86_64" ]]; then
		echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	fi
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${version} == "6" ]]; then
			kernel_version="2.6.32-504"
			installlot
		elif [[ ${version} == "7" ]]; then
			yum -y install net-tools
			kernel_version="4.11.2-1"
			installlot
		else
			echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		if [[ ${version} == "7" || ${version} == "8" ]]; then
			if [[ ${bit} == "x86_64" ]]; then
				kernel_version="3.16.0-4"
				installlot
			elif [[ ${bit} == "i386" ]]; then
				kernel_version="3.2.0-4"
				installlot
			fi
		elif [[ ${version} == "9" ]]; then
			if [[ ${bit} == "x86_64" ]]; then
				kernel_version="4.9.0-4"
				installlot
			fi
		else
			echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		if [[ ${version} -ge "12" ]]; then
			if [[ ${bit} == "x86_64" ]]; then
				kernel_version="4.4.0-47"
				installlot
			elif [[ ${bit} == "i386" ]]; then
				kernel_version="3.13.0-29"
				installlot
			fi
		else
			echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	else
		echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi
}

#检查官方稳定内核并安装
check_sys_official() {
	check_version
	bit=$(uname -m)
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${bit} != "x86_64" ]]; then
			echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
		fi
		if [[ ${version} == "7" ]]; then
			yum install kernel kernel-headers -y --skip-broken
		elif [[ ${version} == "8" ]]; then
			yum install kernel kernel-core kernel-headers -y --skip-broken
		else
			echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		apt update
		if [[ ${bit} == "x86_64" ]]; then
			apt-get update && apt-get install linux-image-amd64 linux-headers-amd64 -y
		elif [[ ${bit} == "aarch64" ]]; then
			apt-get install linux-image-arm64 linux-headers-arm64 -y
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		apt update
		apt-get install linux-image-generic linux-headers-generic -y
	else
		echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
}

#检查官方最新内核并安装
check_sys_official_bbr() {
	check_version
	os_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
	os_version=$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release | tr -d '"')
	os_arch=$(uname -m)
	bit=$(uname -m)
	if [[ "${OS_type}" == "CentOS" ]]; then
		if [[ ${bit} != "x86_64" ]]; then
			echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
		fi
		rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
		if [[ ${version} == "7" ]]; then
			yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y
			yum --enablerepo=elrepo-kernel install kernel-ml kernel-ml-headers -y --skip-broken
		elif [[ ${version} == "8" ]]; then
			yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y
			yum --enablerepo=elrepo-kernel install kernel-ml kernel-ml-headers -y --skip-broken
		else
			echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		case ${os_version} in
		9)
			echo "deb http://deb.debian.org/debian stretch-backports main" >/etc/apt/sources.list.d/stretch-backports.list
			;;
		10)
			echo "deb http://deb.debian.org/debian buster-backports main" >/etc/apt/sources.list.d/buster-backports.list
			;;
		11)
			echo "deb http://deb.debian.org/debian bullseye-backports main" >/etc/apt/sources.list.d/bullseye-backports.list
			;;
		12)
			echo "deb http://deb.debian.org/debian bookworm-backports main" >/etc/apt/sources.list.d/bookworm-backports.list
			;;
		13)
			echo "deb http://deb.debian.org/debian trixie-backports main" >/etc/apt/sources.list.d/trixie-backports.list
			;;
		*)
			echo -e "[Error] 不支持当前系统 ${os_name} ${os_version} ${os_arch} !" && exit 1
			;;
		esac

		apt update
		if [[ ${os_arch} == "x86_64" ]]; then
			apt -t "$(lsb_release -cs)-backports" install \
				linux-image-amd64 \
				linux-headers-amd64 \
				-y
		elif [[ ${os_arch} =~ ^(arm|aarch64)$ ]]; then
			apt -t "$(lsb_release -cs)-backports" install \
				linux-image-arm64 \
				linux-headers-arm64 \
				-y
		else
			echo -e "[Error] 不支持当前系统架构 ${os_arch} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		echo -e "${Error} ubuntu不会写，你来吧" && exit 1
	else
		echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
}

#检查官方xanmod main内核并安装
check_sys_official_xanmod_main() {
	check_version
	wget -O check_x86-64_psabi.sh https://dl.xanmod.org/check_x86-64_psabi.sh
	chmod +x check_x86-64_psabi.sh
	cpu_level=$(./check_x86-64_psabi.sh | awk -F 'v' '{print $2}')
	echo -e "CPU supports \033[32m${cpu_level}\033[0m"
	# exit
	if [[ ${bit} != "x86_64" ]]; then
		echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	fi

	if [[ "${OS_type}" == "Debian" ]]; then
		apt update
		apt-get install gnupg gnupg2 gnupg1 sudo -y
		echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
		# --[ 已修改 ]-- 使用 gpg --dearmor 替换 apt-key
		wget -qO - https://dl.xanmod.org/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/xanmod-kernel.gpg
		if [[ "${cpu_level}" == "4" ]]; then
			apt update && apt install linux-xanmod-x64v3 -y
		elif [[ "${cpu_level}" == "3" ]]; then
			apt update && apt install linux-xanmod-x64v3 -y
		elif [[ "${cpu_level}" == "2" ]]; then
			apt update && apt install linux-xanmod-x64v2 -y
		else
			apt update && apt install linux-xanmod-x64v1 -y
		fi
	else
		echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
}

#检查官方xanmod lts内核并安装
check_sys_official_xanmod_lts() {
	check_version
	wget -O check_x86-64_psabi.sh https://dl.xanmod.org/check_x86-64_psabi.sh
	chmod +x check_x86-64_psabi.sh
	cpu_level=$(./check_x86-64_psabi.sh | awk -F 'v' '{print $2}')
	echo -e "CPU supports \033[32m${cpu_level}\033[0m"
	# exit
	if [[ ${bit} != "x86_64" ]]; then
		echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	fi

	if [[ "${OS_type}" == "Debian" ]]; then
		apt update
		apt-get install gnupg gnupg2 gnupg1 sudo -y
		echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
		# --[ 已修改 ]-- 使用 gpg --dearmor 替换 apt-key
		wget -qO - https://dl.xanmod.org/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/xanmod-kernel.gpg
		if [[ "${cpu_level}" == "4" ]]; then
			apt update && apt install linux-xanmod-lts-x64v3 -y
		elif [[ "${cpu_level}" == "3" ]]; then
			apt update && apt install linux-xanmod-lts-x64v3 -y
		elif [[ "${cpu_level}" == "2" ]]; then
			apt update && apt install linux-xanmod-lts-x64v2 -y
		else
			apt update && apt install linux-xanmod-lts-x64v1 -y
		fi
	else
		echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
}

#检查官方xanmod edge内核并安装
check_sys_official_xanmod_edge() {
	check_version
	wget -O check_x86-64_psabi.sh https://dl.xanmod.org/check_x86-64_psabi.sh
	chmod +x check_x86-64_psabi.sh
	cpu_level=$(./check_x86-64_psabi.sh | awk -F 'v' '{print $2}')
	echo -e "CPU supports \033[32m${cpu_level}\033[0m"
	# exit
	if [[ ${bit} != "x86_64" ]]; then
		echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	fi

	if [[ "${OS_type}" == "Debian" ]]; then
		apt update
		apt-get install gnupg gnupg2 gnupg1 sudo -y
		echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
		# --[ 已修改 ]-- 使用 gpg --dearmor 替换 apt-key
		wget -qO - https://dl.xanmod.org/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/xanmod-kernel.gpg
		if [[ "${cpu_level}" == "4" ]]; then
			apt update && apt install linux-xanmod-edge-x64v3 -y
		elif [[ "${cpu_level}" == "3" ]]; then
			apt update && apt install linux-xanmod-edge-x64v3 -y
		elif [[ "${cpu_level}" == "2" ]]; then
			apt update && apt install linux-xanmod-edge-x64v2 -y
		else
			apt update && apt install linux-xanmod-edge-x64v1 -y
		fi
	else
		echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
}

#检查官方xanmod rt内核并安装
check_sys_official_xanmod_rt() {
	check_version
	wget -O check_x86-64_psabi.sh https://dl.xanmod.org/check_x86-64_psabi.sh
	chmod +x check_x86-64_psabi.sh
	cpu_level=$(./check_x86-64_psabi.sh | awk -F 'v' '{print $2}')
	echo -e "CPU supports \033[32m${cpu_level}\033[0m"
	# exit
	if [[ ${bit} != "x86_64" ]]; then
		echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	fi

	if [[ "${OS_type}" == "Debian" ]]; then
		apt update
		apt-get install gnupg gnupg2 gnupg1 sudo -y
		echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
		# --[ 已修改 ]-- 使用 gpg --dearmor 替换 apt-key
		wget -qO - https://dl.xanmod.org/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/xanmod-kernel.gpg
		if [[ "${cpu_level}" == "4" ]]; then
			apt update && apt install linux-xanmod-rt-x64v3 -y
		elif [[ "${cpu_level}" == "3" ]]; then
			apt update && apt install linux-xanmod-rt-x64v3 -y
		elif [[ "${cpu_level}" == "2" ]]; then
			apt update && apt install linux-xanmod-rt-x64v2 -y
		else
			apt update && apt install linux-xanmod-rt-x64v1 -y
		fi
	else
		echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
}

#检查Zen官方内核并安装
check_sys_official_zen() {
	check_version
	if [[ ${bit} != "x86_64" ]]; then
		echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
	fi
	if [[ "${release}" == "debian" ]]; then
		curl 'https://liquorix.net/add-liquorix-repo.sh' | sudo bash
		apt-get install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y
	elif [[ "${release}" == "ubuntu" ]]; then
		if ! type add-apt-repository >/dev/null 2>&1; then
			echo 'add-apt-repository 未安装 安装中'
			apt-get install software-properties-common -y
		else
			echo 'add-apt-repository 已安装，继续'
		fi
		add-apt-repository ppa:damentz/liquorix && sudo apt-get update
		apt-get install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y
	else
		echo -e "${Error} 不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi

	BBR_grub
	echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功,默认从排第一的高版本内核启动"
}

#检查系统当前状态
check_status() {
	# 初始化变量，避免重复读取文件
	kernel_version=$(uname -r | awk -F "-" '{print $1}')
	kernel_version_full=$(uname -r)
	net_congestion_control=$(cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || echo "unknown")
	net_qdisc=$(cat /proc/sys/net/core/default_qdisc 2>/dev/null || echo "unknown")

	# 检测操作系统类型
	if [ -f /etc/redhat-release ]; then
		os_type="centos"
	elif [ -f /etc/debian_version ]; then
		os_type="debian"
	else
		os_type="unknown"
	fi

	# 检测内核类型
	if [[ "$kernel_version_full" == *bbrplus* ]]; then
		kernel_status="BBRplus"
	elif [[ "$kernel_version_full" =~ (4\.9\.0-4|4\.15\.0-30|4\.8\.0-36|3\.16\.0-77|3\.16\.0-4|3\.2\.0-4|4\.11\.2-1|2\.6\.32-504|4\.4\.0-47|3\.13\.0-29) ]]; then
		kernel_status="Lotserver"
	elif read major minor <<<$(echo "$kernel_version" | awk -F'.' '{print $1, $2}') &&
		{ [[ "$major" == "4" && "$minor" -ge 9 ]] || [[ "$major" == "5" ]] || [[ "$major" == "6" ]] || [[ "$major" == "7" ]]; }; then
		kernel_status="BBR"
	else
		kernel_status="noinstall"
	fi

	# 运行状态检测
	if [[ "$kernel_status" == "BBR" ]]; then
		case "$net_congestion_control" in
		"bbr")
			run_status="BBR启动成功"
			;;
		"bbr2")
			run_status="BBR2启动成功"
			;;
		"tsunami")
			if lsmod | grep -q "^tcp_tsunami"; then
				run_status="BBR魔改版启动成功"
			else
				run_status="BBR魔改版启动失败"
			fi
			;;
		"nanqinlang")
			if lsmod | grep -q "^tcp_nanqinlang"; then
				run_status="暴力BBR魔改版启动成功"
			else
				run_status="暴力BBR魔改版启动失败"
			fi
			;;
		*)
			run_status="未安装加速模块"
			;;
		esac
	elif [[ "$kernel_status" == "Lotserver" ]]; then
		if [[ -e /appex/bin/lotServer.sh ]]; then
			run_status=$(bash /appex/bin/lotServer.sh status | grep "LotServer" | awk '{print $3}')
			[[ "$run_status" == "running!" ]] && run_status="启动成功" || run_status="启动失败"
		else
			run_status="未安装加速模块"
		fi
	elif [[ "$kernel_status" == "BBRplus" ]]; then
		case "$net_congestion_control" in
		"bbrplus")
			run_status="BBRplus启动成功"
			;;
		"bbr")
			run_status="BBR启动成功"
			;;
		*)
			run_status="未安装加速模块"
			;;
		esac
	else
		run_status="未安装加速模块"
	fi

	# 检查 kernel-headers 或 kernel-devel（CentOS）/linux-headers（Debian/Ubuntu）状态
	if [[ "$os_type" == "centos" ]]; then
		installed_headers=$(rpm -qa | grep -E "kernel-devel|kernel-headers" | grep -v '^$' || echo "")
		if [[ -z "$installed_headers" ]]; then
			headers_status="未安装"
		else
			if echo "$installed_headers" | grep -q "kernel-devel-${kernel_version_full}\|kernel-headers-${kernel_version_full}"; then
				headers_status="已匹配"
			else
				headers_status="未匹配"
			fi
		fi
	elif [[ "$os_type" == "debian" ]]; then
		installed_headers=$(dpkg -l | grep -E "linux-headers|linux-image" | awk '{print $2}' | grep -v '^$' || echo "")
		if [[ -z "$installed_headers" ]]; then
			headers_status="未安装"
		else
			if echo "$installed_headers" | grep -q "linux-headers-${kernel_version_full}"; then
				headers_status="已匹配"
			else
				headers_status="未匹配"
			fi
		fi
	else
		headers_status="不支持的操作系统"
	fi

	# Brutal 状态检测
	brutal=""
	if lsmod | grep -q "brutal"; then
		brutal="brutal已加载"
	fi
}

#############系统检测组件#############
check_sys
check_version
[[ "${OS_type}" == "Debian" ]] && [[ "${OS_type}" == "CentOS" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
#check_github
start_menu
