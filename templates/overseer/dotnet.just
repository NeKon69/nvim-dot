# @markers: *.csproj, *.sln
profile := "Debug"
dap_bin := ""
dap_args := "--mode cpu"

build:
    dotnet build -c {{profile}}

run:
    dotnet run -c {{profile}} --no-build

test:
    dotnet test -c {{profile}}

clean:
    dotnet clean
