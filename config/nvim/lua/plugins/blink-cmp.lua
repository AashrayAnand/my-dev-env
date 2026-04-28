return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        trigger = {
          show_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
          max_items = 30,
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
        },
        ghost_text = {
          enabled = true,
        },
        menu = {
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
          },
        },
      },
      signature = {
        enabled = true,
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-y>"] = { "select_and_accept" },
        ["<Tab>"] = { "select_and_accept", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
      },
    },
  },
}
