-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- local function adjust_iskeyword()
--   vim.opt_local.iskeyword:remove { "_" }
-- end

-- adjust_iskeyword()

-- vim.api.nvim_create_autocmd("FileType", {
--   group = vim.api.nvim_create_augroup("custom_split_words", { clear = true }),
--   pattern = "*",
--   callback = adjust_iskeyword,
-- })