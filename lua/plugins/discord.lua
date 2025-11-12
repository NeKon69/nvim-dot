return {
	{
		"andweeb/presence.nvim",
		config = function()
			require("presence").setup({
				auto_update = true,
				neovim_image_text = "Switched from boring CLion",
				main_image = "neovim",
				log_level = nil,
				debounce_timeout = 10,
				enable_line_number = false,
				blacklist = {},
				buttons = function(buffer, repo_url)
					if repo_url then
						return {
							{ label = "View Repository", url = repo_url },
						}
					else
						return true
					end
				end,
				file_assets = {},
				show_time = true,

				editing_text = "Editing %s",
				file_explorer_text = "Browsing %s",
				git_commit_text = "Committing changes",
				plugin_manager_text = "Managing plugins",
				reading_text = "Reading %s",
				workspace_text = "Working on %s",
				line_number_text = "Line %s out of %s",
			})
		end,
	},
}
