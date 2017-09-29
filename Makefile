ROOT=$(abspath $(dir $(firstword $(MAKEFILE_LIST))))
ROOTFS=$(ROOT)/build/rootfs

.PHONY: all
all: busybox zlib dropbear tipcutils ethtool netperf strace iproute2 libteam \
	 tcpdump tests kernel

.PHONY: install
install: tftpboot tests

define SKEL_CP
build/rootfs/$(1): skel/$(1)
	cp skel/$(1) build/rootfs/$(1)
endef

define LIB_CP
build/rootfs/lib/x86_64-linux-gnu/$(1): /lib/x86_64-linux-gnu/$(1)
	cp /lib/x86_64-linux-gnu/$(1) build/rootfs/lib/x86_64-linux-gnu/$(1)
endef

define ROOTFS_MKDIR
build/rootfs/$(1):
	mkdir -p build/rootfs/$(1)
endef

skeldirs=kdump bin sys lib lib/x86_64-linux-gnu share home lib64 sbin tmp \
		 proc etc etc/dropbear etc/init.d etc/network include usr \
		 var var/run var/log var/tmp root dev dev/pts
$(info $(foreach i,$(skeldirs),$(eval $(call ROOTFS_MKDIR,$(i)))))

.PHONY: skeldirs
skeldirs: $(addprefix build/rootfs/,$(skeldirs))

skelfiles=root/.profile etc/dropbear/dropbear_rsa_host_key \
		  etc/dropbear/dropbear_dss_host_key etc/services etc/passwd \
		  etc/shadow etc/init.d/S01logging etc/init.d/S40network \
		  etc/init.d/S20nameif etc/init.d/rcS etc/init.d/S50ssh etc/inittab \
		  etc/host.conf etc/protocols etc/fstab etc/network/interfaces \
		  etc/network/udhcpc.sh etc/resolv.conf etc/init.d/S60kdump \
		  etc/mdev.conf etc/mactab root/setup_ftrace.sh sbin/tipc-config \
		  etc/init.d/S90netserver etc/init.d/S92tipc
$(info $(foreach i,$(skelfiles),$(eval $(call SKEL_CP,$(i)))))

.PHONY: skelfiles
skelfiles: $(addprefix build/rootfs/,$(skelfiles))

.PHONY: skel-install
skel-install: skeldirs skelfiles

libfiles=libc.so.6 libcrypt.so.1 libm.so.6 libdl.so.2 libnsl.so.1 \
		 libnss_compat.so.2 ld-linux-x86-64.so.2 libutil.so.1 \
		 libpthread.so.0 libnl-3.so.200 libnl-genl-3.so.200 \
		 librt.so.1 libmnl.so.0 libdaemon.so.0 libcrypto.so.1.0.0 \
		 libdb-5.3.so libselinux.so.1 libelf.so.1 libpcre.so.3 \
		 libgcc_s.so.1 libslang.so.2 liblzma.so.5 libbz2.so.1.0 libtinfo.so.5 \
		 libncurses.so.5

$(info $(foreach i,$(libfiles),$(eval $(call LIB_CP,$(i)))))

.PHONY: libfiles
libfiles: $(addprefix build/rootfs/lib/x86_64-linux-gnu/,$(libfiles))

build/rootfs:
	mkdir -p build/rootfs

build/rootfs/lib64/ld-linux-x86-64.so.2: build/rootfs/lib64
	cd build/rootfs/lib64 && ln -sf /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2

build/rootfs/lib/x86_64-linux-gnu/libdw.so.1:
	cp /usr/lib/x86_64-linux-gnu/libdw.so.1 $@

.PHONY: lib-install
lib-install: skeldirs libfiles build/rootfs/lib64/ld-linux-x86-64.so.2 \
			 build/rootfs/lib/x86_64-linux-gnu/libdw.so.1

src/busybox/.config: config/busybox
	cp -v $^ $@

.PHONY: busybox
busybox: src/busybox/.config
	yes '' | $(MAKE) -C src/busybox oldconfig

build/rootfs/bin/init:
	(cd build/rootfs && ln -fs bin/busybox init)

.PHONY: busybox-install
busybox-install: busybox build/rootfs/bin/init
	$(MAKE) -C src/busybox install

# This is a workaround for the makefile being version tracked in zlib
src/zlib/zlib.pc:
	(cd src/zlib && ./configure --prefix=$(ROOTFS))

