FILESEXTRAPATHS_prepend := "${THISDIR}/files:${THISDIR}/swupdate:"

FILES_${PN} += "/www/*"

SRC_URI += "file://swupdate-sysrestart.service \
	file://swupdate.cfg \
	file://swu_public.pem \
	file://0001-mongoose-enable-cgi.patch \
    file://0002-add-sysinfo.cgi.patch  \
"

FILES_${PN} += " \
	${systemd_system_unitdir}/swupdate-sysrestart.service \
"

RDEPENDS_${PN}-www += "bash"

SYSTEMD_SERVICE_${PN} += "swupdate-sysrestart.service"

do_install:append () {
	install -m 644 ${WORKDIR}/swupdate.cfg ${D}/${sysconfdir}
	install -m 644 ${WORKDIR}/swu_public.pem ${D}/${sysconfdir}

	install -m 644 ${WORKDIR}/swupdate-sysrestart.service ${D}${systemd_system_unitdir}

	chmod 0755 ${D}/www/sysinfo.cgi
}

