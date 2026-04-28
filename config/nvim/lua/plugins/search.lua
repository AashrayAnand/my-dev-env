return {
  -- grug-far: VSCode-like persistent search panel (open with <leader>sr)
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      headerMaxWidth = 80,
    },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open({ transient = true })
        end,
        desc = "Search and Replace (panel)",
      },
      {
        "<leader>sR",
        function()
          require("grug-far").open({
            transient = true,
            prefills = { paths = vim.fn.expand("%") },
          })
        end,
        desc = "Search and Replace (current file)",
      },
      {
        "<leader>sr",
        function()
          require("grug-far").with_visual_selection({ transient = true })
        end,
        mode = "v",
        desc = "Search selection (panel)",
      },
    },
  },

  -- Telescope: add keymaps to send results to quickfix/trouble
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local actions = require("telescope.actions")
      opts.defaults = opts.defaults or {}
      opts.defaults.mappings = opts.defaults.mappings or {}
      opts.defaults.mappings.i = vim.tbl_extend("force", opts.defaults.mappings.i or {}, {
        -- Ctrl+q sends ALL results to quickfix and opens Trouble
        ["<C-q>"] = function(bufnr)
          actions.send_to_qflist(bufnr)
          vim.cmd("Trouble qflist open")
        end,
        -- Alt+q sends SELECTED results to quickfix and opens Trouble
        ["<M-q>"] = function(bufnr)
          actions.send_selected_to_qflist(bufnr)
          vim.cmd("Trouble qflist open")
        end,
        -- Ctrl+t opens result in new tab
        ["<C-t>"] = actions.select_tab,
      })
      opts.defaults.mappings.n = vim.tbl_extend("force", opts.defaults.mappings.n or {}, {
        ["<C-q>"] = function(bufnr)
          actions.send_to_qflist(bufnr)
          vim.cmd("Trouble qflist open")
        end,
        ["<M-q>"] = function(bufnr)
          actions.send_selected_to_qflist(bufnr)
          vim.cmd("Trouble qflist open")
        end,
      })
      return opts
    end,
  },

  -- Trouble: ensure quickfix mode uses a left-side panel
  {
    "folke/trouble.nvim",
    opts = {
      modes = {
        qflist = {
          win = {
            type = "split",
            position = "bottom",
            size = { height = 15 },
          },
        },
      },
    },
  },
}
