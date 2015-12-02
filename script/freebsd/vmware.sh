#!/bin/sh -u

HOME_DIR=${SSH_USER_HOME:-/home/${SSH_USERNAME}}

if [ "$PACKER_BUILDER_TYPE" = "vmware-iso" ]; then
    echo "==> Installing VMware Tools";
     # Install Perl and other software needed by vmware-install.pl
    pkg install -y perl5;
    pkg install -y compat6x-`uname -m`;
    # the install script is very picky about location of perl command
    ln -s /usr/local/bin/perl /usr/bin/perl;

    mkdir -p /tmp/vmfusion;
    mkdir -p /tmp/vmfusion-archive;
    mdconfig -a -t vnode -f $HOME_DIR/freebsd.iso -u 0;
    mount -t cd9660 /dev/md0 /tmp/vmfusion;
    tar xzf /tmp/vmfusion/vmware-freebsd-tools.tar.gz -C /tmp/vmfusion-archive;
    /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default;
    echo 'ifconfig_vxn0="dhcp"' >>/etc/rc.conf;
    umount /tmp/vmfusion;
    rm -rf /tmp/vmfusion;
    rm -rf /tmp/vmfusion-archive;
    rm -f $HOME_DIR/*.iso;

    rm -f /usr/bin/perl;

    VMWARE_TOOLBOX_CMD_VERSION=$(vmware-toolbox-cmd -v)
    echo "==> Installed VMware Tools ${VMWARE_TOOLBOX_CMD_VERSION}";
fi
