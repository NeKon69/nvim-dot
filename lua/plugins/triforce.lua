return {
	{
		"gisketch/triforce.nvim",
		dependencies = { "nvzone/volt" },
		event = "VeryLazy",
		opts = {
			achievements = require("user.triforce_advancments"),
			notifications = {
				enabled = true,
				level_up = false, -- Выключено по твоей просьбе
				achievements = true,
			},
			keymap = {
				show_profile = "<leader>tp",
			},

			enabled = true,
			gamification_enabled = true,
			auto_save_interval = 300,
			ignore_ft = {
				"log",
				"gitcommit",
				"TelescopePrompt",
				"checkhealth",
				"help",
				"lspinfo",
				"dashboard",
				"alpha",
				"lazy",
			},
			xp_rewards = {
				char = 1,
				line = 2,
				save = 5,
			},
		},
	},
}
