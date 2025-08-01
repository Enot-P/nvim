vim.g.mapleader = " "
vim.keymap.set("n", "<leader>q", ":Neotree toggle<CR>", { desc = "Toggle NeoTree" })
vim.keymap.set("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Вертикальное разделение" })
vim.keymap.set("n", "<leader>\\", "<cmd>split<CR>", { desc = "Горизонтальное разделение" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Перейти в левое окно" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Перейти в нижнее окно" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Перейти в верхнее окно" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Перейти в правое окно" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Сохранить и выйти" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>", { desc = "Сохранить и выйти" })
vim.keymap.set("n", "<leader>Q", ":q!<CR>", { desc = "Выйти без сохранения" })
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>tp", ":Telescope projects<CR>", { desc = "Поиск проектов" })
vim.keymap.set("n", "<leader>c", ":BufferLineClose<CR>", { desc = "Закрыть текущий буфер" })
for i = 1, 9 do
	vim.keymap.set(
		"n",
		"<leader>" .. i,
		":BufferLineGoToBuffer " .. i .. "<CR>",
		{ desc = "Перейти к буферу " .. i }
	)
end
vim.keymap.set(
	"n",
	"<leader>x",
	":BufferLineCloseOthers<CR>",
	{ desc = "Закрыть остальные буферы" }
)
-- Window resizing keybindings
vim.keymap.set("n", "<A-j>", ":resize +2<CR>", { desc = "Увеличить высоту окна" })
vim.keymap.set("n", "<A-k>", ":resize -2<CR>", { desc = "Уменьшить высоту окна" })
vim.keymap.set("n", "<A-h>", ":vertical resize +2<CR>", { desc = "Увеличить ширину окна" })
vim.keymap.set("n", "<A-l>", ":vertical resize -2<CR>", { desc = "Уменьшить ширину окна" })
vim.keymap.set("n", "<leader>dl", ":Telescope diagnostics bufnr=0<CR>", { desc = "Показать список ошибок" })
vim.keymap.set("n", "<leader>df", ":Telescope diagnostics bufnr=nil<CR>", { desc = "Показать ошибки проекта" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Показать ошибку под курсором" })
