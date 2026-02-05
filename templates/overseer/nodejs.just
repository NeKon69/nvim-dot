# @markers: package.json
dap_bin := ""
dap_args := "--mode cpu"

build:
    npm run build

run:
    npm start

test:
    npm test

lint:
    npm run lint

deps:
    npm install
