# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils linux-mod versionator udev

MY_PN="${PN/-kmod}"
MY_PV="$(replace_version_separator 3 '-')"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Opensourced tools for VMware guests"
HOMEPAGE="http://open-vm-tools.sourceforge.net/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="vmhgfs"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	CONFIG_CHECK="~DRM_VMWGFX ~VMWARE_BALLOON ~VMWARE_PVSCSI ~VMXNET3
		!UIDGID_STRICT_TYPE_CHECKS"

	# See logic in configure.ac.
	local MODULES="vmxnet"

	use vmhgfs && MODULES+=" vmhgfs"

	if kernel_is -lt 3 9; then
		MODULES+=" vmci vsock"
	else
		CONFIG_CHECK+=" VMWARE_VMCI ~VMWARE_VMCI_VSOCKETS"
	fi

	if kernel_is -lt 3; then
		MODULES+=" vmblock vmsync"
	else
		CONFIG_CHECK+=" ~FUSE_FS"
	fi

	local mod
	for mod in ${MODULES}; do
		MODULE_NAMES+=" ${mod}(ovt:modules/linux/${mod})"
	done

	linux-mod_pkg_setup
}

src_prepare() {
    epatch "${FILESDIR}/0001-Remove-unused-DEPRECATED-macro.patch"
    epatch "${FILESDIR}/0002-Conditionally-define-g_info-macro.patch"
    epatch "${FILESDIR}/0003-Add-kuid_t-kgid_t-compatibility-layer.patch"
    epatch "${FILESDIR}/0004-Use-new-link-helpers.patch"
    epatch "${FILESDIR}/0005-Update-hgfs-file-operations-for-newer-kernels.patch"
    epatch "${FILESDIR}/0006-Fix-vmxnet-module-on-kernels-3.16.patch"
    epatch "${FILESDIR}/0007-Fix-vmhgfs-module-on-kernels-3.16.patch"
    epatch "${FILESDIR}/0008-Fix-segfault-in-vmhgfs.patch"
	epatch_user
}

src_configure() {
	BUILD_TARGETS="auto-build"
	export OVT_SOURCE_DIR="${S}"
	export LINUXINCLUDE="${KV_OUT_DIR}/include"
}

src_install() {
	linux-mod_src_install
	udev_dorules "${FILESDIR}/60-vmware.rules"
}