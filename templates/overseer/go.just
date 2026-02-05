# @markers: go.mod
profile := "dev"
dap_bin := "bin/app"
dap_args := "--mode cpu"

build:
    go build -tags {{profile}} -o bin/app .

run: build
    ./bin/app

test:
    go test -v ./...

lint:
    golangci-lint run

format:
    go fmt ./...

deps:
    go mod tidy && go mod vendor
