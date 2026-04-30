-- IntelliJ / Kulala HTTP Client: .http и .rest → filetypes http / rest
vim.filetype.add({
    extension = {
        http = "http",
        rest = "rest",
    },
})

-- Автоматическая очистка лог-файла LSP при старте
local lsp_log_path = vim.fn.stdpath("log") .. "/lsp.log"
local log_file = io.open(lsp_log_path, "r")
if log_file then
    log_file:close()
    -- Очищаем файл, если он больше 10MB
    local file_size = vim.fn.getfsize(lsp_log_path)
    if file_size > 10 * 1024 * 1024 then -- 10MB
        io.open(lsp_log_path, "w"):close()
    end
end

-- Визуально моргнет при копировании
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function() vim.hl.on_yank() end,
})

-- Более удобная работа в markdown
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = true
        vim.keymap.set("n", "k", "gk")
        vim.keymap.set("n", "j", "gj")
    end,
})

-- Выключает подсветку курсора, когда покидаешь окно
vim.api.nvim_create_autocmd("WinLeave", {
    pattern = "*",
    callback = function() vim.wo.cursorline = false end,
})

-- Открывает help файлы вертикально справа
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = { "*.txt" },
    callback = function()
        if vim.bo.filetype == "help" then
            vim.cmd.wincmd("L") -- Move window to the rightmost position
        end
    end,
})

-- Каждый раз, когда пользователь что-то переключил или просто стоит на месте — проверь, не изменились ли файлы на диске
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})
