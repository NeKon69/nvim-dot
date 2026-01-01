return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		animate = {
			enabled = true,
			duration = 300,
			fps = 60,
			easing = "outCubic",
		},

		debug = {
			enabled = true,
			condition = function()
				local ext = vim.fn.expand("%:e")
				return ext ~= "cpp" and ext ~= "cu" and ext ~= "cuh" and ext ~= "c" and ext ~= "h" and ext ~= "hpp"
			end,
		},

		image = {
			enabled = true,
			formats = {
				"png",
				"jpg",
				"jpeg",
				"gif",
				"bmp",
				"webp",
				"tiff",
				"heic",
				"avif",
				"mp4",
				"mov",
				"avi",
				"mkv",
				"webm",
				"pdf",
				"icns",
			},
		},

		dashboard = {
			enabled = true,
			sections = {
				{
					pane = 1,
					section = "terminal",
					cmd = "echo ''",
					height = 18,
					padding = 1,
				},
				{ pane = 2, section = "header" },
				{ pane = 2, section = "keys", gap = 1, padding = 1 },
				{
					pane = 2,
					section = "recent_files",
					title = "Recent Files",
					icon = " ",
					indent = 2,
					padding = 1,
					limit = 10,
				},
				{ pane = 2, section = "startup" },
			},
			preset = {
				keys = {
					{ icon = " ", key = "u", desc = "Update", action = ":Lazy update" },
					{ icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
					{ icon = " ", key = "o", desc = "Old Files", action = ":Telescope oldfiles" },
					{ icon = " ", key = "g", desc = "Find Word", action = ":Telescope live_grep" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},

		input = { enabled = true },
		rename = { enabled = true },
		scope = { enabled = true },
		terminal = { enabled = true },
		toggle = { enabled = true },
		win = { enabled = true },

		bigfile = { enabled = true },
		notifier = { enabled = true, timeout = 3000 },
		quickfile = { enabled = true },
		statuscolumn = { enabled = true },
		indent = { enabled = true },
		scroll = { enabled = true },
		words = { enabled = true },
		dim = { enabled = true },

		styles = {
			notification = {
				wo = { wrap = true },
			},
		},
	},

	keys = {
		{
			"<leader>nh",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "📜 Notification History",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "❌ Dismiss Notifications",
		},
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "📝 Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "📝 Select Scratch",
		},
		{
			"<leader>z",
			function()
				Snacks.zen()
			end,
			desc = "🧘 Zen Mode",
		},
		{
			"<leader>Z",
			function()
				Snacks.zen.zoom()
			end,
			desc = "🔍 Zoom",
		},
	},

	init = function()
		local orig_schedule = vim.schedule
		vim.schedule = function(fn)
			orig_schedule(function()
				local ok, err = pcall(fn)
				if not ok and err:match("Invalid buffer id") then
					return
				elseif not ok then
					error(err)
				end
			end)
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end

				if vim.fn.has("nvim-0.11") == 1 then
					vim._print = function(_, ...)
						dd(...)
					end
				else
					vim.print = _G.dd
				end

				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.line_number():map("<leader>ul")
				Snacks.toggle
					.option("conceallevel", {
						off = 0,
						on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
					})
					:map("<leader>uc")
				Snacks.toggle.treesitter():map("<leader>uT")
				Snacks.toggle
					.option("background", { off = "light", on = "dark", name = "Dark Background" })
					:map("<leader>ub")
				Snacks.toggle.inlay_hints():map("<leader>uh")
				Snacks.toggle.indent():map("<leader>ug")
				Snacks.toggle.dim():map("<leader>uD")
			end,
		})

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*",
			callback = function(ev)
				local is_dashboard = vim.bo[ev.buf].filetype == "snacks_dashboard"
				if is_dashboard then
					Snacks.image.new({
						buf = ev.buf,
						file = "/home/progamers/Pictures/homework/fa7bcd7e906c638abd8fd46a8813e565.webp",
						width = 50,
						height = 15,
						pos = { 2, 2 },
					})
				end
			end,
		})
	end,
}
