Minimalistic bootloader for x86-64.

```shell
nasm -f bin boot.asm -o boot.bin
qemu-system-x86_64 -drive file=boot.bin,format=raw
```

![](bootloader.png)
