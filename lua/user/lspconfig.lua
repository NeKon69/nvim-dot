local M = {}

M.capabilities = require("cmp_nvim_lsp").default_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { "documentation", "detail", "additionalTextEdits" },
}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local bufnr = event.buf

		local function force_map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, {
				buffer = bufnr,
				silent = true,
				desc = desc,
				nowait = true,
				noremap = true,
			})
		end

		if client and client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end

		local history = require("user.history")
		-- ТВОЙ ПРОВЕРЕННЫЙ СПИСОК G
		force_map("<M-CR>", "<cmd>Lspsaga code_action<CR>", "Code Action (Alt+Enter)")
		force_map("gd", history.wrap_jump("Lspsaga goto_definition", "Definition"), "LSP Definition")
		force_map("gp", history.wrap_jump("Lspsaga peek_definition", "Peek Def"), "LSP Peek Definition")
		force_map("gD", history.wrap_jump("Lspsaga goto_declaration", "Declaration"), "LSP Declaration")
		force_map("gi", history.wrap_jump(vim.lsp.buf.implementation, "Implement"), "LSP Implementation")
		force_map("gt", history.wrap_jump("Lspsaga goto_type_definition", "Type Def"), "LSP Type Definition")
		force_map("gh", history.wrap_jump("Lspsaga finder", "LSP Finder"), "LSP Finder")

		force_map("K", "<cmd>Lspsaga hover_doc<CR>", "LSP Hover")

		-- ВОЗВРАЩАЕМ ПРОПУЩЕННЫЕ ЛИДЕР-МАППИНГИ
		force_map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "Code Action")
		force_map("<leader>cr", "<cmd>Lspsaga rename<CR>", "Rename")
		force_map("<leader>o", "<cmd>Lspsaga outline<CR>", "Outline (Symbols)")
		force_map("<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", "Incoming Calls")
		force_map("<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", "Outgoing Calls")
		force_map("<leader>fm", function()
			vim.lsp.buf.format({ async = true })
		end, "Format")

		-- ОСТАЛЬНАЯ ЛОГИКА (CODELENS, HIGHLIGHT, HOVER) БЕЗ ИЗМЕНЕНИЙ
		if client and client.server_capabilities.codeLensProvider then
			vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
				buffer = bufnr,
				callback = function()
					if vim.api.nvim_buf_is_valid(bufnr) then
						vim.lsp.codelens.refresh({ bufnr = bufnr })
					end
				end,
			})
			force_map("<leader>cl", vim.lsp.codelens.run, "Run CodeLens")
		end

		if client and client.server_capabilities.documentHighlightProvider then
			local highlight_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = highlight_group,
				buffer = bufnr,
				callback = function()
					if vim.api.nvim_buf_is_valid(bufnr) then
						vim.lsp.buf.document_highlight()
					end
				end,
			})
			vim.api.nvim_create_autocmd("CursorMoved", {
				group = highlight_group,
				buffer = bufnr,
				callback = function()
					if vim.api.nvim_buf_is_valid(bufnr) then
						vim.lsp.buf.clear_references()
					end
				end,
			})
		end

		local hover_timer = nil
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = bufnr,
			callback = function()
				if vim.fn.mode() == "n" and vim.fn.pumvisible() == 0 then
					if hover_timer then
						vim.fn.timer_stop(hover_timer)
					end
					hover_timer = vim.fn.timer_start(500, function()
						if vim.api.nvim_buf_is_valid(bufnr) then
							local hover = require("lspsaga.hover")
							if not (hover.winid and vim.api.nvim_win_is_valid(hover.winid)) then
								vim.cmd("Lspsaga hover_doc ++silent")
							end
						end
					end)
				end
			end,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			buffer = bufnr,
			callback = function()
				if hover_timer then
					vim.fn.timer_stop(hover_timer)
				end
			end,
		})
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("SagaFixLineWrap", { clear = true }),
	callback = function(event)
		if vim.bo[event.buf].filetype == "markdown" then
			vim.wo[0].wrap = false
		end
	end,
})

vim.diagnostic.config({
	virtual_text = { spacing = 4, prefix = "●" },
	underline = true,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
})

local _open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = "rounded"
	opts.focusable = false
	return _open_floating_preview(contents, syntax, opts, ...)
end

return M
