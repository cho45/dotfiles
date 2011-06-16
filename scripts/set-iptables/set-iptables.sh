#!/bin/sh

# SYN Flood 対策
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# ICMP Redirect 拒否
for i in /proc/sys/net/ipv4/conf/*/accept_redirects
do
	echo 0 > $i
done

echo "全てのチェインの内容を削除"
iptables -F
echo "組み込み済みチェイン以外を全て削除"
iptables -X
echo "すべてのチェインのパケットカウンタをゼロに"
iptables -Z

echo "ポリシーの設定"
iptables -P INPUT   ACCEPT
iptables -P OUTPUT  ACCEPT
iptables -P FORWARD DROP

echo "自ホストからのアクセスをすべて許可"
iptables -A INPUT -i lo -j ACCEPT

echo "LAN内の自ホストからのアクセスを全て許可"
iptables -A INPUT -j ACCEPT -s 192.168.0.1
iptables -A INPUT -j ACCEPT -s 192.168.0.2
iptables -A INPUT -j ACCEPT -s 192.168.0.3
iptables -A INPUT -j ACCEPT -s 192.168.0.4
iptables -A INPUT -j ACCEPT -s 192.168.0.250
iptables -A INPUT -j ACCEPT -s 192.168.0.251
iptables -A INPUT -j ACCEPT -s 192.168.0.252
iptables -A INPUT -j ACCEPT -s 192.168.0.253
iptables -A INPUT -j ACCEPT -s 192.168.11.1
iptables -A INPUT -j ACCEPT -s 192.168.0.7

#echo "使用するサービスのポートの設定"
#echo "    SSH"
#iptables -A INPUT -p tcp --sport 22 -j ACCEPT
#echo "    HTTP(S)"
#iptables -A INPUT -p tcp --sport 80 -j ACCEPT
#iptables -A INPUT -p tcp --sport 443 -j ACCEPT
#echo "    NTP"
#iptables -A INPUT -p udp --sport 123 -j ACCEPT
#echo "    IRC"
#iptables -A INPUT -p tcp --sport 6667 -j ACCEPT
#iptables -A INPUT -p tcp --sport 6668 -j ACCEPT

echo "1秒間に4回を超えるpingはログを記録して破棄"
iptables -N ping_of_death
iptables -A ping_of_death -m limit --limit 1/s --limit-burst 4 -j ACCEPT
iptables -A ping_of_death -j LOG --log-tcp-options --log-ip-options --log-prefix '[iptables#ping of death] : '
iptables -A ping_of_death -j DROP
iptables -A INPUT -p icmp --icmp-type echo-request -j ping_of_death

echo '/root/deny_ip に記述された IP を拒否'
echo "拒否IPアドレスは /root/deny_ip に1行ごとに記述しておくこと"
iptables -N deny_ip
iptables -A deny_ip -j LOG --log-tcp-options --log-ip-options --log-prefix '[iptables#deny ip] : '
iptables -A deny_ip -j DROP
if [ -s /root/deny_ip ]; then
	for ip in `cat /root/deny_ip`
	do
		iptables -I INPUT -s $ip -j deny_ip
	done
fi

echo "指定した国からのアクセスはログを記録して破棄"
echo "各国割当てIPアドレス情報はAPNIC ( http://www.apnic.net/ ) より最新版を取得"
# http://www.nsrc.org/codes/country-codes.html
COUNTRYLIST='CN KR US TW KP'
echo "Deny country: $COUNTRYLIST"
wget http://ftp.apnic.net/stats/apnic/delegated-apnic-latest
for country in $COUNTRYLIST
do
	echo "$country"
	for ip in `cat delegated-apnic-latest | grep "apnic|$country|ipv4|"`
	do
		FILTER_ADDR=`echo $ip |cut -d "|" -f 4`
		TEMP_CIDR=`echo $ip |cut -d "|" -f 5`
		FILTER_CIDR=32
		while [ $TEMP_CIDR -ne 1 ];
		do
			TEMP_CIDR=$((TEMP_CIDR/2))
			FILTER_CIDR=$((FILTER_CIDR-1))
		done
		iptables -I INPUT -s $FILTER_ADDR/$FILTER_CIDR -j deny_ip
	done
done
rm -f delegated-apnic-latest

echo 'SSH の設定 Brute Force Attak'
iptables -N block_ssh
iptables -F block_ssh
iptables -N ssh
iptables -F ssh
iptables -A INPUT -j ssh -p tcp --dport 22

echo "    /proc/net/ipt_recent/*"
iptables -A block_ssh -m recent --name block_ssh --set -j LOG --log-level DEBUG --log-prefix "[iptables#block ssh] : "
iptables -A block_ssh -j DROP

echo "    syn 以外のパッケットは許可"
iptables -A ssh -p tcp ! --syn -m state --state ESTABLISHED,RELATED -j ACCEPT
echo "    攻撃者は10分間拒否し続ける"
iptables -A ssh -p tcp --syn -m recent --name block_ssh --update --seconds 600 -j REJECT
echo "    1分間に5回アクセスがあった場合は攻撃者と見なす"
iptables -A ssh -p tcp --syn -m recent --name syn_ssh --rcheck --seconds 60  --hitcount 5 -j block_ssh
echo "    syn パケットを記録"
iptables -A ssh -p tcp --syn -m recent --name syn_ssh --set

iptables -A ssh -p tcp --syn -j ACCEPT

echo "サービスしているポートの設定"
echo "    SSH"
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
echo "    HTTP(S)"
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
echo "    NTP"
iptables -A INPUT -p udp --dport 123 -j ACCEPT
echo "    DNS"
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT

#echo "ドロップ予定をログ"
#iptables -A INPUT -m limit -j LOG --log-level DEBUG --log-prefix "[iptables#drop] : "

iptables-save > saved_iptables.cfg

echo "iptables-restore < saved_iptables.cfg"

