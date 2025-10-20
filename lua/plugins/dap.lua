return {
  "mfussenegger/nvim-dap",

  dependencies = {
    { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim",
  },

  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      floating = {
        max_height = 0.9,
        max_width = 0.9,
        border = "rounded",
        mappings = { close = { "q", "<Esc>" } },
      },
      element_mappings = {
        breakpoints = { open = "<CR>", remove = "d", toggle = "t" },
      },
      layouts = {
        {
          elements = { { id = "scopes", size = 0.6 }, { id = "stacks", size = 0.4 } },
          position = "bottom",
          size = 12,
        },
        {
          elements = { { id = "repl", size = 1.0 } },
          position = "bottom",
          size = 8,
        },
      },
      render = {
        max_value_lines = 100,
        },
    })

    require("nvim-dap-virtual-text").setup({})

    require("mason-nvim-dap").setup({
      ensure_installed = { "cpptools" },
      handlers = {},
    })

    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "DiagnosticHint", linehl = "DebugLine" })

    local map = vim.keymap.set
    map("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
    map("n", "<S-F5>", dap.terminate, { desc = "DAP: Terminate" })
    map("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
    map("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
    map("n", "<S-F11>", dap.step_out, { desc = "DAP: Step Out" })
    map("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
    map("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "DAP: Conditional Breakpoint" })
    map("n", "<leader>do", dapui.toggle, { desc = "DAP: Toggle UI" })
    map("n", "<leader>de", dapui.eval, { desc = "DAP: Evaluate" })
    map("n", "<leader>dr", function() dapui.focus("repl") end, { desc = "DAP: Focus REPL" })
    map("n", "<leader>ds", function() dapui.focus("scopes") end, { desc = "DAP: Focus Scopes" })
    map("n", "<leader>dbp", function() dapui.float_element("breakpoints", { enter = true }) end, { desc = "DAP: Floating Breakpoints" })
    map("n", "<leader>dt", function() dapui.float_element("threads", { enter = true }) end, { desc = "DAP: Floating Threads" })
  end,
}

