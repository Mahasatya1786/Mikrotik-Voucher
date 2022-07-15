# jul/12/2022 16:37:14 by RouterOS 6.48.6
# software id = SCBA-B8JQ
#
# model = 751G-2HnD
# serial number = 2F7A012685C5
/interface bridge
add admin-mac=00:0C:42:FB:DD:73 auto-mac=no comment=defconf name=bridge
/interface ethernet
set [ find default-name=ether5 ] name=AP
set [ find default-name=ether1 ] name=Internet
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=20/40mhz-XX \
    country=indonesia disabled=no distance=indoors frequency=auto hide-ssid=\
    yes ht-supported-mcs="mcs-0,mcs-1,mcs-2,mcs-3,mcs-4,mcs-5,mcs-6,mcs-7,mcs-\
    8,mcs-9,mcs-10,mcs-11,mcs-12,mcs-13,mcs-14,mcs-15" installation=indoor \
    mode=ap-bridge ssid=MikroTik-FBDD77 wireless-protocol=802.11
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip hotspot profile
add dns-name=wifi.xyz hotspot-address=192.168.7.1 name=hsprof1
/ip hotspot user profile
set [ find default=yes ] name=Main on-login=\
    ":put (\",,1000,,,noexp,Disable,\")" parent-queue=none rate-limit=1M/1M
/ip pool
add name=default-dhcp ranges=192.168.88.10-192.168.88.254
add name=hs-pool-5 ranges=192.168.7.11-192.168.7.254
add name=dhcp_pool3 ranges=192.168.9.2-192.168.9.254
add name=dhcp_pool4 ranges=192.168.1.2-192.168.1.254
/ip dhcp-server
add address-pool=default-dhcp disabled=no interface=bridge name=defconf
add address-pool=hs-pool-5 disabled=no interface=AP lease-time=1h name=dhcp1
add address-pool=dhcp_pool4 disabled=no interface=ether4 name=dhcp2
/ip hotspot
add address-pool=hs-pool-5 disabled=no interface=AP name=hotspot1 profile=\
    hsprof1
/ip hotspot user profile
add address-pool=hs-pool-5 name=User on-login=":put (\",rem,1000,1h,1000,,Enab\
    le,\"); {:local date [ /system clock get date ];:local year [ :pick \$date\
    \_7 11 ];:local month [ :pick \$date 0 3 ];:local comment [ /ip hotspot us\
    er get [/ip hotspot user find where name=\"\$user\"] comment]; :local ucod\
    e [:pic \$comment 0 2]; :if (\$ucode = \"vc\" or \$ucode = \"up\" or \$com\
    ment = \"\") do={ /sys sch add name=\"\$user\" disable=no start-date=\$dat\
    e interval=\"1h\"; :delay 2s; :local exp [ /sys sch get [ /sys sch find wh\
    ere name=\"\$user\" ] next-run]; :local getxp [len \$exp]; :if (\$getxp = \
    15) do={ :local d [:pic \$exp 0 6]; :local t [:pic \$exp 7 16]; :local s (\
    \"/\"); :local exp (\"\$d\$s\$year \$t\"); /ip hotspot user set comment=\$\
    exp [find where name=\"\$user\"];}; :if (\$getxp = 8) do={ /ip hotspot use\
    r set comment=\"\$date \$exp\" [find where name=\"\$user\"];}; :if (\$getx\
    p > 15) do={ /ip hotspot user set comment=\$exp [find where name=\"\$user\
    \"];}; /sys sch remove [find where name=\"\$user\"]; [:local mac \$\"mac-a\
    ddress\"; /ip hotspot user set mac-address=\$mac [find where name=\$user]]\
    }}" parent-queue=none rate-limit=2M/2M
add add-mac-cookie=no address-pool=hs-pool-5 !keepalive-timeout \
    !mac-cookie-timeout name=uprof1
/tool user-manager customer
set admin access=\
    own-routers,own-users,own-profiles,own-limits,config-payment-gw
/interface bridge port
add bridge=bridge comment=defconf interface=ether2
add bridge=bridge comment=defconf interface=ether3
add bridge=bridge comment=defconf disabled=yes interface=ether4
add bridge=bridge comment=defconf disabled=yes interface=AP
add bridge=bridge comment=defconf interface=wlan1
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=Internet list=WAN
/ip address
add address=192.168.88.1/24 comment=defconf interface=bridge network=\
    192.168.88.0
add address=192.168.7.1/24 interface=AP network=192.168.7.0
add address=10.10.1.1/24 interface=ether4 network=10.10.1.0
/ip dhcp-client
add comment=defconf disabled=no interface=Internet
/ip dhcp-server network
add address=192.168.1.0/24 boot-file-name=pxelinux.0 comment="Net Boot" \
    dns-server=192.168.1.1,192.168.88.1,8.8.8.8 gateway=192.168.1.1 \
    next-server=192.168.1.23
add address=192.168.7.0/24 comment="hotspot network" gateway=192.168.7.1
add address=192.168.9.0/24 gateway=192.168.9.1
add address=192.168.88.0/24 boot-file-name=pxelinux.0 comment=defconf \
    gateway=192.168.88.1 next-server=192.168.88.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,192.168.1.1
/ip dns static
add address=192.168.88.1 comment=defconf name=router.lan
add address=192.168.9.254 name=server.cnf
add address=192.168.88.251 name=server.local
/ip firewall filter
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here"
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN
add action=accept chain=forward
add action=accept chain=forward
add action=accept chain=input dst-address-list=192.168.88.1 dst-port=80 \
    in-interface=Internet protocol=tcp src-address-list=192.168.1.128 \
    src-port=80
