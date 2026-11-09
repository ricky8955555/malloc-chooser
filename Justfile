default := "build"

zig := env("ZIG_EXECUTABLE", "zig")

arch := env("ARCH", `uname -m`)
lib := if arch == "x86" {
    "lib"
} else if arch == "x86_64" {
    "lib64"
} else {
    error("Unsupported CPU architecture.")
}
abi := env("ABI", `ldd --version 2>&1 | head -n1 | grep -qi musl && echo "musl" || echo "gnu"`)

prefix := env("PREFIX", "/usr/local/")

[arg("optimize", pattern="Debug|ReleaseSafe|ReleaseFast|ReleaseSmall")]
build optimize="ReleaseSmall":
    mkdir -p out
    {{zig}} build-lib -target {{arch}}-linux-{{abi}} -O{{optimize}} -dynamic -lc malloc_chooser.zig
    mv libmalloc_chooser.so out/libmalloc_chooser-{{arch}}-{{abi}}.so

install:
    install out/libmalloc_chooser-{{arch}}-{{abi}}.so {{prefix}}{{lib}}/libmalloc_chooser.so
