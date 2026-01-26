return {
  "chrisgrieser/nvim-spider",
  config = function()
    -- Инициализация UTF-8 поддержки для русского языка
    local ok, utf8 = pcall(require, "luautf8")
    if ok then
      require("spider").setup({
        skipInsignificantPunctuation = true,
      })
    else
      require("spider").setup({
        skipInsignificantPunctuation = true,
      })
    end
  end,
  keys = {
    { "w", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" } },
    { "e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" } },
    { "b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" } },
  },
}
