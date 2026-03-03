return {
	"milanglacier/minuet-ai.nvim",
	enabled = true,
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
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
					end_point = "http://127.0.0.1:8012/v1/completions",
					model = "Qwen3.5-9B-Q6_K",
					stream = true,
					template = {
						prompt = function(context_before_cursor, context_after_cursor, _)
							local ctx = require("user.minuet_context")
							local context_payload = ctx.build_payload(context_before_cursor, context_after_cursor)
							local before = ctx.sanitize_prompt_text(context_before_cursor)
							local after = ctx.sanitize_prompt_text(context_after_cursor)
							local instructions = table.concat({
								"/*__MINUET_INLINE_CONTRACT_BEGIN__",
								"ROLE: local inline code completion engine.",
								"OUTPUT: return ONLY raw code to insert at cursor.",
								"You may return from start-of-line when needed; overlap is filtered.",
								"FORBIDDEN: markdown, backticks, prose, task explanations.",
								"FORBIDDEN: placeholder comments like 'TODO' or 'Implement ...'.",
								"FORBIDDEN: escaped newline literals like \\n in output.",
								"FORBIDDEN: starting unrelated functions/classes/sections unless directly required by current block.",
								"RULES:",
								"1) prefer minimal correct continuation.",
								"2) preserve file style, naming, and surrounding conventions.",
								"3) do not repeat text already present after cursor.",
								"4) PRIORITY: finish the current coherent block first (current line -> statement -> block).",
								"5) do not start a new block if the current block is incomplete.",
								"6) if line is partial, complete that line before anything else.",
								"7) stop as soon as the current block is coherently complete.",
								"8) if uncertain, return short safe continuation.",
								"__MINUET_INLINE_CONTRACT_END__*/",
							}, "\n")
							return "<|fim_prefix|>"
								.. instructions
								.. "\n"
								.. context_payload
								.. "\n"
								.. before
								.. "<|fim_suffix|>"
								.. after
								.. "<|fim_middle|>"
						end,
						suffix = false,
					},
					optional = {
						max_tokens = 400,
						temperature = 0.2,
						top_p = 0.85,
						top_k = 20,
						repeat_penalty = 1.12,
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
