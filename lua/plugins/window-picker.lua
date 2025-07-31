return {
  "s1n7ax/nvim-window-picker",
  version = "2.*", -- Рекомендуется использовать стабильную версию
  config = function()
    require("window-picker").setup({
      -- Настройки по желанию, например:
      hint = "floating-big-letter",
      filter_rules = {
        include_current_win = false,
        autoselect_one = true,
        bo = {
          filetype = { "neo-tree", "notify" },
          buftype = { "terminal" },
        },
      },
    })
  end,
}
