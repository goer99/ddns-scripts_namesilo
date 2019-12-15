include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts_namesilo
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPLv2
PKG_MAINTAINER:=Sky <icksky4@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=IP Addresses and Names
	TITLE:=DDNS extension for namesilo.com
	PKGARCH:=all
	DEPENDS:=+ddns-scripts +wget +openssl-util
endef

define Package/$(PKG_NAME)/description
	Dynamic DNS Client scripts extension for namesilo.com
endef

define Build/Configure
endef

define Build/Compile
	$(CP) ./*.sh $(PKG_BUILD_DIR)
endef

define Package/$(PKG_NAME)/preinst
	#!/bin/sh
	# if NOT run buildroot then stop service
	[ -z "$${IPKG_INSTROOT}" ] && /etc/init.d/ddns stop >/dev/null 2>&1
	exit 0 # suppress errors
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/update_namesilo.sh $(1)/usr/lib/ddns
endef

define Package/$(PKG_NAME)/postinst
	#!/bin/sh
	# remove old services file entries
	/bin/sed -i '/namesilo\.com/d' $${IPKG_INSTROOT}/etc/ddns/services >/dev/null 2>&1
	/bin/sed -i '/namesilo\.com/d' $${IPKG_INSTROOT}/etc/ddns/services_ipv6 >/dev/null 2>&1
	# and create new
	printf "%s\\t\\t%s\\n" '"namesilo.com"' '"update_namesilo.sh"' >> $${IPKG_INSTROOT}/etc/ddns/services
	printf "%s\\t\\t%s\\n" '"namesilo.com"' '"update_namesilo.sh"' >> $${IPKG_INSTROOT}/etc/ddns/services_ipv6
	# on real system restart service if enabled
	[ -z "$${IPKG_INSTROOT}" ] && {
		/etc/init.d/ddns enabled && \
			/etc/init.d/ddns start >/dev/null 2>&1
	}
	exit 0 # suppress errors
endef

define Package/$(PKG_NAME)/prerm
	#!/bin/sh
	# if NOT run buildroot then stop service
	[ -z "$${IPKG_INSTROOT}" ] && /etc/init.d/ddns stop >/dev/null 2>&1
	# remove services file entries
	/bin/sed -i '/namesilo\.com/d' $${IPKG_INSTROOT}/etc/ddns/services >/dev/null 2>&1
	/bin/sed -i '/namesilo\.com/d' $${IPKG_INSTROOT}/etc/ddns/services_ipv6 >/dev/null 2>&1
	exit 0 # suppress errors
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