.PHONY: zlib
zlib: src/zlib/zlib.pc
	$(MAKE) -C src/zlib

.PHONY: zlib-install
zlib-install: zlib
	$(MAKE) -C src/zlib install

src/dropbear/Makefile:
	(cd src/dropbear/ \
		&& autoconf \
		&& autoheader \
		&& ./configure --prefix=$(ROOTFS) --with-zlib=$(ROOTFS))

.PHONY: dropbear
dropbear: src/dropbear/Makefile
	$(MAKE) -C src/dropbear
	$(MAKE) -C src/dropbear scp

.PHONY: dropbear-install
# NOTE: scp isn't installed by the make install target
dropbear-install: dropbear build/rootfs/bin
	$(MAKE) -C src/dropbear install
	cp -v src/dropbear/scp build/rootfs/bin

src/tipcutils/Makefile: kernel-header-install
	(cd ./src/tipcutils \
		&& ./bootstrap \
		&& CPPFLAGS=-I$(ROOTFS)/usr/include ./configure --prefix=$(ROOTFS))

.PHONY: tipcutils
tipcutils: src/tipcutils/Makefile
	$(MAKE) -C src/tipcutils
	$(MAKE) -C src/tipcutils/demos

.PHONY: tipcutils-install
tipcutils-install: tipcutils src/tipcutils/Makefile
	$(MAKE) -C src/tipcutils install
	cp src/tipcutils/demos/benchmark/server_tipc build/rootfs/sbin/server_bench
	cp src/tipcutils/demos/benchmark/client_tipc build/rootfs/sbin/client_bench

src/ethtool/Makefile:
	(cd ./src/ethtool && ./autogen.sh && ./configure --prefix=$(ROOTFS))

.PHONY: ethtool
ethtool: src/ethtool/Makefile
	$(MAKE) -C src/ethtool

.PHONY: ethtool-install
ethtool-install: ethtool
	$(MAKE) -C src/ethtool install

src/netperf/Makefile:
	(cd ./src/netperf && ./autogen.sh && ./configure --prefix=$(ROOTFS))

.PHONY: netperf
netperf: src/netperf/Makefile
	$(MAKE) -C src/netperf

.PHONY: netperf-install
netperf-install: netperf
	$(MAKE) -C src/netperf install

src/strace/Makefile:
		(cd ./src/strace && ./bootstrap \
		&& ./configure --prefix=$(ROOTFS))

.PHONY: strace
strace: src/strace/Makefile
	$(MAKE) -C src/strace

.PHONY: strace-install
strace-install: strace
	$(MAKE) -C src/strace install

# Workaround for persistent makefile
src/iproute2/ip/ip:
	(cd ./src/iproute2 && ./configure)

.PHONY: iproute2
iproute2: src/iproute2/ip/ip
	$(MAKE) -C src/iproute2

.PHONY: iproute2-install
iproute2-install: iproute2
	DESTDIR=$(ROOTFS) $(MAKE) -C src/iproute2 install

src/libteam/Makefile:
	(cd ./src/libteam && ./autogen.sh && ./configure --prefix=$(ROOTFS))

.PHONY: libteam
libteam: src/libteam/Makefile
	$(MAKE) -C src/libteam

.PHONY: libteam-install
libteam-install: libteam
	$(MAKE) -C src/libteam install

src/libpcap/Makefile:
	(cd ./src/libpcap && ./configure --prefix=$(ROOTFS))

.PHONY: libpcap
libpcap: src/libpcap/Makefile
	$(MAKE) -C src/libpcap

.PHONY: libpcap-install
libpcap-install: libpcap
	$(MAKE) -C src/libpcap install

# We need libcap built into the rootfs in order to configure
src/tcpdump/Makefile: libpcap-install
	(cd ./src/tcpdump && ./configure --prefix=$(ROOTFS))

.PHONY: tcpdump
tcpdump: src/tcpdump/Makefile
	$(MAKE) -C src/tcpdump

.PHONY: tcpdump-install
tcpdump-install: tcpdump
	$(MAKE) -C src/tcpdump install

src/kexec-tools/Makefile:
	(cd src/kexec-tools && ./bootstrap)
	(cd src/kexec-tools && ./configure --prefix=$(ROOTFS))

