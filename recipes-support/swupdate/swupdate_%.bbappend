FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/swupdate:"

FILES:${PN} += "/www/*"

SRC_URI += "file://swupdate-sysrestart.service \
	file://swupdate.cfg \
	file://swu_public.pem \
	file://0001-mongoose-enable-cgi.patch \
	file://sysinfo.cgi  \
"

FILES:${PN} += " \
	${systemd_system_unitdir}/swupdate-sysrestart.service \
"

RDEPENDS:${PN}-www += "bash"

SYSTEMD_SERVICE:${PN} += "swupdate-sysrestart.service"

do_install:append () {
	install -m 644 ${WORKDIR}/swupdate.cfg ${D}/${sysconfdir}
	install -m 644 ${WORKDIR}/swu_public.pem ${D}/${sysconfdir}

	install -m 644 ${WORKDIR}/swupdate-sysrestart.service ${D}${systemd_system_unitdir}
	install -m 0755 ${WORKDIR}/sysinfo.cgi ${D}/www/sysinfo.cgi
}

