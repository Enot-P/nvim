return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPost", "BufNewFile" }, -- Загружать при открытии буфера
  dependencies = {
    -- "lewis6991/gitsigns.nvim", -- Для git-знаков
    "kevinhwang91/nvim-hlslens", -- Для поиска
  },
  config = function()
    require("scrollbar").setup({
      show = true,
      handle = {
        blend = 30,
      },
      excluded_filetypes = {
        "prompt",
        "TelescopePrompt",
        "noice",
        "lazy",
        "mason",
        -- другие, если нужно
      },
      handlers = {
        cursor = true, -- Показывать позицию курсора
        diagnostic = true, -- Диагностика LSP
        gitsigns = false, -- Интеграция с gitsigns
        handle = true, -- Сама полоса прокрутки
        search = true, -- Включаем интеграцию с hlslens
        ale = false,
      },
    })

    -- require("scrollbar.handlers.gitsigns").setup()

    require("scrollbar.handlers.search").setup({})
  end,
}
