return {
  'NvChad/nvim-colorizer.lua',
  config = function()
    require("colorizer").setup({
      filetypes = {
        "*",
        dart = { mode = "virtualtext" }, -- специально для dart
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        AARRGGBB = true, -- для Color.fromARGB
        rgb_fn = true,
        css = true,
        css_fn = true,
        mode = "virtualtext", -- квадратики справа
        virtualtext = "■",
        always_update = true,
        custom = {
          ["Color.fromARGB"] = {
            regex = "[%w%s%p]*Color%.fromARGB%((%d+), (%d+), (%d+), (%d+)%)",
            parse = function(color)
              local a, r, g, b = color:match("Color%.fromARGB%((%d+), (%d+), (%d+), (%d+)%)")
              return { a = a, r = r, g = g, b = b }
            end,
          },
        },
      },
    })

    -- Принудительная активация для dart
    vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
      pattern = "*.dart",
      callback = function()
        vim.cmd("ColorizerAttachToBuffer")
      end,
    })
  end
}
