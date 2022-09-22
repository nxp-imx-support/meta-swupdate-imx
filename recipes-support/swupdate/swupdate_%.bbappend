FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/swupdate:"

FILES:${PN} += "/www/*"

SRC_URI += "file://swupdate-sysrestart.service \
	file://swupdate.cfg \
	file://swu_public.pem \
	file://0001-mongoose-enable-cgi.patch \
    file://0002-add-sysinfo.cgi.patch  \
"

FILES:${PN} += " \
	${systemd_system_unitdir}/swupdate-sysrestart.service \
"

RDEPENDS:${PN}-www += "bash"

SYSTEMD_SERVICE:${PN} += "swupdate-sysrestart.service"

python () {
    import re

    try:
        defconfig = bb.fetch2.localpath('file://defconfig', d)
    except bb.fetch2.FetchError:
        return

    try:
        configfile = open(defconfig)
    except IOError:
        return

    features = configfile.read()
    configfile.close()

    for current_fragment in find_cfgs(d):
        try:
            fragment_fd = open(current_fragment)
        except IOError:
            continue

        fragment = fragment_fd.read()
        fragment_fd.close()

        fragment_search = re.findall('^(?:# )?(CONFIG_[a-zA-Z0-9_]*)[= ].*\n?', fragment, re.MULTILINE)

        for feature in fragment_search:
            features = re.sub("^(?:# )?" + feature + "[= ].*\n?", "", features, flags=re.MULTILINE)

        features = features + fragment

    features = features.splitlines(True)


    depends = d.getVar('DEPENDS', False)

    if 'CONFIG_REMOTE_HANDLER=y\n' in features:
        depends += ' zeromq'

    if 'CONFIG_SSL_IMPL_OPENSSL=y\n' in features:
        depends += ' openssl'
    elif 'CONFIG_SSL_IMPL_MBEDTLS=y\n' in features:
        depends += ' mbedtls'
    elif 'CONFIG_SSL_IMPL_WOLFSSL=y\n' in features:
        depends += ' wolfssl'

    if 'CONFIG_JSON=y\n' in features:
        depends += ' json-c'

    if 'CONFIG_SYSTEMD=y\n' in features:
        depends += ' systemd'

    if 'CONFIG_ARCHIVE=y\n' in features:
        depends += ' libarchive'

    if 'CONFIG_LUA=y\n' in features:
        depends += ' lua'

    if 'CONFIG_UBOOT=y\n' in features:
        depends += ' libubootenv'

    if 'CONFIG_DOWNLOAD=y\n' in features or 'CONFIG_SURICATTA=y\n' in features:
        depends += ' curl'

    if 'CONFIG_MTD=y\n' in features or 'CONFIG_CFI=y\n' in features or 'CONFIG_UBIVOL=y\n' in features:
        depends += ' mtd-utils'

    if 'CONFIG_UCFWHANDLER=y\n' in features:
        depends += ' libgpiod'

    if 'CONFIG_SWUFORWARDER_HANDLER=y\n' in features:
        depends += ' curl libwebsockets uriparser'

    if 'CONFIG_RDIFFHANDLER=y\n' in features:
        depends += ' librsync'

    if 'CONFIG_BOOTLOADER_EBG=y\n' in features:
        depends += ' efibootguard'

    if 'CONFIG_ZSTD=y\n' in features:
        depends += ' zstd'

    if 'CONFIG_DISKPART=y\n' in features:
        depends += ' util-linux'

    d.setVar('DEPENDS', depends)

    if 'CONFIG_MONGOOSE=y\n' in features:
        d.setVar('SWUPDATE_MONGOOSE', 'true')
    else:
        d.setVar('SWUPDATE_MONGOOSE', 'false')

    if 'CONFIG_MONGOOSE_WEB_API_V2=y\n' in features:
        d.setVar('SWUPDATE_WWW', 'webapp')

    if 'CONFIG_SIGNED_IMAGES=y\n' in features:
        d.setVar('SWUPDATE_SIGNED_IMAGES', 'true')
    else:
        d.setVar('SWUPDATE_SIGNED_IMAGES', 'false')

    # Values not used here might be used in a bbappend
    d.setVar('SWUPDATE_SOCKET_CTRL_PATH', '/tmp/sockinstctrl')
    d.setVar('SWUPDATE_SOCKET_PROGRESS_PATH', '/tmp/swupdateprog')
    d.setVar('SWUPDATE_HW_COMPATIBILITY_FILE', '/etc/hwrevision')
    d.setVar('SWUPDATE_SW_VERSIONS_FILE', '/etc/sw-versions')
    for feature in features:
        if feature.startswith('CONFIG_SOCKET_CTRL_PATH='):
            ctrl_path = feature.split('=')[1].strip()
            d.setVar('SWUPDATE_SOCKET_CTRL_PATH', ctrl_path)
        elif feature.startswith('CONFIG_SOCKET_PROGRESS_PATH='):
            prog_path = feature.split('=')[1].strip()
            d.setVar('SWUPDATE_SOCKET_PROGRESS_PATH', prog_path)
        elif feature.startswith('CONFIG_HW_COMPATIBILITY_FILE='):
            hwrev_file = feature.split('=')[1].strip()
            d.setVar('SWUPDATE_HW_COMPATIBILITY_FILE', hwrev_file)
        elif feature.startswith('CONFIG_SW_VERSIONS_FILE='):
            swver_file = feature.split('=')[1].strip()
            d.setVar('SWUPDATE_SW_VERSIONS_FILE', swver_file)
}

