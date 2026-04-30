-- ============================================================
-- 🗄️  golang-migrate helpers
-- ============================================================

local function find_migrations_dir(callback)
    local cwd = vim.fn.getcwd()

    local found = vim.fs.find("migrations", {
        path = cwd,
        type = "directory",
        limit = math.huge,
    })

    if #found == 0 then
        local default = cwd .. "/migrations"
        vim.fn.mkdir(default, "p")
        callback(default)
        return
    end

    if #found == 1 then
        callback(found[1])
        return
    end

    -- несколько папок — показываем выбор
    Snacks.picker.select(found, {
        prompt = "📁 Выбери папку migrations",
        format = function(item) return item:gsub("^" .. vim.pesc(cwd) .. "/", "") end,
    }, function(item)
        if item then
            callback(item)
        end
    end)
end

local function migrate_create()
    Snacks.input({
        prompt = "📦 Имя миграции (например: create_users_table)",
        width = 60,
    }, function(name)
        if not name or name == "" then
            return
        end
        name = name:gsub("%s+", "_"):lower()

        find_migrations_dir(function(dir)
            local cmd = string.format(
                "migrate create -ext sql -dir %s -seq %s",
                vim.fn.shellescape(dir),
                vim.fn.shellescape(name)
            )
            local out = vim.fn.system(cmd)
            if vim.v.shell_error ~= 0 then
                vim.notify("migrate error:\n" .. out, vim.log.levels.ERROR)
            else
                vim.notify("✅ Миграция создана в " .. dir, vim.log.levels.INFO)
                local up = vim.fn.glob(dir .. "/*_" .. name .. ".up.sql")
                if up ~= "" then
                    vim.cmd("edit " .. up)
                end
            end
        end)
    end)
end

-- ============================================================
-- 🗄️  migrate up / down
-- ============================================================

local function migrate_run(direction)
    find_migrations_dir(function(dir)
        Snacks.input({
            prompt = "🔌 DATABASE_URL",
            width = 70,
        }, function(url)
            if not url or url == "" then
                return
            end

            local prompt = direction == "up" and "⬆️  Шагов up (Enter = все)" or "⬇️  Шагов down"

            Snacks.input({ prompt = prompt, width = 30 }, function(steps)
                local steps_arg = ""
                if steps and steps ~= "" then
                    steps_arg = " " .. steps
                end

                local cmd = string.format(
                    "migrate -path %s -database %s %s%s",
                    vim.fn.shellescape(dir),
                    vim.fn.shellescape(url),
                    direction,
                    steps_arg
                )

                vim.fn.jobstart(cmd, {
                    stdout_buffered = true,
                    stderr_buffered = true,
                    on_stdout = function(_, data)
                        local out = table.concat(data, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
                        if out ~= "" then
                            vim.notify(out, vim.log.levels.INFO)
                        end
                    end,
                    on_stderr = function(_, data)
                        local out = table.concat(data, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
                        if out ~= "" then
                            vim.notify(out, vim.log.levels.WARN)
                        end
                    end,
                    on_exit = function(_, code)
                        if code == 0 then
                            vim.notify("✅ migrate " .. direction .. " выполнен", vim.log.levels.INFO)
                        else
                            vim.notify("❌ migrate завершился с кодом " .. code, vim.log.levels.ERROR)
                        end
                    end,
                })
            end)
        end)
    end)
end

-- ============================================================
-- 🎖️ custom
-- ============================================================

local function sqlc_generate()
    local cwd = vim.fn.getcwd()
    local config = vim.fs.find({ "sqlc.yaml", "sqlc.yml", ".sqlc.yaml" }, { path = cwd, upward = true })[1]

    local cmd = "sqlc generate"
    if config and config:match("%.sqlc%.ya?ml$") then
        cmd = cmd .. " -f " .. vim.fn.shellescape(config)
    end

    vim.notify("🚀 SQLC: Генерация кода...", vim.log.levels.INFO)

    vim.fn.jobstart(cmd, {
        on_exit = function(_, code)
            if code == 0 then
                vim.notify("✅ SQLC: Код успешно сгенерирован", vim.log.levels.INFO)
            else
                vim.notify("❌ SQLC: Ошибка генерации (код " .. code .. ")", vim.log.levels.ERROR)
            end
        end,
    })
end

-- ============================================================
-- 🎮 keymaps
-- ============================================================

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go", "gomod", "sql" },
    callback = function()
        local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc }) end

        vim.keymap.set("n", "<leader>lr", function()
            vim.notify("Перезапуск gopls...", vim.log.levels.INFO)
            for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
                client:stop(true)
            end
        end, { desc = "Restart gopls" })

        map("<leader>gs", sqlc_generate, "SQLC Generate")

        -- run/test
        map("<leader>gorr", "<cmd>terminal go run .<cr>", "Run")
        map("<leader>gor", "<cmd>terminal go run -race .<cr>", "Run with race")
        map("<leader>got", "<cmd>terminal go test ./...<cr>", "Test")
        map("<leader>goT", function() vim.cmd("terminal go test " .. vim.fn.expand("%:p:h")) end, "Test file")

        -- navigation
        map("<leader>a", function()
            local file = vim.fn.expand("%")
            if file:match("_test%.go$") then
                vim.cmd("edit " .. file:gsub("_test%.go$", ".go"))
            else
                vim.cmd("edit " .. file:gsub("%.go$", "_test.go"))
            end
        end, "Alt file")

        -- coverage
        map(
            "<leader>c",
            function()
                vim.cmd("terminal go test -coverprofile=/tmp/cover.out ./... && go tool cover -html=/tmp/cover.out")
            end,
            "Coverage"
        )

        -- migrations
        vim.keymap.set("n", "<leader>gmc", migrate_create, { desc = "Migrate: create" })
        vim.keymap.set("n", "<leader>gmu", function() migrate_run("up") end, { desc = "Migrate: up" })
        vim.keymap.set("n", "<leader>gmd", function() migrate_run("down") end, { desc = "Migrate: down" })
    end,
})

-- авто lsp restart при скачке пакета
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "go.mod", "go.sum" },
    callback = function()
        vim.defer_fn(function()
            vim.cmd("LspRestart")
            vim.notify("📦 go.mod изменился — LSP перезапущен", vim.log.levels.INFO)
        end, 500) -- небольшая задержка, чтобы go mod tidy успел отработать
    end,
})
