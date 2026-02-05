# @markers: poetry.lock, pyproject.toml
dap_bin := "poetry"
dap_args := "--mode cpu"

run:
    poetry run python main.py

test:
    poetry run pytest

lint:
    poetry run ruff check .

deps:
    poetry install