do_install () {
	(cd ${S} && oe_runmake install)

    install -m 0755 -d ${D}/www
    if [ -d ${S}/web-app ];then
        cp -R --no-dereference --preserve=mode,links -v ${S}/examples/www/v2/* ${D}/www
    else
        install -m 0755 ${S}/www/* ${D}/www
    fi

    install -d ${D}${sysconfdir}/init.d
    install -m 755 ${WORKDIR}/swupdate ${D}${sysconfdir}/init.d
    sed -i -e "s|/usr/lib/|${libdir}/|" ${D}${sysconfdir}/init.d/swupdate

    # shell based configuration loader allows to place code snippets into this folder
    install -d ${D}${libdir}/swupdate/conf.d
    install -m 755 ${WORKDIR}/swupdate.sh ${D}${libdir}/swupdate
    sed -i 's#@LIBDIR@#${libdir}#g' ${D}${libdir}/swupdate/swupdate.sh
    if ${SWUPDATE_MONGOOSE}; then
        install -m 644 ${WORKDIR}/10-mongoose-args ${D}${libdir}/swupdate/conf.d/
    fi
    if ${SWUPDATE_SIGNED_IMAGES}; then
        install -m 644 ${WORKDIR}/swupdate.cfg ${D}/${sysconfdir}
        install -m 644 ${WORKDIR}/swu_public.pem ${D}/${sysconfdir}
    fi
    install -d ${D}${systemd_unitdir}/system
    install -m 644 ${WORKDIR}/swupdate.service ${D}${systemd_system_unitdir}
    sed -i 's#@LIBDIR@#${libdir}#' ${D}${systemd_system_unitdir}/swupdate.service
    install -m 644 ${WORKDIR}/swupdate-sysrestart.service ${D}${systemd_system_unitdir}
    install -m 644 ${WORKDIR}/swupdate.socket.tmpl ${D}${systemd_system_unitdir}/swupdate.socket
    sed -e "s,@@SWUPDATE_SOCKET_CTRL_PATH@@,${SWUPDATE_SOCKET_CTRL_PATH},g" \
        -e "s,@@SWUPDATE_SOCKET_PROGRESS_PATH@@,${SWUPDATE_SOCKET_PROGRESS_PATH},g" \
        -i ${D}${systemd_system_unitdir}/swupdate.socket
    install -m 644 ${WORKDIR}/swupdate-usb@.service ${D}${systemd_system_unitdir}
    install -m 644 ${WORKDIR}/swupdate-progress.service ${D}${systemd_system_unitdir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${libdir}/tmpfiles.d
        install -m 0644 ${WORKDIR}/tmpfiles-swupdate.conf ${D}${libdir}/tmpfiles.d/swupdate.conf
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${WORKDIR}/swupdate-usb.rules ${D}${sysconfdir}/udev/rules.d/
    else
        # in case of systemd there is a service file, for sysv init we need to start it as well
        install -m 0644 ${WORKDIR}/90-start-progress ${D}${libdir}/swupdate/conf.d/
    fi

     chmod 0755 ${D}/www/sysinfo.cgi
}
