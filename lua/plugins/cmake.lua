return {
	"Civitasv/cmake-tools.nvim",
	dap_config_name = "cppdbg",
	event = "VeryLazy",
	opts = {
		cmake_generate_options = {
			"-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
		},
		cmake_regenerate_on_save = true,
	},
}
