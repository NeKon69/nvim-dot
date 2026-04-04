return {
	"milanglacier/minuet-ai.nvim",
	enabled = function()
		return require("user.completion_backend").current() == "local"
	end,
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
			provider = "openai_fim_compatible",
			n_completions = 1,
			context_window = 8192,
			throttle = 120,
			debounce = 120,
			request_timeout = 6,
			before_cursor_filter_length = 8,
			after_cursor_filter_length = 20,
			notify = "warn",
			virtualtext = {
				auto_trigger_ft = { "*" },
				keymap = {
					accept = "<Tab>",
					accept_line = "<C-l>",
					next = "<M-j>",
					prev = "<M-k>",
					dismiss = "<M-;>",
				},
			},
			provider_options = {
				openai_fim_compatible = {
					api_key = "TERM",
					name = "Llama.cpp",
					end_point = model_config.completions_endpoint(),
					model = model_config.model_name,
					stream = true,
					template = {
						prompt = function(context_before_cursor, context_after_cursor, _)
							local ctx = require("user.minuet_context")
							local context_payload = ctx.build_payload(context_before_cursor, context_after_cursor)
							local before = ctx.truncate_before(context_before_cursor)
							local after = ctx.truncate_after(context_after_cursor)
							return table.concat({
								"Complete code by inserting text between PREFIX and SUFFIX.",
								"Return only the missing inserted code.",
								"Do not repeat PREFIX.",
								"Do not repeat SUFFIX.",
								"Do not rewrite the whole line, block, or file.",
								"If the cursor is in the middle of a line, insert only what fits there.",
								"Prefer a short useful continuation that completes the current coherent piece of code.",
								"Never answer with only a safe closer like }, ), ], ;, or ,. ",
								"No markdown, no tags, no explanations.",
								"",
								context_payload,
								"[PREFIX]",
								before,
								"[SUFFIX]",
								after,
								"[INSERT_ONLY]",
							}, "\n")
						end,
						suffix = false,
					},
					optional = {
						max_tokens = 400,
						temperature = 1.0,
						top_p = 0.9,
						top_k = 40,
						repeat_penalty = 1.08,
						stop = {
							"```",
							"<end>",
							"<eos>",
							"<end_of_turn>",
							"<|",
							"__LOCAL_CONTEXT_END__*/",
							"[PREFIX]",
							"[SUFFIX]",
							"[INSERT_ONLY]",
						},
					},
				},
			},
		})

		local vt = require("minuet.virtualtext")
		local idle_timer = nil

		local function stop_idle_timer()
			if idle_timer then
				pcall(vim.fn.timer_stop, idle_timer)
				idle_timer = nil
			end
		end

		local function schedule_idle_trigger()
			stop_idle_timer()
			idle_timer = vim.fn.timer_start(700, function()
				vim.schedule(function()
					local mode = vim.fn.mode()
					if mode ~= "i" and mode ~= "R" then
						return
					end
					if vt.action.is_visible and vt.action.is_visible() then
						return
					end
					vt.action.next()
				end)
			end)
		end

		local group = vim.api.nvim_create_augroup("MinuetIdleTrigger", { clear = true })
		vim.api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI", "InsertEnter" }, {
			group = group,
			callback = function()
				schedule_idle_trigger()
			end,
		})
		vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
			group = group,
			callback = function()
				stop_idle_timer()
			end,
		})
	end,
}
