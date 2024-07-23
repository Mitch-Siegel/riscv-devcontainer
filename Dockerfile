# TODO: newer ubuntu?
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    qemu-system-riscv64 \
    xz-utils \
    u-boot-qemu

RUN mkdir /image
WORKDIR /image
RUN wget https://gitlab.com/api/v4/projects/giomasce%2Fdqib/jobs/artifacts/master/download?job=convert_riscv64-virt -O ./debian-rv64.zip
RUN unzip ./debian-rv64.zip
RUN ls -ltr

RUN wget https://github.com/riscv-software-src/opensbi/releases/download/v1.5/opensbi-1.5-rv-bin.tar.xz
RUN ls -ltr
RUN tar -xvf ./opensbi-1.5-rv-bin.tar.xz
RUN ls -ltr

RUN dd if=/dev/zero of=fw_jump.img bs=1M count=32

ENTRYPOINT [ "qemu-system-riscv64" ]
CMD [ "-machine", "virt", \
      "-cpu", "rv64", \
      "-m", "1G", \
      "-device", "virtio-net-device,netdev=net", \
      "-netdev", "user,id=net,hostfwd=tcp::2222-:22", \
      "-device", "virtio-blk-device,drive=hd", \
      "-drive", "file=./dqib_riscv64-virt/image.qcow2,if=none,id=hd,format=qcow2", \
      "-kernel", "/usr/lib/u-boot/qemu-riscv64_smode/uboot.elf", \
      "-append", "root=LABEL=rootfs console=ttyS0", \
      "-nographic" ]




    #   "-fsdev", "local,security_model=passthrough,id=fsdev0,path=./riscv-deb-share", \
    #   "-device", "virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare"
      