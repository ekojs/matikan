## Matikan v1.0.1

### Shutdown/Reboot for LUKS Swap in Ubuntu


### Instructions How to Create Encrypted SWAP using LUKS Encryption

#### 1 - Setup LUKS Format to partitions. Ex : /dev/sda6 -> This is Extended Partition
```bash
sudo cryptsetup --verbose --verify-passphrase luksFormat /dev/sda6
sudo cryptsetup luksOpen /dev/sda6 sda6_crypt
```

#### 2 - Open up the partition and named it. Ex : sda6_crypt
```bash
sudo cryptsetup luksOpen /dev/sda6 sda6_crypt
```

#### 3 - Create swap and label it with 'swap'.
```bash
sudo mkswap -L swap /dev/mapper/sda6_crypt
```

#### 4 - Check your UUID for partition /dev/sda6. Write/Copy the UUID.
```bash
sudo blkid 
/dev/sda1: UUID="fcb1ff57-fbfe-4f5d-82bf-fc372cf53904" TYPE="ext4" PARTUUID="2ba375fb-01"
/dev/sda2: UUID="e87c4cc9-81cb-46ae-892d-15f6b1977bbc" TYPE="ext4" PARTUUID="2ba375fb-02"
/dev/sda5: UUID="59a8a751-8f78-49ad-81ac-383f6870588c" TYPE="crypto_LUKS" PARTUUID="2ba375fb-05"
/dev/sda6: UUID="b39babff-ccfb-47d2-bef7-576783659381" TYPE="crypto_LUKS" PARTUUID="2ba375fb-06"
```

#### 5 - Create/Update crypttab using your UUID
```bash
sudo vim /etc/crypttab
#sda6_crypt UUID=5b154575-4677-4573-8f97-80664da5b864 none luks,swap,discard
sda6_crypt UUID=b39babff-ccfb-47d2-bef7-576783659381 none luks,swap,discard
```

#### 6 - Add/Update fstab for your swap.
```bash
sudo vim /etc/fstab

# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda2 during installation
UUID=e87c4cc9-81cb-46ae-892d-15f6b1977bbc /               ext4    errors=remount-ro 0       1
# /boot was on /dev/sda1 during installation
UUID=fcb1ff57-fbfe-4f5d-82bf-fc372cf53904 /boot           ext4    defaults        0       2
/dev/mapper/sda6_crypt none            swap    sw              0       0
```

#### 7 - Check your LUKS Swap.
```bash
free -h
```

#### 8 - Update your initramfs.
```bash
sudo update-initramfs -u -k all
```



### Instructions How to use the program [`matikan.sh`](https://github.com/ekojs/matikan/blob/master/matikan.sh)

#### 1 - Use help argument or run the program without arguments for help menu'
```bash
./matikan.sh --help
```


#### 2 - Chmod and create symlink in /usr/bin
```bash
chmod +x matikan.sh

sudo ln -s /home/user/matikan.sh /usr/bin/matikan
```

 


#### Note:
For Indonesian check out at [`catatan swap`](https://github.com/ekojs/matikan/blob/master/catatan_swap.txt)
