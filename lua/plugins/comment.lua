--- for fast coments blocs of code. It supports a lot of language
return {
  "numToStr/Comment.nvim",
  config = function()
    require("Comment").setup({
      padding = true,
      ignore = "^$",
    })
  end,
}
