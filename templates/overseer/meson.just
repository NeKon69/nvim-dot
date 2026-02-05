# @markers: meson.build
profile := "debug"
dap_bin := ""
dap_args := "--mode cpu"

build:
    meson setup builddir --buildtype={{profile}}
    meson compile -C builddir

run: build
    find builddir -maxdepth 2 -type f -executable -not -name "build.ninja" -not -path "*/.private/*" | head -n 1 | xargs -I {} {}

test:
    meson test -C builddir

clean:
    rm -rf builddir
