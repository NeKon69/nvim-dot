local M = {}

M.capabilities = require("cmp_nvim_lsp").default_capabilities()

M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { "documentation", "detail", "additionalTextEdits" },
}

M.capabilities.textDocument.codeLens = {
	dynamicRegistration = false,
}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local bufnr = event.buf
		local opts = { buffer = bufnr, remap = false, silent = true }

		vim.keymap.set(
			"n",
			"gd",
			vim.lsp.buf.definition,
			vim.tbl_extend("force", opts, { desc = "LSP: Go to definition" })
		)
		vim.keymap.set(
			"n",
			"gD",
			vim.lsp.buf.declaration,
			vim.tbl_extend("force", opts, { desc = "LSP: Go to declaration" })
		)
		vim.keymap.set(
			"n",
			"gi",
			vim.lsp.buf.implementation,
			vim.tbl_extend("force", opts, { desc = "LSP: Go to implementation" })
		)
		vim.keymap.set(
			"n",
			"gr",
			vim.lsp.buf.references,
			vim.tbl_extend("force", opts, { desc = "LSP: Show references" })
		)
		vim.keymap.set(
			"n",
			"gt",
			vim.lsp.buf.type_definition,
			vim.tbl_extend("force", opts, { desc = "LSP: Go to type definition" })
		)

		vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP: Hover" }))

		local hover_timer = nil
		local wait_time = 500
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = bufnr,
			callback = function()
				if vim.fn.mode() == "n" and vim.fn.pumvisible() == 0 then
					if hover_timer then
						vim.fn.timer_stop(hover_timer)
					end
					hover_timer = vim.fn.timer_start(wait_time, function()
						if client and client.server_capabilities.hoverProvider then
							local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
							vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
								if err or not result or not result.contents then
									return
								end
								local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
								if #markdown_lines == 0 or (markdown_lines[1] == "" and #markdown_lines == 1) then
									return
								end
								vim.lsp.util.open_floating_preview(markdown_lines, "markdown", {
									border = "rounded",
									focusable = false,
								})
							end)
						end
					end)
				end
			end,
			desc = "Show hover documentation on hold",
		})

		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP: Rename" }))
		vim.keymap.set(
			{ "n", "v" },
			"<leader>ca",
			vim.lsp.buf.code_action,
			vim.tbl_extend("force", opts, { desc = "LSP: Code action" })
		)

		vim.keymap.set("n", "<leader>fm", function()
			vim.lsp.buf.format({ async = true })
		end, vim.tbl_extend("force", opts, { desc = "LSP: Format" }))

		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend(
			"force",
			opts,
			{ desc = "Previous diagnostic" }
		))
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

		if client and client.server_capabilities.codeLensProvider then
			vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
				buffer = bufnr,
				callback = function()
					vim.lsp.codelens.refresh({ bufnr = bufnr })
				end,
			})
			vim.keymap.set(
				"n",
				"<leader>cl",
				vim.lsp.codelens.run,
				vim.tbl_extend("force", opts, { desc = "Run CodeLens" })
			)
		end

		if client and client.server_capabilities.documentHighlightProvider then
			local highlight_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = highlight_group,
				buffer = bufnr,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd("CursorMoved", {
				group = highlight_group,
				buffer = bufnr,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		prefix = "●",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
})

local _open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	opts.focusable = false
	return _open_floating_preview(contents, syntax, opts, ...)
end

return M
