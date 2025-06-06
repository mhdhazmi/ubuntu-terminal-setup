return {
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("dashboard").setup({
        theme = "hyper",
        config = {
          week_header = {
            enable = true,
          },
          shortcut = {
            {
              desc = "󰊳 Update",
              group = "@property",
              action = "Lazy update",
              key = "u",
            },
            {
              icon = " ",
              icon_hl = "@variable",
              desc = "Files",
              group = "Label",
              action = "Telescope find_files",
              key = "f",
            },
            {
              desc = " New File",
              group = "DiagnosticHint",
              action = "enew",
              key = "n",
            },
            {
              desc = " Recent Files",
              group = "DiagnosticInfo",
              action = "Telescope oldfiles",
              key = "r",
            },
            {
              desc = " Find Text",
              group = "Number",
              action = "Telescope live_grep",
              key = "g",
            },
            {
              desc = " Config",
              group = "Constant",
              action = "edit ~/.config/nvim/init.lua",
              key = "c",
            },
            {
              desc = " Quit",
              group = "DiagnosticError",
              action = "quit",
              key = "q",
            },
          },
          project = {
            enable = true,
            limit = 8,
            icon = " ",
            label = "",
            action = "Telescope find_files cwd=",
          },
          mru = {
            limit = 10,
            icon = " ",
            label = "",
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return {
              "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
            }
          end,
        },
      })
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
  },
}