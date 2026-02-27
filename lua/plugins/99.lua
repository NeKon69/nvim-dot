return {
	{
		"ThePrimeagen/99",
		event = "VeryLazy",
		config = function()
			local _99 = require("99")

			local CodexProvider = setmetatable({}, { __index = _99.Providers.BaseProvider })

			function CodexProvider._build_command(_, query, context)
				local cmd = {
					"codex",
					"exec",
					"--skip-git-repo-check",
					"-o",
					context.tmp_file,
				}

				table.insert(cmd, query)
				return cmd
			end

			function CodexProvider._get_provider_name()
				return "CodexProvider"
			end

			function CodexProvider.fetch_models(callback)
				callback(nil, "Codex model listing is not supported by this provider")
			end

			_99.setup({
				provider = CodexProvider,
				completion = {
					source = "cmp",
					custom_rules = {},
				},
			})

			local prompts = _99.__get_state().prompts.prompts
			local base_output_file = prompts.output_file
			prompts.output_file = function()
				return base_output_file()
					.. "\nDo not use Markdown code fences in TEMP_FILE output."
					.. "\nOutput raw code only unless the user explicitly asks for fenced markdown."
			end

			vim.keymap.set("v", "<leader>av", function()
				_99.visual({})
			end, { desc = "99 Visual" })

			vim.keymap.set("n", "<leader>ax", function()
				_99.stop_all_requests()
			end, { desc = "99 Stop" })

			vim.keymap.set("n", "<leader>as", function()
				_99.search({})
			end, { desc = "99 Search" })

			vim.keymap.set("n", "<leader>ao", function()
				_99.open()
			end, { desc = "99 Open Result" })
		end,
	},
}
