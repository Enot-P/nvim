return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    build = "cargo build --release",

    dependencies = {
      "rafamadriz/friendly-snippets",
      "saghen/blink.compat",
      {
        "MattiasMTS/cmp-dbee",
        dependencies = {
          "kndndrj/nvim-dbee",
        },
        ft = "sql",
        opts = {},
      },
    },

    opts = {
      keymap = {
        preset = "none",

        -- открыть completion
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

        -- TAB / Shift-TAB — навигация по списку
        ["<Tab>"] = {
          "select_next",
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          "fallback",
        },

        -- ENTER — принять
        ["<CR>"] = {
          "accept",
          "fallback",
        },

        -- закрыть меню
        ["<C-e>"] = { "hide", "fallback" },

        -- документация
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        -- сигнатуры
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = { auto_show = true },
      },

      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },

        per_filetype = {
          sql = { "dbee", "buffer" },
        },

        providers = {
          dbee = {
            name = "cmp-dbee",
            module = "blink.compat.source",
          },
        },
      },
    },

    opts_extend = { "sources.default" },
  },
}
