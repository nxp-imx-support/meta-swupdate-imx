FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

FILES:${PN} += "/etc/*"
SRC_URI += " file://0001-imx8mm-enable-env_redunand-bootcount-limit-lf-6.1.36-2.1.0.patch \
             file://0002-imx8mm-default-env-lf-6.1.36-2.1.0.patch \
             file://0003-imx8qxp-enable-env_redunand-bootcount-limit-lf-6.1.36-2.1.0.patch \
             file://0004-imx8qxp-default-env-lf-6.1.36-2.1.0.patch \
             file://0005-imx93-enable-env_redunand-bootcount-limit-lf-6.1.36-2.1.0.patch \
             file://0006-imx93-default-env-lf-6.1.36-2.1.0.patch \
             file://0007-imx6ull-enable-env_redunand-bootcount-limit-lf-6.1.36-2.1.0.patch \
             file://0008-imx6ull-default-env-lf-6.1.36-2.1.0.patch"

SWU_HW_REV ?= "1.0"

do_install:append:mx93-nxp-bsp () {

    echo "/dev/mmcblk0 0x700000 0x4000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk0 0x704000 0x4000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision

}

do_install:append:mx8qxp-nxp-bsp () {

    echo "/dev/mmcblk1 0x700000 0x2000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk1 0x702000 0x2000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision

}

do_install:append:mx8mm-nxp-bsp () {

    echo "/dev/mmcblk1 0x700000 0x4000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk1 0x704000 0x4000" >> ${D}/${sysconfdir}/fw_env.config
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

