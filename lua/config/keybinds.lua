vim.g.mapleader = " "

-- Сохранение по Ctrl+S во всех режимах (:update — сохраняет только при изменениях)
vim.keymap.set("n", "<C-s>", ":update<CR>", { silent = true, desc = "Сохранить файл" })
vim.keymap.set(
	"i",
	"<C-s>",
	"<Esc>:update<CR>a",
	{ silent = true, desc = "Сохранить и вернуться в insert" }
)
vim.keymap.set(
	"v",
	"<C-s>",
	"<Esc>:update<CR>gv",
	{ silent = true, desc = "Сохранить и сохранить выделение" }
)
