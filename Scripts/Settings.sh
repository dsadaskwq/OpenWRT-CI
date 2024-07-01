#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE

if [[ $WRT_URL == *"lede"* ]]; then
	LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
	#修改默认时间格式
	sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $LEDE_FILE
	#添加编译日期标识
	sed -i "s/(\(<%=pcdata(ver.luciversion)%>\))/\1 \/ $WRT_REPO-$WRT_DATE/g" $LEDE_FILE
	#修改默认WIFI名
	sed -i "s/ssid=.*/ssid=$WRT_WIFI/g" ./package/kernel/mac80211/files/lib/wifi/mac80211.sh
        #修改默认wifi国家 CN/US/AU
	sed -i "s/country=.*/country=CN/g" ./package/kernel/mac80211/files/lib/wifi/mac80211.sh
else
	#修改默认wifi国家 CN/US/AU
        sed -i "/set \${s}\.type='mac80211'/a set \${s}\.country='CN'" $(find ./package/network/config/wifi-scripts/files/lib/wifi/ -type f -name "mac80211.*")
        #修改默认WIFI名
	sed -i "s/ssid=.*/ssid='$WRT_WIFI'/g" $(find ./package/network/config/wifi-scripts/files/lib/wifi/ -type f -name "mac80211.*")
	#修改immortalwrt.lan关联IP
	sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
	#添加编译日期标识
	sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_REPO-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
        #部分插件调整到nas 网络储存 
        sed -i 's/services/nas/g' ./package/luci-app-aliyundrive-webdav/luasrc/controller/*.lua
        sed -i 's/services/nas/g' ./package/luci-app-aliyundrive-webdav/luasrc/view/aliyundrive-webdav/*.htm
        sed -i 's/services/nas/g' ./package/luci-app-aliyundrive-webdav/luasrc/controller/*.lua
        sed -i 's/services/nas/g' ./package/luci-app-aliyundrive-webdav/luasrc/view/aliyundrive-webdav/*.htm
        sed -i 's/services/nas/g' ./package/feeds/luci/luci-app-wol/root/usr/share/luci/menu.d/luci-app-wol.json
        sed -i 's/services/nas/g' ./package/feeds/luci/luci-app-ksmbd/root/usr/share/luci/menu.d/luci-app-ksmbd.json
        sed -i 's/services/nas/g' ./package/feeds/luci/luci-app-qbittorrent/root/usr/share/luci/menu.d/luci-app-qbittorrent.json
	#部分插件调整到vpn
        sed -i 's/services/vpn/g' ./package/feeds/luci/luci-app-uugamebooster/luasrc/controller/*.lua
        sed -i 's/services/vpn/g' ./package/feeds/luci/luci-app-uugamebooster/luasrc/view/uugamebooster/*.htm
        #修改upnp插件名
	sed -i 's/msgstr "UPnP IGD 和 PCP\/NAT-PMP"/msgstr "UPnP"/' ./package/feeds/luci/luci-app-upnp/po/zh_Hans/upnp.po
    
fi

#默认主题修改
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
#echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-advancedplus=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo "$WRT_PACKAGE" >> ./.config
fi

#科学插件设置
if [[ $WRT_URL == *"lede"* ]]; then
	echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> ./.config
else
	echo "CONFIG_PACKAGE_luci=y" >> ./.config
	echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
        echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ./.config

fi
#修改Tiny Filemanager汉化
if [ -d "./package/luci-app-tinyfilemanager" ]; then
	PO_FILE="./package/luci-app-tinyfilemanager/po/zh_Hans/tinyfilemanager.po"
	sed -i '/msgid "Tiny File Manager"/{n; s/msgstr.*/msgstr "文件管理器"/}' $PO_FILE
	sed -i 's/启用用户验证/用户验证/g;s/家目录/初始目录/g;s/Favicon 路径/收藏夹图标路径/g;s/存储//g' $PO_FILE

	echo "tinyfilemanager date has been updated!"
fi