add action=accept chain=input dst-address=192.168.88.1 in-interface=Internet \
    protocol=tcp src-address=192.168.1.128
/ip firewall nat
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface-list=WAN
add action=masquerade chain=srcnat out-interface=Internet
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    src-address=192.168.7.0/24
/ip hotspot ip-binding
add address=192.168.7.254 mac-address=00:27:22:AA:0C:2C server=hotspot1 \
    to-address=192.168.7.254 type=bypassed
add address=192.168.7.3 mac-address=90:F6:52:6C:95:80 server=hotspot1 \
    to-address=192.168.7.3 type=bypassed
/ip hotspot user
add comment=vc-188-07.09.22- limit-uptime=5m name=ajik password=123
add comment=vc-188-07.09.22- disabled=yes limit-uptime=15m name=test4 \
    password=1234
add comment=vc-188-07.09.22- disabled=yes limit-uptime=10h name=test \
    password=1234
add comment=vc-874-07.12.22- limit-uptime=5m name=saap7388 password=saap7388
add comment=vc-874-07.12.22- limit-uptime=5m name=ggas2593 password=ggas2593
add comment=vc-874-07.12.22- limit-uptime=5m name=vccu2682 password=vccu2682
add comment=vc-874-07.12.22- limit-uptime=5m name=xeyn7469 password=xeyn7469
add comment=vc-874-07.12.22- limit-uptime=5m name=jhiu6577 password=jhiu6577
add comment=vc-874-07.12.22- limit-uptime=5m name=zebe4792 password=zebe4792
add comment=vc-874-07.12.22- limit-uptime=5m name=kpwp9927 password=kpwp9927
add comment=vc-874-07.12.22- limit-uptime=5m name=ngjt9825 password=ngjt9825
add comment=vc-874-07.12.22- limit-uptime=5m name=azng3242 password=azng3242
add comment=vc-874-07.12.22- limit-uptime=5m name=pkab6583 password=pkab6583
/ip tftp
add disabled=yes ip-addresses=192.168.88.0/24 real-filename=tftp/pxelinux.0 \
    req-filename=pxelinux.0
add disabled=yes ip-addresses=192.168.88.250 real-filename=tftp/pxelinux.0 \
    req-filename=pxelinux.0
add ip-addresses=192.168.88.0/24 real-filename=/tftp/memdisk req-filename=\
    memdisk
add ip-addresses=192.168.88.0/24 real-filename=/tftp/pxelinux.cfg/default \
    req-filename=pxelinux.cfg/default
add ip-addresses=192.168.88.0/24 real-filename=/tftp/bootmsg.txt \
    req-filename=bootmsg.txt
add ip-addresses=192.168.88.0/24 real-filename=/tftp/pxelinux.0 req-filename=\
    pxelinux.0
add ip-addresses=192.168.88.0/24 real-filename=/tftp/ldlinux.c32 \
    req-filename=ldlinux.c32
add ip-addresses=192.168.88.0/24 real-filename=/tftp/wimboot req-filename=\
    wimboot
add disabled=yes ip-addresses=192.168.88.0/24 real-filename=/MNT/boot.wim \
    req-filename=boot.wim
add ip-addresses=192.168.88.0/24 real-filename=/tftp/boot.sdi req-filename=\
    boot/boot.sdi
add ip-addresses=192.168.88.0/24 real-filename=/tftp/bcd req-filename=\
    boot/bcd
add allow-rollover=yes ip-addresses=192.168.88.0/24 real-filename=\
    /usb1/boot.wim req-filename=boot.wim
add ip-addresses=192.168.88.0/24 real-filename=/tftp/ipxe.lkrn req-filename=\
    ipxe.lkrn
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
add address=::224.0.0.0/100 comment="defconf: other" list=bad_ipv6
add address=::127.0.0.0/104 comment="defconf: other" list=bad_ipv6
add address=::/104 comment="defconf: other" list=bad_ipv6
add address=::255.0.0.0/104 comment="defconf: other" list=bad_ipv6
/ipv6 firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" port=\
    33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
/system clock
set time-zone-name=Asia/Jakarta
/system logging
add action=disk prefix=-> topics=hotspot,info,debug
/system ntp client
set enabled=yes primary-ntp=103.123.108.221 secondary-ntp=103.123.108.224
/system scheduler
add comment="Monitor Profile User" interval=2m41s name=User on-event=":local d\
    ateint do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\",\"j\
    un\",\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :pick\
    \_\$d 4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11 ];\
    :local monthint ([ :find \$montharray \$month]);:local month (\$monthint +\
    \_1);:if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\"\
    \$year\$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$da\
    ys\")];}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local minu\
    tes [ :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local date\
    \_[ /system clock get date ]; :local time [ /system clock get time ]; :loc\
    al today [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :for\
    each i in [ /ip hotspot user find where profile=\"User\" ] do={ :local com\
    ment [ /ip hotspot user get \$i comment]; :local name [ /ip hotspot user g\
    et \$i name]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comment \
    3] = \"/\" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d=\$\
    comment] ; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today an\
    d \$expt < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or (\$e\
    xpd = \$today and \$expt < \$curtime)) do={ [ /ip hotspot user remove \$i \
    ]; [ /ip hotspot active remove [find where user=\$name] ];}}}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=may/28/2022 start-time=04:24:55
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool user-manager database
set db-path=user-manager
