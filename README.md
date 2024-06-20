
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
