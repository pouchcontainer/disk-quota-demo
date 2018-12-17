# PouchContainer DiskQuota Demo

[PouchContainer](https://github.com/alibaba/pouch) provides `diskquota` functionality
 to limit filesystem's disk usage. Before we use this feature, we need to build
 box environment for PouchContainer.

## Requirement

Diskquota in PouchContainer relies on kernel version and quota tools.

|| user/group quota | project quota|
|:---:| :----:| :---:|
|ext4| >= 2.6|>= 4.5|
|xfs|>= 2.6|>= 3.10|

The feature requires to format disk with quota attributes. We cannot format root
 partition because it is used by system. Therefore, we add the extra disk for
 the Vagrant box.

We provides vagrant box to build the whole demo environment. The user only need
 to download [vagrant](https://app.vagrantup.com) and [virtualbox](https://www.virtualbox.org/).

> NOTE: recommend to use latest version of vagrant and virtualbox.

## Get started

After you install the vagrant and virtualbox, use following script to setup

```
git clone https://github.com/pouchcontainer/disk-quota-demo
cd disk-quota-demo

# it will take a while to download ubuntu box
vagrant up
```

When the `vagrant up` command successfully, use `vagrant ssh` to login and check
 the block devices.

```
vagrant@vagrant:~$ lsblk
NAME                   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                      8:0    0   64G  0 disk
`-sda1                   8:1    0   64G  0 part
  |-vagrant--vg-root   253:0    0   63G  0 lvm  /
  `-vagrant--vg-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                      8:16   0   20G  0 disk /var/lib/pouch
```

The extra block device will be mounted at `/var/lib/pouch` because the PouchContainer
 uses the path as default root path.

```
vagrant@vagrant:~$ sudo dumpe2fs -h /dev/sdb | grep 'Filesystem features'
dumpe2fs 1.44.1 (24-Mar-2018)
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent 64bit flex_bg sparse_super large_file huge_file dir_nlink extra_isize quota metadata_csum project
```

And the `/dev/sdb` extra block device already has the `project` features. Now
 we can start simple demo.

## Only 10M Disk for a container

The vagrant provision has installed PouchContainer during `vagrant up`.

```
vagrant@vagrant:~$ sudo service pouch start

vagrant@vagrant:~$ sudo pouch version
KernelVersion:   4.15.0-29-generic
Os:              linux
Version:         1.0.1
APIVersion:      1.24
Arch:            amd64
BuildTime:       2018-11-23T02:46:58+00:00
GitCommit:       1.0.1
GoVersion:       go1.10.4
```

After pouch daemon started, we can use the following command to run container.

```
vagrant@vagrant:~$ sudo pouch run --disk-quota 10m -it busybox sh
/ # df -h
Filesystem                Size      Used Available Use% Mounted on
overlay                  10.0M     28.0K     10.0M   0% /
tmpfs                    64.0M         0     64.0M   0% /dev
/dev/sdb                 19.6G     46.4M     18.5G   0% /etc/hostname
/dev/sdb                 19.6G     46.4M     18.5G   0% /etc/hosts
/dev/sdb                 19.6G     46.4M     18.5G   0% /etc/resolv.conf
tmpfs                    64.0M         0     64.0M   0% /run
tmpfs                     1.9G         0      1.9G   0% /sys/fs/cgroup
tmpfs                    64.0M         0     64.0M   0% /proc/kcore
tmpfs                    64.0M         0     64.0M   0% /proc/timer_list
tmpfs                    64.0M         0     64.0M   0% /proc/sched_debug
tmpfs                     1.9G         0      1.9G   0% /sys/firmware
tmpfs                     1.9G         0      1.9G   0% /proc/scsi
```

The root path has been limited in `10M`. Then try to create file bigger than 10M.

```
/ # dd if=/dev/zero of=only10m bs=1G count=1
1+0 records in
0+0 records out
10452992 bytes (10.0MB) copied, 0.331497 seconds, 30.1MB/s
/ # echo $?
1
/ # ls -alh | grep only10m
-rw-r--r--    1 root     root       10.0M Dec 17 07:00 only10m
```

We can see that `dd` only create `10M` file because the disk quota is out of range.

## More detail

This repo is used to build one box with quota feature. If you aren't familiar
 with quota feature, please check the [link](https://github.com/alibaba/pouch/blob/master/docs/features/pouch_with_diskquota.md).
