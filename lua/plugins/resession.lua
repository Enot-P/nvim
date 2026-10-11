return {
    "stevearc/resession.nvim",
    dependencies = {
        { "scottmckendry/pick-resession.nvim", dependencies = { "folke/snacks.nvim" } },
    },
    config = function()
        require("pick-resession").setup({})

        local resession = require("resession")
        local sessions = require("sessions")

        resession.setup({
            load_order = "modification_time", -- свежие сессии идут первыми в списке
            autosave = {
                enabled = true, -- периодически пересохранять уже открытую сессию (страховка от падений)
                interval = 60,
                notify = false,
            },
        })

        -- Сохранять сессию нет смысла, если открыт только дашборд / пустой буфер
        local function has_real_buffers()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
                    return true
                end
            end
            return false
        end

        -- Убираем всё, что показывается тем же именем: старые сессии с полным путём
        -- и сессии одноимённых папок из других мест.
        local function drop_duplicates(keep)
            for _, other in ipairs(resession.list()) do
                if other ~= keep and sessions.display_name(other) == keep then
                    pcall(resession.delete, other, { notify = false })
                end
            end
        end

        vim.api.nvim_create_autocmd("VimLeavePre", {
            group = vim.api.nvim_create_augroup("resession_save_cwd", { clear = true }),
            desc = "Сохранить сессию текущего каталога при выходе из vim",
            callback = function()
                if not has_real_buffers() then
                    return
                end
                local name = sessions.name_for_dir()
                resession.save(name, { notify = false, attach = false })
                drop_duplicates(name)
            end,
        })

        -- Resession does NOTHING automagically, so we have to set up some keymaps
        vim.keymap.set("n", "<leader>ss", resession.save, { desc = "Session: save" })
        vim.keymap.set("n", "<leader>sl", resession.load, { desc = "Session: load" })
        vim.keymap.set("n", "<leader>sd", resession.delete, { desc = "Session: delete" })
        vim.keymap.set("n", "<leader>sr", function()
            local last = sessions.list(1)[1]
            if not last then
                vim.notify("Нет сохранённых сессий", vim.log.levels.WARN)
                return
            end
            resession.load(last)
        end, { desc = "Session: restore last" })
    end,
}
