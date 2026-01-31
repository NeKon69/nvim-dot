return {
	cpp = "clang++ -std=c++20 -O3 {file} -o {bin} && {bin}",
	py = "python3 {file}",
	asm = "nasm -f elf64 {file} -o {bin}.o && ld {bin}.o -o {bin} && {bin}",
}
