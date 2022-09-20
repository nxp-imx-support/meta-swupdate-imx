FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

FILES_${PN} += "/etc/*"
SRC_URI += " file://0001-enable-env_redunand-bootcount-limit-LF_v5.10.9-1.0.0.patch \
             file://0002-default-env-LF_v5.10.9-1.0.0.patch "

SWU_HW_REV ?= "1.0"

do_install_append_mx8qxp () {

    echo "/dev/mmcblk1 0x400000 0x2000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk1 0x402000 0x2000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision

}

do_install_append_mx8mm () {

    echo "/dev/mmcblk1 0x400000 0x2000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk1 0x402000 0x2000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision

}

do_install_append_mx6ull () {

    echo "/dev/mmcblk1 0xE0000 0x2000" > ${D}/${sysconfdir}/fw_env.config
    echo "/dev/mmcblk1 0xE2000 0x2000" >> ${D}/${sysconfdir}/fw_env.config
    echo "${MACHINE} ${SWU_HW_REV}" > ${D}/${sysconfdir}/hwrevision
}

do_deploy_append () {

     install -D -m 644  ${D}/${sysconfdir}/fw_env.config  ${DEPLOYDIR}
     install -D -m 644  ${D}/${sysconfdir}/hwrevision  ${DEPLOYDIR}

}

