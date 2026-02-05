# @markers: Cargo.toml
profile := "dev"
dap_bin := "target/debug/app"
dap_args := "--mode cpu"

build:
    cargo build --profile {{profile}}

run: build
    cargo run --profile {{profile}}

test:
    cargo test

check:
    cargo check

lint:
    cargo clippy -- -D warnings

format:
    cargo fmt

clean:
    cargo clean
