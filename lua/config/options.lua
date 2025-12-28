vim.opt.number = true -- Отображает номер строки
vim.opt.cursorline = true -- Подсветка текущей строки
vim.opt.relativenumber = true -- Номерация идет относительно строки
vim.opt.shiftwidth = 4 -- Кол-во пробелов в табуляции
vim.opt.clipboard = "unnamedplus" -- Синхронизация для копирования
vim.opt.autowrite = true    -- автосохранение при переключении буферов
vim.opt.autowriteall = true -- автосохранение при выходе

-- Настройка filetype для специальных файлов
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "docker-compose*.yml", "docker-compose*.yaml", "*.docker-compose.yml", "*.docker-compose.yaml" },
  callback = function()
    vim.bo.filetype = "yaml"
  end,
})

-- Настройка filetype для GraphQL файлов
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.graphql", "*.gql" },
  callback = function()
    vim.bo.filetype = "graphql"
  end,
})
