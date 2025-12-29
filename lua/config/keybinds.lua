local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Перемещение строк в визуальном режиме
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

-- отцентровка экрана при перемещении по файлу
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Смещение не сбрасывает визуальный режим более
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

vim.keymap.set("v", "p", '"_dp', opts) -- При вставке буффер обмена не заменяется
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]]) -- Удаление без вставки в буффео обмена
vim.keymap.set("n", "x", '"_x', opts) -- Посимвольное удаление также ничего не делает

-- глобальная замена слова под курсором (в рамках файла)
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { desc = "Replace word under cursor" })

vim.keymap.set({ "i" }, "<C-c>", "<Esc>") -- Универсальный выход из любых режимов
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true }) -- Уберет выделения, которые идут при приске через /

-- split комманды
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Сохранение по Ctrl+S во всех режимах (:update — сохраняет только при изменениях)
vim.keymap.set("n", "<C-s>", ":update<CR>", { silent = true, desc = "Сохранить файл" })
vim.keymap.set("i", "<C-s>", "<Esc>:update<CR>a", { silent = true, desc = "Сохранить и вернуться в insert" })
vim.keymap.set("v", "<C-s>", "<Esc>:update<CR>gv", { silent = true, desc = "Сохранить и сохранить выделение" })

-- Визуально моргнет при копировании
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
