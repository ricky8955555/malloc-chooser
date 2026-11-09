# malloc-chooser

A small project designed to build a dynamic library used to pick *mimalloc* as the memory allocator when no other allocator (such as *jemalloc*) dynamic-linked.

Of course, you can replace the malloc implementation with your own preference.

Now the project is only designed for *x86* and *x86_64* linux machines.

## Build and Install

You need to prepare *[Zig](https://ziglang.org/)* 0.16 for compilation and *[Just](https://github.com/casey/just)* for running script.

Build the library:

```shell
just build                                            # Build native library
ZIG_EXECUTABLE=/bin/zig ARCH=x86 ABI=musl just build  # Build x86 musl library with specific zig executable
```

Install the library system-wide:

```shell
sudo just install                               # Install native library into /usr/local/$LIB
sudo PREFIX="/" ARCH=x86 ABI=musl just install  # Install x86 musl library into /lib
```

## Usage

Select one of your preference from below:

### 1. Use `LD_PRELOAD`

You can use `LD_PRELOAD` environ to inject the library into your program:

```shell
LD_PRELOAD=/usr/local/$LIB/libmalloc_chooser.so ./your_program
```

Or write the environment to file like `bashrc` to make it work globally:

```shell
export LD_PRELOAD="${LD_PRELOAD} /usr/local/$LIB/libmalloc_chooser.so"
```

### 2. Write to `/etc/ld.so.preload`

You can write the library into `/etc/ld.so.preload` to make it work globally:

```shell
echo "/usr/local/$LIB/libmalloc_chooser.so" >> /etc/ld.so.preload
```
