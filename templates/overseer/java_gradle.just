# @markers: build.gradle, gradlew
dap_bin := ""
dap_args := "--mode cpu"

build:
    chmod +x gradlew
    ./gradlew build

run:
    ./gradlew run

test:
    ./gradlew test

clean:
    ./gradlew clean
