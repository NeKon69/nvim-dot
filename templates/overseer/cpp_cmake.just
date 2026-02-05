# @markers: CMakeLists.txt
profile := "Debug"
dap_bin := "build_Debug/app"
dap_args := "--mode cpu"

build:
    cmake -B build_{{profile}} -DCMAKE_BUILD_TYPE={{profile}} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build_{{profile}}

run: build
    find build_{{profile}} -maxdepth 4 -type f -executable -not -path "*/CMakeFiles/*" -not -name "*.so" -not -name "*.a" -not -name "*_test" -not -name "test_*" | head -n 1 | xargs -I {} {}

test: build
    cd build_{{profile}} && ctest -C {{profile}} --output-on-failure

clean:
    rm -rf build_*

format:
    clang-format -i src/*.cpp include/*.h
