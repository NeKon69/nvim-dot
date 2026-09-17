# @markers: CMakeLists.txt
profile := "Debug"
dap_bin := "build_" + profile + "/app"
dap_args := ""

build:
    cmake -B build_{{profile}} -DCMAKE_BUILD_TYPE={{profile}} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build_{{profile}}

run: build
    cd build_{{profile}} && ./{{dap_bin}} {{dap_args}}

test: build
    cd build_{{profile}} && ctest -C {{profile}} --output-on-failure

clean:
    rm -rf build_*

format:
    clang-format -i src/*.cpp include/*.h
