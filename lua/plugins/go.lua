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
-- 🧩 impl: выбор интерфейса из списка (без ручного pkg.Name)
-- ============================================================

-- По выбранному символу собираем аргумент для `impl`:
--  - тот же пакет, что и структура → просто имя интерфейса
--  - другой пакет → полный import-path + ".Name" (его impl всегда резолвит)
local function resolve_iface(item, origin_buf)
    local name = item and item.name
    if not name or name == "" then
        vim.notify("Не удалось определить имя интерфейса", vim.log.levels.ERROR)
        return nil
    end

    local sym_dir = item.file and vim.fn.fnamemodify(item.file, ":h")
    local cur_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(origin_buf), ":h")

    -- тот же пакет — квалификатор не нужен
    if not sym_dir or sym_dir == cur_dir then
        return name
    end

    local out = vim.system(
        { "go", "list", "-f", "{{.ImportPath}}" },
        { cwd = sym_dir, text = true }
    ):wait()

    if out.code == 0 then
        local importpath = vim.trim(out.stdout or "")
        if importpath ~= "" then
            return importpath .. "." .. name
        end
    end

    -- fallback: имя пакета из директории (может не совпасть с package-именем)
    vim.notify("go list не дал import-path, использую имя директории", vim.log.levels.WARN)
    return vim.fn.fnamemodify(sym_dir, ":t") .. "." .. name
end

local function impl_interface_picker()
    -- курсор должен стоять на структуре; запоминаем буфер, т.к. picker уводит фокус
    local origin_buf = vim.api.nvim_get_current_buf()

    Snacks.picker.lsp_workspace_symbols({
        filter = { default = { "Interface" }, go = { "Interface" } },
        confirm = function(picker, item)
            picker:close()
            if not item then
                return
            end
            -- после close фокус возвращается в исходное окно/структуру
            vim.schedule(function()
                local iface = resolve_iface(item, origin_buf)
                if iface then
                    require("gopher.impl").impl(iface)
                end
            end)
        end,
    })
end

-- ============================================================
-- 🏗️ constructor
-- ============================================================