.PHONY: kexec-tools
kexec-tools: src/kexec-tools/Makefile
	$(MAKE) -C src/kexec-tools

.PHONY: kexec-tools-install
kexec-tools-install: kexec-tools build/rootfs
	$(MAKE) -C src/kexec-tools install

.PHONY: tests
tests:
	$(MAKE) -C test/programs

linux/.config: config/kconfig
	cp -v $^ $@

.PHONY: kernel
kernel: linux/.config
	yes '' | $(MAKE) -C linux oldconfig
	$(MAKE) -C linux bzImage

kernel-tools: kernel skel-install
	$(MAKE) -C linux/tools perf
	cp linux/tools/perf/perf build/rootfs/sbin/ || :
	cp -H src/perf-tools/bin/* build/rootfs/sbin/
	cp -v /bin/bash build/rootfs/bin/

.PHONY: kernel-install
kernel-install: kernel kernel-tools
	$(MAKE) -C linux INSTALL_MOD_PATH=$(ROOTFS) modules
	$(MAKE) -C linux INSTALL_MOD_PATH=$(ROOTFS) modules_install

.PHONY: kernel-header-install
kernel-header-install: skel-install
	$(MAKE) -C linux INSTALL_HDR_PATH=$(ROOTFS)/usr headers_install

build/tftpboot:
	mkdir -p $@

build/tftpboot/pxelinux.cfg: build/tftpboot
	mkdir -p $@

build/tftpboot/pxelinux.0: tftp/pxelinux.0 build/tftpboot
	cp -v tftp/pxelinux.0 $@

.PHONY: info-install
info-install: build/rootfs
	./scripts/build-info.sh > build/rootfs/build.info

.PHONY: rootfs
rootfs: tcpdump-install kernel-install skel-install lib-install \
		busybox-install zlib-install dropbear-install tipcutils-install \
		ethtool-install netperf-install strace-install iproute2-install \
		libteam-install kexec-tools-install info-install
	rm -rf build/rootfs/usr/share/
	rm -rf build/rootfs/share/

build/tmp:
	mkdir -p $@

.PHONY: initramfs-kdump
initramfs-kdump: rootfs build/rootfs/kdump build/tmp
	rm -f $(ROOT)/build/rootfs/kdump/initramfs_kdump.cpio.gz
	(cd $(ROOTFS) && find . | cpio --owner 0:0 -H newc -o | \
		gzip -c > $(ROOT)/build/tmp/initramfs_kdump.cpio.gz)
	mv -v $(ROOT)/build/tmp/initramfs_kdump.cpio.gz \
		  $(ROOT)/build/rootfs/kdump/

.PHONY: kernel-kdump
kernel-kdump: kernel build/rootfs/kdump
	cp linux/arch/x86/boot/bzImage build/rootfs/kdump/

.PHONY: initramfs pxeconfig
ifdef NOKDUMP
pxeconfig: build/tftpboot/pxelinux.cfg
	cp -v tftp/pxelinux.cfg/default build/tftpboot/pxelinux.cfg/default

initramfs: rootfs kernel
	(cd $(ROOTFS) && find . | cpio --owner 0:0 -H newc -o | \
		gzip -c > $(ROOT)/build/tftpboot/initramfs.cpio.gz)
else
pxeconfig: build/tftpboot/pxelinux.cfg
	cp -v tftp/pxelinux.cfg/default_kdump build/tftpboot/pxelinux.cfg/default

initramfs: initramfs-kdump kernel-kdump
	(cd $(ROOTFS) && find . | cpio --owner 0:0 -H newc -o | \
		gzip -c > $(ROOT)/build/tftpboot/initramfs.cpio.gz)
endif

.PHONY: tftpboot
tftpboot: build/tftpboot pxeconfig build/tftpboot/pxelinux.0 initramfs
	cp linux/arch/x86/boot/bzImage build/tftpboot/vmlinuz

.PHONY: clean
clean:
	rm -rf build

.PHONY: linuxclean
linuxclean:
	git -C linux clean -dffx

.PHONY: deepclean
deepclean: clean
	$(MAKE) -C test/programs clean
	$(foreach sub,$(wildcard src/*),cd $(sub) ; make clean ; cd $$OLDPWD;)

.PHONY: gitclean
gitclean: deepclean
	git submodule foreach git checkout "*"
	git submodule foreach 'echo $$path | grep -v linux && git clean -dffx || true'
