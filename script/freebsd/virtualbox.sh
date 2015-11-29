#!/bin/sh -u

freebsd_major="`uname -r | awk -F. '{print $1}'`"

if [ "$PACKER_BUILDER_TYPE" = "virtualbox-iso" ]; then
    echo "==> Installing VirtualBox guest additions"

    # Disable X11 because vagrants are (usually) headless
    echo 'WITHOUT_X11="YES"' >> /etc/make.conf

    pkg install -y virtualbox-ose-additions;

    echo 'vboxdrv_load="YES"' >>/boot/loader.conf;
    echo 'vboxnet_enable="YES"' >>/etc/rc.conf;
    echo 'vboxguest_enable="YES"' >>/etc/rc.conf;
    echo 'vboxservice_enable="YES"' >>/etc/rc.conf;

    echo 'virtio_blk_load="YES"' >>/boot/loader.conf;
    if [ "$freebsd_major" -gt 9 ]; then
      # Appeared in FreeBSD 10
      echo 'virtio_scsi_load="YES"' >>/boot/loader.conf;
    fi
    echo 'virtio_balloon_load="YES"' >>/boot/loader.conf;
    echo 'if_vtnet_load="YES"' >>/boot/loader.conf;

    echo 'ifconfig_vtnet0_name="em0"' >>/etc/rc.conf;
    echo 'ifconfig_vtnet1_name="em1"' >>/etc/rc.conf;
    echo 'ifconfig_vtnet2_name="em2"' >>/etc/rc.conf;
    echo 'ifconfig_vtnet3_name="em3"' >>/etc/rc.conf;

    pw groupadd vboxusers;
    pw groupmod vboxusers -m vagrant;
fi
