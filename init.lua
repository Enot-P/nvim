require("me.remap")
require("me.sets")
require("me.lazy")
require("me.utils") -- Просто загружаем утилиты
require("me.utils.utils_keymaps").setup() -- Отдельно настраиваем кеймапы

-- Глобальная обработка ошибок Treesitter
vim.api.nvim_create_autocmd("User", {
  pattern = "TreesitterHighlightError",
  callback = function()
    -- Подавляем ошибки Treesitter для предотвращения спама
    vim.notify("Treesitter highlight error suppressed", vim.log.levels.WARN)
  end,
})

-- Дополнительная защита от ошибок подсветки
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local ok, _ = pcall(function()
      -- Проверяем, что Treesitter может обработать файл
      local ts = require("nvim-treesitter")
      if ts and ts.get_parser then
        local parser = ts.get_parser(buf)
        if parser then
          parser:parse()
        end
      end
    end)
    
    if not ok then
      -- Отключаем Treesitter для проблемных файлов
      vim.treesitter.stop(buf)
    end
  end,
})

-- Format on save
local format_on_save_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_on_save_group,
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false, timeout_ms = 500 })
  end,
})

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local yank_group = augroup("HighlightYank", {})
local format_options_group = augroup("FormatOptions", { clear = true })

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

-- This needs to be an auto command instead of simply putting this in your vimrc
-- or init.lua as set or vim.o. If you have ftplugin enabled, vim has built-in
-- files for common programming languages, for which the format options are
-- usually already preset (with +cro), meaning that whatever you add in your
-- vimrc or init.lua will get overridden by the native ft plugin loading the
-- [filetype].vim file. So you need to to do the change after the ft file is
-- loaded
autocmd("BufEnter", {
	group = format_options_group,
	pattern = "*",
	desc = "Set buffer local formatoptions.",
	callback = function()
		vim.opt_local.formatoptions:remove({
			"r", -- Automatically insert the current comment leader after hitting <Enter> in Insert mode.
			"o", -- Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.
		})
	end,
})

-- vim.api.nvim_create_autocmd("VimEnter", {
--   pattern = "*",
--   callback = function()
--     if vim.fn.argc() == 0 or (vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv()[0]) == 1) then -- Открыть Oil, если не был передан файл или была передана директория
--       vim.cmd("Oil")
--     end
--   end,
--   desc = "Open Oil on startup",
-- })
