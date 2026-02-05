# @markers: build.zig
profile := "Debug"
dap_bin := "zig-out/bin/app"
dap_args := "--mode cpu"

build:
    zig build -Doptimize={{profile}}

run:
    zig build run -Doptimize={{profile}}

test:
    zig build test

clean:
    rm -rf zig-out/ zig-cache/
