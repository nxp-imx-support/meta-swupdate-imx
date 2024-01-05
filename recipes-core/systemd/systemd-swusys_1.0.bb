SUMMARY = "swupdate misc"
DESCRIPTION = "Use systemd service to implement the clean the upgrade_available, bootcount"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = " file://clrupstatus.service "
#S = "${WORKDIR}"

#RDEPENDS:${PN} = "systemd"


inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "clrupstatus.service"

SRC_URI:append = " file://clrupstatus.service "
FILES:${PN} += "${systemd_unitdir}/system/clrupstatus.service"

do_install:append() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/clrupstatus.service ${D}/${systemd_unitdir}/system
}
