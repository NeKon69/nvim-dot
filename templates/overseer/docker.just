# @markers: Dockerfile
tag := "latest"

build:
    docker build -t app:{{tag}} .

run: build
    docker run --rm -it app:{{tag}}
