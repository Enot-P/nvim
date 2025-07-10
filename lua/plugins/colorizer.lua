return {
  "NvChad/nvim-colorizer.lua",
  event = "VeryLazy",
  config = function()
    require("colorizer").setup {
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = false, -- "Name" codes like Blue or Thistle
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS functions: rgb_fn, hsl_fn
        mode = "virtualtext", -- | background | virtualtext.  "virtualtext" is a default value
      },
      -- set to true if you want to enable a certain mode for the whole file
      -- set to false to disable a certain mode only for the current file
      modes = {
        "css",
        "scss",
        "html",
        "lua",
      },
    }
  end,
}