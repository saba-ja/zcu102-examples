FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://platform-top.h file://bsp.cfg"
SRC_URI += "file://user_2024-06-20-01-17-00.cfg \
            file://user_2024-06-20-01-46-00.cfg \
            "

