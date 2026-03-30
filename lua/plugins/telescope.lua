-- Bootstrap native package manager
vim.opt.packpath:append(vim.fn.stdpath("data") .. "/site")

vim.pack.add({
    -- Основной Telescope
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-lua/plenary.nvim",

    -- Расширения
    "https://github.com/nvim-telescope/telescope-fzf-native.nvim",     -- ускорение поиска
    "https://github.com/nvim-telescope/telescope-live-grep-args.nvim", -- live_grep с аргументами
    "https://github.com/nvim-telescope/telescope-frecency.nvim",       -- умная сортировка по частоте
    "https://github.com/nvim-telescope/telescope-project.nvim",        -- переключение проектов
    "https://github.com/nvim-telescope/telescope-ui-select.nvim",      -- улучшенный vim.ui.select
    "https://github.com/nvim-telescope/telescope-dap.nvim",            -- интеграция с nvim-dap
    "https://github.com/nvim-telescope/telescope-github.nvim",         -- GitHub issues/PR
    "https://github.com/tomasky/bookmarks.nvim",                       -- telescope-bookmarks
})


vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local lga_actions = require("telescope-live-grep-args.actions")

        telescope.setup({
            defaults = {
                prompt_prefix = "🔭 ",
                selection_caret = " ",
                path_display = { "smart" },
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        ["<Esc>"] = actions.close,
                    },
                },
            },

            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown({})
                },
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                live_grep_args = {
                    auto_quoting = true,
                    mappings = {
                        i = {
                            ["<C-k>"] = lga_actions.quote_prompt(),
                            ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                        },
                    },
                },
                frecency = {
                    show_scores = true,
                    show_unindexed = true,
                },
            },

            pickers = {
                find_files = { theme = "ivy" },
                live_grep = { theme = "ivy" },
            },
        })

        -- Загрузка расширений
        telescope.load_extension("fzf")
        telescope.load_extension("live_grep_args")
        telescope.load_extension("frecency")
        telescope.load_extension("project")
        telescope.load_extension("ui-select")
        telescope.load_extension("dap")
        telescope.load_extension("gh")
        telescope.load_extension("bookmarks")
    end,
})

-- =============================================
-- Горячие клавиши
-- =============================================

local builtin = require("telescope.builtin")
local lg = require("telescope").extensions.live_grep_args

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", lg.live_grep_args, { desc = "Live grep with args" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last search" })

-- Расширения
vim.keymap.set("n", "<leader>fp", function() require("telescope").extensions.project.project {} end,
    { desc = "Projects" })
vim.keymap.set("n", "<leader>fc", function() require("telescope").extensions.frecency.frecency {} end,
    { desc = "Frecency (smart recent)" })

-- GitHub
vim.keymap.set("n", "<leader>gi", function() require("telescope").extensions.gh.issues {} end, { desc = "GitHub Issues" })
vim.keymap.set("n", "<leader>gp", function() require("telescope").extensions.gh.pull_request {} end,
    { desc = "GitHub PRs" })

-- DAP
vim.keymap.set("n", "<leader>db", function() require("telescope").extensions.dap.commands {} end,
    { desc = "DAP commands" })

-- Bookmarks
vim.keymap.set("n", "<leader>bm", function() require("telescope").extensions.bookmarks.bookmarks {} end,
    { desc = "Bookmarks" })

-- Дополнительно
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "LSP Symbols" })
