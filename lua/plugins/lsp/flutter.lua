return {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/dressing.nvim",
        "mfussenegger/nvim-dap",
    },
    config = function()
        local log_file = vim.fn.tempname() .. "_flutter.log"
        local tmux_pane_created = false
        -- Устанавливаем переменные окружения для Android Emulator в Hyprland/Wayland
        vim.env.QT_QPA_PLATFORM = "xcb"
        vim.env.ANDROID_EMULATOR_USE_SYSTEM_LIBS = "1"
        vim.env.JAVA_HOME = "/usr/lib/jvm/default"

        local file = io.open(log_file, "w")
        if file then
            file:close()
        end
        local function log_filter(log_line)
            if log_line then
                local file = io.open(log_file, "a")
                if file then
                    file:write(log_line .. "\n")
                    file:flush()
                    file:close()
                end
            end
            return true
        end

        local function create_tmux_log_window()
            if vim.env.TMUX == nil then
                vim.notify("Не в tmux сессии. Логи будут отображаться только в Neovim буфере.", vim.log.levels.WARN)
                return
            end

            if tmux_pane_created then
                return
            end

            local cmd = string.format("tmux new-window -n 'Flutter Logs' 'tail -f %s'", vim.fn.shellescape(log_file))

            local result = vim.fn.system(cmd)
            if vim.v.shell_error == 0 then
                tmux_pane_created = true
                vim.notify("Окно tmux с логами Flutter создано", vim.log.levels.INFO)
            else
                vim.notify("Не удалось создать окно tmux: " .. (result or "неизвестная ошибка"), vim.log.levels.ERROR)
            end
        end

        -- Фильтрация известных некритичных ошибок RangeError от Dart LSP
        -- Эти ошибки возникают при синхронизации документа (особенно при использовании сниппетов)
        -- и не влияют на работу LSP, но засоряют интерфейс уведомлениями
        --
        -- ВАЖНО: Это только скрывает уведомления в UI. Ошибки всё ещё записываются в лог-файл
        -- (~/.local/state/nvim/lsp.log). Это не критично, но если нужно, можно периодически
        -- чистить лог вручную или настроить автоматическую очистку в autocmds.lua
        local original_notify = vim.notify
        vim.notify = function(msg, level, opts)
            -- Фильтруем уведомления об ошибках RangeError от dartls
            if type(msg) == "string" then
                -- Проверяем, что это сообщение об ошибке от dartls
                local is_dartls_error = string.match(msg, "%[dartls%]") or string.match(msg, "LSP.*dartls")
                if is_dartls_error then
                    -- Игнорируем ошибки синхронизации документа
                    if
                        string.match(msg, "RangeError")
                        or string.match(msg, "edit starts past the end")
                        or string.match(msg, "edit extends past the end")
                        or string.match(msg, "An error occurred while handling textDocument/didChange")
                    then
                        return -- Игнорируем эти уведомления (но они всё равно логируются!)
                    end
                end
            end
            return original_notify(msg, level, opts)
        end

        require("flutter-tools").setup({
            lsp = {
                color = {
                    enabled = true,
                },
                on_attach = function(client, bufnr) end,
                capabilities = vim.lsp.protocol.make_client_capabilities(),
                settings = {
                    showTodos = true,
                    completeFunctionCalls = true,
                    analysisExcludedFolders = {
                        vim.fn.expand("$HOME/.pub-cache"),
                        vim.fn.expand("$HOME/flutter"),
                    },
                    renameFilesWithClasses = "prompt",
                    enableSnippets = true,
                    updateImportsOnRename = true,
                },
            },
            debugger = {
                enabled = true,
                exception_breakpoints = {},
                evaluate_to_string_in_debug_views = true,
            },
            dev_log = {
                enabled = true,
                filter = log_filter,
                notify_errors = true,
                open_cmd = "15split",
                focus_on_open = false,
            },
        })

        -- Остальной код без изменений...
        vim.api.nvim_create_autocmd("BufNew", {
            pattern = "__FLUTTER_DEV_LOG__",
            callback = function()
                vim.defer_fn(function()
                    create_tmux_log_window()
                end, 500)
            end,
            once = true,
        })

        vim.api.nvim_create_autocmd("BufWinEnter", {
            pattern = "__FLUTTER_DEV_LOG__",
            callback = function()
                vim.defer_fn(function()
                    local buf = vim.fn.bufnr("__FLUTTER_DEV_LOG__")
                    if buf ~= -1 then
                        local wins = vim.fn.win_findbuf(buf)
                        if #wins > 0 then
                            for _, win in ipairs(wins) do
                                vim.api.nvim_win_close(win, false)
                            end
                        end
                    end
                end, 50)
            end,
        })

        vim.api.nvim_create_autocmd("BufWipeout", {
            pattern = "__FLUTTER_DEV_LOG__",
            callback = function()
                local file = io.open(log_file, "w")
                if file then
                    file:close()
                end
                tmux_pane_created = false
            end,
        })

        vim.api.nvim_create_user_command("FlutterTmuxLogs", function()
            tmux_pane_created = false
            create_tmux_log_window()
        end, {
            desc = "Создать новое окно tmux с логами Flutter",
        })

        -- Хоткеи
        vim.keymap.set("n", "<leader>flr", ":FlutterRun<CR>", { desc = "Flutter: Run" })
        vim.keymap.set("n", "<leader>flR", ":FlutterRestart<CR>", { desc = "Flutter: Restart" })
        vim.keymap.set("n", "<leader>flh", ":FlutterHotReload<CR>", { desc = "Flutter: Hot Reload" })
        vim.keymap.set("n", "<leader>flH", ":FlutterHotRestart<CR>", { desc = "Flutter: Hot Restart" })
        vim.keymap.set("n", "<leader>flq", ":FlutterQuit<CR>", { desc = "Flutter: Quit" })
        vim.keymap.set("n", "<leader>fld", ":FlutterDevices<CR>", { desc = "Flutter: Devices" })
        vim.keymap.set("n", "<leader>fle", ":FlutterEmulators<CR>", { desc = "Flutter: Emulators" })
        vim.keymap.set("n", "<leader>flo", ":FlutterOutline<CR>", { desc = "Flutter: Outline" })
        vim.keymap.set("n", "<leader>fls", ":FlutterSuper<CR>", { desc = "Flutter: Super" })
        vim.keymap.set("n", "<leader>flw", ":FlutterWidgetInspector<CR>", { desc = "Flutter: Widget Inspector" })
        vim.keymap.set("n", "<leader>flc", ":FlutterClearLogs<CR>", { desc = "Flutter: Clear Logs" })
    end,
}
