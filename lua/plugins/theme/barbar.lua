return {
  "romgrk/barbar.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim", -- Опционально: поддержка статуса Git
    "nvim-tree/nvim-web-devicons", -- Обязательно: иконки файлов
  },
  enabled = vim.fn.argv(0) ~= "leetcode.nvim", -- Не грузится в leet
  event = "VeryLazy",
  init = function()
    vim.g.barbar_auto_setup = 0 -- Отключаем авто-настройку, чтобы lazy.nvim корректно применил настройки
  end,
  opts = {
    -- Настройки внешнего вида и поведения
    animation = true,
    insert_at_start = true,
    insert_at_end = true,
    icons = {
      buffer_index = false,
      buffer_number = false,
      button = "×",
      -- Настройка статуса файла
      modified = { button = "●" },
      pinned = { button = "", filename = true },
    },
  },
  keys = {
    -- Переключение между буферами (Alt + , или .)
    { "<A-,>", "<Cmd>BufferPrevious<CR>", desc = "Previous Buffer" },
    { "<A-.>", "<Cmd>BufferNext<CR>", desc = "Next Buffer" },
    -- Перемещение буферов в списке (Alt + < или >)
    { "<A-<>", "<Cmd>BufferMovePrevious<CR>", desc = "Move Buffer Left" },
    { "<A->>", "<Cmd>BufferMoveNext<CR>", desc = "Move Buffer Right" },
    -- Переход по номеру (Alt + 1...9)
    { "<A-1>", "<Cmd>BufferGoto 1<CR>", desc = "Go to Buffer 1" },
    { "<A-2>", "<Cmd>BufferGoto 2<CR>", desc = "Go to Buffer 2" },
    { "<A-3>", "<Cmd>BufferGoto 3<CR>", desc = "Go to Buffer 3" },
    { "<A-4>", "<Cmd>BufferGoto 4<CR>", desc = "Go to Buffer 4" },
    { "<A-5>", "<Cmd>BufferGoto 5<CR>", desc = "Go to Buffer 5" },
    { "<A-0>", "<Cmd>BufferLast<CR>", desc = "Go to Last Buffer" },
    { "<A-x>", "<Cmd>BufferClose<CR>", desc = "Close Buffer" },
    { "<A-X>", "<Cmd>BufferCloseAllButCurrent<CR>", desc = "Close All Buffers Except Current" },
    -- Магический выбор (Alt + p) — позволяет выбрать буфер по букве
    { "<A-p>", "<Cmd>BufferPick<CR>", desc = "Pick Buffer" },
  },
}
