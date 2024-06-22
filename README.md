
## Assign IP to ethx
```
ifconfig eth0 192.168.1.11 netmask 255.255.255.0 up
ifconfig eth1 192.168.1.12 netmask 255.255.255.0 up
```

## Clean up the PetaLinux folder
To clean the entire build directory, removing all compiled files but keeping your configuration intact, use the following:

```shell
petalinux-build -x mrproper
```

https://support.xilinx.com/s/question/0D52E00006hpN4rSAE/how-to-update-devicetree-in-petalinux-20192?language=en_US

    petalinux-build -c device-tree -x cleansstate
    petalinux-build -c device-tree
    petalinux-build -c kernel -x distclean
    petalinux-build -c kernel


https://support.xilinx.com/s/question/0D52E00006hpmy0SAA/accepted-process-for-modifying-pldtsi-with-device-tree-overlays?language=en_US

```
/*
/include/ "pl.dtsi"

/ {
        fragment@2 {
                target = <&amba>;
                overlay2: __overlay__ {
                        xxv_ethernet_10g: ethernet@a0020000 {
                                local-mac-address = [00 0a 35 00 01 22];
                        };
                        xxv_ethernet_10g_1: ethernet@a0030000 {
                                local-mac-address = [00 0a 35 00 01 23];
                        };
                };
        };
};
*/

```
