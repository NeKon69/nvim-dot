# @markers: requirements.txt, venv/, .venv/
dap_bin := "python3"
dap_args := "--mode cpu"

run:
    ([ -f venv/bin/python ] && venv/bin/python main.py) || ([ -f .venv/bin/python ] && .venv/bin/python main.py) || python3 main.py

test:
    pytest

lint:
    ruff check .

format:
    ruff format .

deps:
    pip install -r requirements.txt
