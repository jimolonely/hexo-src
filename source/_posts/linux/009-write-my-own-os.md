---
title: 写自己的操作系统1
tags:
  - linux
p: linux/009-write-my-own-os
date: 2018-04-02 10:04:45
---
从零写自己的操作系统.

# 前提
来自youtube上一位腼腆的牛人推出的[视频](http://wyoos.org/).

# 目标
完成一个自己的系统的iso文件,在屏幕上打印一句话,效果如下:

{% asset_img 000.png %}

# 技术栈
1. makefle
2. ASM汇编
3. 链接
4. C++

# 代码
types.h: 声明数据类型
```cpp
#ifndef __TYPES_H
#define __TYPES_H

    typedef char                     int8_t;
    typedef unsigned char           uint8_t;
    typedef short                   int16_t;
    typedef unsigned short         uint16_t;
    typedef int                     int32_t;
    typedef unsigned int           uint32_t;
    typedef long long int           int64_t;
    typedef unsigned long long int uint64_t;
    
#endif
```
kernel.cpp:打印逻辑
```cpp
#include "types.h"

void printf(char* str)
{
    static uint16_t* VideoMemory = (uint16_t*)0xb8000;

    for(int i = 0; str[i] != '\0'; ++i)
        VideoMemory[i] = (VideoMemory[i] & 0xFF00) | str[i];
}

typedef void (*constructor)();
extern "C" constructor start_ctors;
extern "C" constructor end_ctors;
extern "C" void callConstructors()
{
    for(constructor* i = &start_ctors; i != &end_ctors; i++)
        (*i)();
}

extern "C" void kernelMain(const void* multiboot_structure, uint32_t /*multiboot_magic*/)
{
    printf("Hello World! --- jimo - OS1");

    while(1);
}
```
loader.s:从硬件启动
```asm
.set MAGIC, 0x1badb002
.set FLAGS, (1<<0 | 1<<1)
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
    .long MAGIC
    .long FLAGS
    .long CHECKSUM


.section .text
.extern kernelMain
#.extern callConstructors
.global loader


loader:
    mov $kernel_stack, %esp
    call callConstructors
    push %eax
    push %ebx
    call kernelMain


_stop:
    cli
    hlt
    jmp _stop


.section .bss
.space 2*1024*1024; # 2 MiB
kernel_stack:
```
linker.ld:用于链接,手写
```link
ENTRY(loader)
OUTPUT_FORMAT(elf32-i386)
OUTPUT_ARCH(i386:i386)

SECTIONS
{
  . = 0x0100000;

  .text :
  {
    *(.multiboot)
    *(.text*)
    *(.rodata)
  }

  .data  :
  {
    start_ctors = .;
    KEEP(*( .init_array ));
    KEEP(*(SORT_BY_INIT_PRIORITY( .init_array.* )));
    end_ctors = .;

    *(.data)
  }

  .bss  :
  {
    *(.bss)
  }

  /DISCARD/ : { *(.fini_array*) *(.comment) }
}
```
makefile:方便make
```makefile
GCCPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = loader.o kernel.o



%.o: %.cpp
	gcc $(GCCPARAMS) -c -o $@ $<

%.o: %.s
	as $(ASPARAMS) -o $@ $<

mykernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

install: mykernel.bin
	sudo cp $< /boot/mykernel.bin

mykernel.iso: mykernel.bin
	rm -rf iso
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp mykernel.bin iso/boot/mykernel.bin
	echo 'set timeout=0'                      > iso/boot/grub/grub.cfg
	echo 'set default=0'                     >> iso/boot/grub/grub.cfg
	echo ''                                  >> iso/boot/grub/grub.cfg
	echo 'menuentry "My Operating System" {' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/mykernel.bin'    >> iso/boot/grub/grub.cfg
	echo '  boot'                            >> iso/boot/grub/grub.cfg
	echo '}'                                 >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=mykernel.iso iso
	rm -rf iso

run: mykernel.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm 'my-os' &
```
# 编译与链接
1.编译cpp
```shell
$ make kernel.o
gcc -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore -c -o kernel.o kernel.cpp
kernel.cpp: 在函数‘void kernelMain(const void*, uint32_t)’中:
kernel.cpp:26:41: 警告：ISO C++ forbids converting a string constant to ‘char*’ [-Wwrite-strings]
     printf("Hello World! --- jimo - OS1");
```
2.编译loader
```shell
$ make loader.o
as --32 -o loader.o loader.s
loader.s: Assembler messages:
loader.s: 警告：end of file not at end of a line; newline inserted
```
3.链接
```shell
$ make mykernel.bin
gcc -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore -c -o kernel.o kernel.cpp
kernel.cpp: 在函数‘void kernelMain(const void*, unsigned int)’中:
kernel.cpp:24:41: 警告：ISO C++ forbids converting a string constant to ‘char*’ [-Wwrite-strings]
     printf("Hello World! --- jimo - OS1");
                                         ^
ld -melf_i386 -T linker.ld -o mykernel.bin loader.o kernel.o
```
4.制作ISO文件
```shell
$ make mykernel.iso
rm -rf iso
mkdir iso
mkdir iso/boot
mkdir iso/boot/grub
cp mykernel.bin iso/boot/mykernel.bin
echo 'set timeout=0'                      > iso/boot/grub/grub.cfg
echo 'set default=0'                     >> iso/boot/grub/grub.cfg
echo ''                                  >> iso/boot/grub/grub.cfg
echo 'menuentry "My Operating System" {' >> iso/boot/grub/grub.cfg
echo '  multiboot /boot/mykernel.bin'    >> iso/boot/grub/grub.cfg
echo '  boot'                            >> iso/boot/grub/grub.cfg
echo '}'                                 >> iso/boot/grub/grub.cfg
grub-mkrescue --output=mykernel.iso iso
xorriso 1.4.8 : RockRidge filesystem manipulator, libburnia project.

Drive current: -outdev 'stdio:mykernel.iso'
Media current: stdio file, overwriteable
Media status : is blank
Media summary: 0 sessions, 0 data blocks, 0 data, 25.7g free
Added to ISO image: directory '/'='/tmp/grub.lWPSfY'
xorriso : UPDATE : 633 files added in 1 seconds
Added to ISO image: directory '/'='/home/jimo/workspace/temp/os/iso'
xorriso : UPDATE : 637 files added in 1 seconds
xorriso : NOTE : Copying to System Area: 512 bytes from file '/usr/lib/grub/i386-pc/boot_hybrid.img'
ISO image produced: 8831 sectors
Written to medium : 8831 sectors at LBA 0
Writing to 'stdio:mykernel.iso' completed successfully.

rm -rf iso
```

如果这一步出现错误,比如没有xorriso,那么请安装[libisoburn](https://dev.lovelyhq.com/libburnia)
```shell
grub-mkrescue --output=mykernel.iso iso
grub-mkrescue：错误： xorriso not found.
```

这时当前目录下有iso文件了:

{% asset_img 001.png %}

5.导入虚拟机新建就ok了.

