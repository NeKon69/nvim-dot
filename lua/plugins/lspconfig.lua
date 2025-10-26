return {
  -- This is the orchestrator plugin
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
  },
  opts = {
    ensure_installed = { "clangd", "glslls" },

    handlers = {
      function(server_name)
        local lsp_util = require("user.lspconfig")
        require("lspconfig")[server_name].setup({
          capabilities = lsp_util.capabilities,
          on_attach = lsp_util.on_attach,
        })
      end,

      ["lua_ls"] = function()
        local lsp_util = require("user.lspconfig")
        require("lspconfig").lua_ls.setup({
          capabilities = lsp_util.capabilities,
          on_attach = lsp_util.on_attach,
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
            },
          },
        })
      end,
    },
  },
}
