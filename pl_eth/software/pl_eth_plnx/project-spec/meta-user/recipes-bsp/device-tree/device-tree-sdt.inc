SRC_URI:append = " file://system-conf.dtsi file://pl.dtsi"
EXTRA_OVERLAYS:append:linux = " system-user.dtsi pl-user.dtsi"
