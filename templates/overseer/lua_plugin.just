# @markers: lua/*.lua, plugin/*.lua
test:
    nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = tests/minimal_init.lua }"

lint:
    luacheck .

format:
    stylua .
