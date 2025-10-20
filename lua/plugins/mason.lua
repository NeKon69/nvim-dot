return {
  -- This file sets up the installers: Mason and the Mason-lspconfig bridge.
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "glslls" },
      })
    end,
  },
}
