-- Сюда добавляются подпапки
-- lazy.nvim автоматически импортирует все файлы из указанных папок
return {
  { import = "plugins.theme" },
  { import = "plugins.lsp" }, -- включает все файлы из lsp/, включая dap.lua, flutter.lua и др.
}
