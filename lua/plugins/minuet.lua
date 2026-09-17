return {
	"milanglacier/minuet-ai.nvim",
	enabled = false,
	init = function()
		require("user.completion_backend").setup_command()
	end,
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local model_config = require("user.minuet_model")

		require("user.minuet_local").setup()
		require("user.minuet_context").setup()

		require("minuet").setup({
			provider = "openai_compatible",
			n_completions = 1,
			context_window = 7000,
			context_ratio = 0.82,
			throttle = 250,
			debounce = 250,
			request_timeout = 8,
			before_cursor_filter_length = 4,
			after_cursor_filter_length = 12,
			notify = "warn",
			virtualtext = {
				auto_trigger_ft = { "*" },
				show_on_completion_menu = true,
				keymap = {
					accept = "<Tab>",
					accept_line = "<C-l>",
					next = "<M-j>",
					prev = "<M-k>",
					dismiss = "<M-;>",
				},
			},
			provider_options = {
				openai_compatible = {
					api_key = "TERM",
					name = "ChatMock",
					end_point = model_config.chat_completions_endpoint(),
					model = model_config.primary_model,
					stream = true,
					system = {
						template = table.concat({
							"You are a low-latency code autocomplete engine.",
							"Return only the exact text to insert at <cursorPosition>.",
							"Do not explain, format as markdown, wrap in code fences, or include alternatives.",
							"Do not repeat existing prefix/suffix context.",
							"Prefer the shortest useful completion that continues the current code naturally.",
							"If the cursor is mid-line, only emit text that fits at the cursor.",
						}, "\n"),
						n_completion_template = "",
					},
					few_shots = {},
					chat_input = {
						template = table.concat({
							"{{{metadata}}}",
							"<contextBeforeCursor>",
							"{{{context_before_cursor}}}<cursorPosition>",
							"<contextAfterCursor>",
							"{{{context_after_cursor}}}",
						}, "\n"),
						metadata = function(context_before_cursor, context_after_cursor, _)
							local ctx = require("user.minuet_context")
							return ctx.build_payload(context_before_cursor, context_after_cursor)
						end,
						context_before_cursor = function(context_before_cursor, _, _)
							return require("user.minuet_context").truncate_before(context_before_cursor)
						end,
						context_after_cursor = function(_, context_after_cursor, _)
							return require("user.minuet_context").truncate_after(context_after_cursor)
						end,
					},
					optional = {
						max_completion_tokens = 500,
						reasoning = { effort = "none", summary = "none" },
						responses_tools = {},
						responses_tool_choice = "none",
						stop = {
							"<endCompletion>",
							"```",
							"<contextBeforeCursor>",
							"<contextAfterCursor>",
							"<cursorPosition>",
						},
					},
					transform = {
						function(request)
							local body = request.body
							body.model = model_config.request_model()
							body.fast_mode = model_config.request_fast_mode(body.model) or nil
							body.messages = vim.tbl_filter(function(message)
								return message.role ~= "system" or message.content ~= ""
							end, body.messages or {})
							request.end_point = model_config.chat_completions_endpoint()
							return request
						end,
					},
				},
			},
		})

		local group = vim.api.nvim_create_augroup("MinuetAutoTriggerCurrentBuffer", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter" }, {
			group = group,
			callback = function()
				vim.b.minuet_virtual_text_auto_trigger = true
			end,
		})
	end,
}
