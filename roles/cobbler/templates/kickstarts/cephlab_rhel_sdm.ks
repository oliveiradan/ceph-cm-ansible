## {{ ansible_managed }}
## This kickstart for use with systems where /dev/sdm is the root drive (e.g., mero)
# kickstart template for Fedora 8 and later.
# (includes %end blocks)
# do not use with earlier distros

#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
#set os_version = $getVar('os_version','')
# Partition clearing information
clearpart --all --initlabel
# Use all of /dev/sdm for the root partition (20G minimum)
part / --fstype="ext4" --ondisk=sdm --size=20000 --grow
# Clear the Master Boot Record
zerombr
# System bootloader configuration
#if $os_version == 'rhel7'
    #set bootloader_args = "--location=mbr --boot-drive=sdm"
#else
    #set bootloader_args = "--location=mbr --driveorder=sdm"
#end if
bootloader $bootloader_args
# Use text mode install
text
# Firewall configuration
firewall --enabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
network --bootproto=dhcp --device=$mac_address_eth0 --onboot=on
# Reboot after installation
reboot

#Root password
rootpw --iscrypted $default_password_crypted
# SELinux configuration
#set distro = $getVar('distro','').split("-")[0]
#set distro_ver = $getVar('distro','').split("-")[1]
#if $distro == 'RHEL'
#set distro_ver = $distro_ver.split(".")[0]
#end if
#if int($distro_ver) == 8
selinux --disabled
#else
selinux --permissive
#end if
# Do not configure the X Window System
skipx
# System timezone
timezone Etc/UTC --utc
# Install OS instead of upgrade
install

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
@core
$SNIPPET('cephlab_packages_rhel')
$SNIPPET('func_install_if_enabled')
%end

%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('cephlab_hostname')
$SNIPPET('cephlab_user')
#set distro = $getVar('distro','').split("-")[0]
#if $distro == 'RHEL'
$SNIPPET('cephlab_rhel_rhsm')
#end if
# Update to latest kernel before rebooting
yum -y update kernel
$SNIPPET('cephlab_rc_local')
$SNIPPET('kickstart_done')
# End final steps
%end