-- Генерирует func NewX(...) *X после структуры под курсором. with_fields —
-- поля становятся аргументами; sync.* пропускаются, их нулевое значение
-- уже рабочее, а копировать мьютекс по значению нельзя.
local function gen_constructor(with_fields)
    local bufnr = vim.api.nvim_get_current_buf()
    local node = vim.treesitter.get_node()
    while node and not (node:type() == "type_spec" and node:field("type")[1]
            and node:field("type")[1]:type() == "struct_type") do
        node = node:parent()
    end
    if not node then
        vim.notify("Курсор не на структуре", vim.log.levels.WARN)
        return
    end

    local text = function(n) return vim.treesitter.get_node_text(n, bufnr) end
    local name = text(node:field("name")[1])

    -- дженерики: [K comparable, V any] -> в сигнатуре как есть, в типе [K, V]
    local tparams, targs = "", ""
    local tp = node:field("type_parameters")[1]
    if tp then
        tparams = text(tp)
        local names = {}
        for decl in tp:iter_children() do
            if decl:type() == "type_parameter_declaration" then
                for _, id in ipairs(decl:field("name")) do
                    table.insert(names, text(id))
                end
            end
        end
        targs = "[" .. table.concat(names, ", ") .. "]"
    end

    local params, inits = {}, {}
    if with_fields then
        local list = node:field("type")[1]:named_child(0)
        for field in (list and list:iter_children() or function() end) do
            if field:type() == "field_declaration" then
                local ids = field:field("name")
                -- встроенное поле: имя = имя типа без *, пакета и дженериков;
                -- '*' у него не входит в type-узел, поэтому берём текст поля
                local embedded = #ids == 0
                local ftype = embedded and vim.trim((text(field):gsub("%s*[`\"].*$", "")))
                    or text(field:field("type")[1])
                local names = {}
                if embedded then
                    names = { (ftype:gsub("^%*", ""):gsub("%[.*$", ""):gsub("^.*%.", "")) }
                else
                    for _, id in ipairs(ids) do
                        table.insert(names, text(id))
                    end
                end
                if not ftype:match("^%*?sync%.") then
                    for _, n in ipairs(names) do
                        -- TTL -> ttl, HTTPClient -> httpClient, Name -> name
                        local head, tail = n:match("^(%u+)(.*)$")
                        local arg = n
                        if head then
                            if #head > 1 and tail:match("^%l") then
                                head, tail = head:sub(1, -2), head:sub(-1) .. tail
                            end
                            arg = head:lower() .. tail
                        end
                        table.insert(params, arg .. " " .. ftype)
                        table.insert(inits, ("\t\t%s: %s,"):format(n, arg))
                    end
                end
            end
        end
    end

    local lines = { "", ("func New%s%s(%s) *%s%s {"):format(name, tparams, table.concat(params, ", "), name, targs) }
    if #inits == 0 then
        table.insert(lines, ("\treturn &%s%s{}"):format(name, targs))
    else
        table.insert(lines, ("\treturn &%s%s{"):format(name, targs))
        vim.list_extend(lines, inits)
        table.insert(lines, "\t}")
    end
    table.insert(lines, "}")

    -- вставляем после всего type-объявления (у type ( ... ) — после скобки)
    local decl = node:parent()
    local end_row = (decl and decl:type() == "type_declaration" and decl or node):end_()
    vim.api.nvim_buf_set_lines(bufnr, end_row + 1, end_row + 1, false, lines)

    if #inits > 0 then
        vim.api.nvim_win_set_cursor(0, { end_row + 3, 0 })
        return
    end

    -- пустой литерал отдаём gopls-экшену Fill: он проставит все поля с нулевыми
    -- значениями (sync.Map{}, "", 0, nil) — тот же код, что и в Code actions
    vim.api.nvim_win_set_cursor(0, { end_row + 4, #("\treturn &" .. name .. targs) })
    vim.lsp.buf.code_action({
        apply = true,
        filter = function(action) return action.title:match("^Fill ") ~= nil end,
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
        -- go определяет модуль по cwd, а не по аргументу-пути, поэтому запускаем
        -- из директории файла: иначе в репо без go.mod в корне будет
        -- "cannot find main module"
        local in_file_dir = function(cmd)
            vim.cmd("terminal cd " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " && " .. cmd)
        end

        map("<leader>gor", function() in_file_dir("go run .") end, "Run")
        map("<leader>gorr", function() in_file_dir("go run -race .") end, "Run with race")
        map("<leader>got", "<cmd>terminal go test ./...<cr>", "Test")
        map("<leader>goT", function() in_file_dir("go test .") end, "Test file")
        map("<leader>gof", "<cmd>terminal go test -fuzz=FuzzParsePrice -fuzztime=60s -v<cr>", "Fuzz: ParsePrice")
        map("<leader>goF", function()
            vim.ui.input({ prompt = "Fuzz function name (или . для всех): " }, function(name)
                if name and name ~= "" then
                    vim.cmd("terminal go test -fuzz=" .. name .. " -fuzztime=60s ./... -v")
                end
            end)
        end, "Fuzz: Custom")

        -- navigation
        map("<leader>a", function()
            local file = vim.fn.expand("%")
            if file:match("_test%.go$") then
                vim.cmd("edit " .. file:gsub("_test%.go$", ".go"))
            else
                vim.cmd("edit " .. file:gsub("%.go$", "_test.go"))
            end
        end, "Alt file")

        -- исходники stdlib/runtime: gopls ищет только объявления, а тут нужны
        -- комментарии, //go:linkname и .s-файлы
        local goroot_src = function()
            local out = vim.system({ "go", "env", "GOROOT" }, { text = true }):wait()
            return vim.trim(out.stdout or "") .. "/src"
        end
        map("<leader>fG", function() Snacks.picker.files({ cwd = goroot_src() }) end, "Find Files (GOROOT)")
        map("<leader>sG", function() Snacks.picker.grep({ cwd = goroot_src() }) end, "Grep (GOROOT)")

        -- coverage
        map(
            "<leader>c",
            function()
                vim.cmd("terminal go test -coverprofile=/tmp/cover.out ./... && go tool cover -html=/tmp/cover.out")
            end,
            "Coverage"
        )

        -- gopher
        -- gomodifytags вызывается с -file/-w, то есть работает с файлом на диске,
        -- а не с буфером: несохранённые правки он не видит, а его результат их ещё
        -- и затирает в буфере. Поэтому сохраняем перед каждым вызовом. Файл при
        -- этом обязан парситься — на синтаксической ошибке команда откажет целиком.
        local tag_cmd = function(cmd, args, range)
            vim.cmd("silent! update")
            vim.cmd((range or "") .. cmd .. " " .. args)
        end

        map("<leader>gtg", function() tag_cmd("GoTagAdd", "json") end, "Add json tags")
        map("<leader>gtr", function() tag_cmd("GoTagRm", "json") end, "Remove json tags")

        -- Любой тег, а не только json. Аргумент без '=' — тег, с '=' — опция
        -- (json=omitempty), несколько — через пробел.
        local tag_add = function(range)
            vim.ui.input({ prompt = "Tag (yaml, db, json=omitempty): " }, function(input)
                if input and input ~= "" then
                    tag_cmd("GoTagAdd", input, range)
                end
            end)
        end

        map("<leader>gta", function() tag_add() end, "Add any tag")
        vim.keymap.set("v", "<leader>gta", function()
            -- выходим из visual, чтобы проставились метки '< и '>: vim.ui.input
            -- асинхронный, к моменту колбэка выделения уже не будет
            vim.cmd("normal! \27")
            tag_add(("%d,%d"):format(vim.fn.line("'<"), vim.fn.line("'>")))
        end, { buffer = true, desc = "Add any tag (выделенные поля)" })
        map("<leader>gts", "<cmd>GoTestsAdd<cr>", "Generate tests")
        map("<leader>gie", "<cmd>GoIfErr<cr>", "Add if err")
        map("<leader>goc", function() gen_constructor(false) end, "Constructor (пустой)")
        map("<leader>goC", function() gen_constructor(true) end, "Constructor (поля в аргументах)")
        map("<leader>gdc", "<cmd>GoCmt<cr>", "Add doc comment")
        map("<leader>gii", impl_interface_picker, "Impl interface (picker)")
        map("<leader>giI", function()
            vim.ui.input({ prompt = "Interface (например: io.Reader): " }, function(input)
                if input and input ~= "" then
                    vim.cmd("GoImpl " .. input)
                end
            end)
        end, "Impl interface (ручной ввод)")

        -- migrations
        vim.keymap.set("n", "<leader>gmc", migrate_create, { desc = "Migrate: create" })
        vim.keymap.set("n", "<leader>gmu", function() migrate_run("up") end, { desc = "Migrate: up" })
        vim.keymap.set("n", "<leader>gmd", function() migrate_run("down") end, { desc = "Migrate: down" })
    end,
})

-------------- PACKAGES -----------------

vim.pack.add({
    { src = "https://github.com/olexsmir/gopher.nvim" },
    { src = "https://github.com/maxandron/goplements.nvim" }, -- Показывает какие интерфейсы реализует струтура
    { src = "https://github.com/fredrikaverpil/godoc.nvim" }, -- Документация
})

require("gopher").setup({
    commands = {
        go = "go",
        gomodifytags = "gomodifytags",
        gotests = "gotests",
        impl = "impl",
        iferr = "iferr",
    },
})
require("goplements").setup({})

-- Godoc: регистрация парсера и старт подсветки
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_godoc_start", { clear = true }),
    pattern = { "godoc" },
    callback = function(args)
        vim.treesitter.language.add("godoc", {
            path = "/home/enot/.local/share/nvim-dev/nvim-treesitter/parser/godoc.so",
        })
        vim.treesitter.language.register("godoc", "godoc")
        pcall(vim.treesitter.start, args.buf)
    end,
})

require("godoc").setup({
    window = { type = "vsplit" },
})
