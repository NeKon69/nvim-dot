return {
  -- This is the orchestrator plugin
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
  },
  -- THIS IS THE CORRECT WAY TO CONFIGURE IT
  opts = {
    -- A list of servers to ensure are installed
    ensure_installed = { "clangd", "glslls" },

    -- This is the key. We provide the setup function inside the 'handlers' table.
    -- mason-lspconfig will call this for each server.
    handlers = {
      -- The default handler for all servers
      function(server_name)
        local lsp_util = require("user.lspconfig")
        require("lspconfig")[server_name].setup({
          capabilities = lsp_util.capabilities,
          on_attach = lsp_util.on_attach,
        })
      end,

      -- You can add custom handlers for specific servers here. For example:
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
