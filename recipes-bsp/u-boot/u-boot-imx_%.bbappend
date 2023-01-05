FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

FILES:${PN} += "/etc/*"
SRC_URI += " file://0001-enable-env_redunand-bootcount-limit-LF_v5.15.71-2.2.0.patch \
             file://0002-default-env-LF5.15.71-2.2.0.patch"

SWU_HW_REV ?= "1.0"

do_install:append:mx93-nxp-bsp () {

    echo "/dev/mmcblk0 0x400000 0x2000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk0 0x402000 0x2000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision

}

do_install:append:mx8qxp-nxp-bsp () {

    echo "/dev/mmcblk1 0x400000 0x2000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk1 0x402000 0x2000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision

}

do_install:append:mx8mm-nxp-bsp () {

    echo "/dev/mmcblk1 0x400000 0x2000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk1 0x402000 0x2000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision

}

do_install:append:mx6ull-nxp-bsp () {

    echo "/dev/mmcblk1 0xE0000 0x2000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk1 0xE2000 0x2000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision
}

do_deploy:append () {

     install -D -m 644  ${D}/${sysconfdir}/fw_env.config  ${DEPLOYDIR}
     install -D -m 644  ${D}/${sysconfdir}/hwrevision  ${DEPLOYDIR}

}

