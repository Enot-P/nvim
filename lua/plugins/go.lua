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
-- 🧵 go func() {...}()  <->  wg.Go(func() {...})
-- ============================================================

-- Переключает ближайшую к курсору горутину. В сторону wg.Go заодно съедает
-- старый паттерн wg.Add(1) перед go и defer wg.Done() первой строкой тела.
-- Обратно разворачивает в голый go func() {...}().
local function goroutine_toggle()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.treesitter.get_parser(bufnr):parse()
    local text = function(n) return vim.treesitter.get_node_text(n, bufnr) end

    -- X.Method(args) -> X, иначе nil
    local selector_call = function(call, method)
        if not (call and call:type() == "call_expression") then
            return nil
        end
        local fn = call:field("function")[1]
        if fn:type() ~= "selector_expression" or text(fn:field("field")[1]) ~= method then
            return nil
        end
        return text(fn:field("operand")[1])
    end

    -- строка содержит только этот узел — её можно удалять целиком
    local alone_on_line = function(n)
        local row = n:start()
        return n:end_() == row and vim.trim(vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]) == text(n)
    end

    -- имя WaitGroup, объявленной в объемлющей функции выше строки row
    local find_wg_name = function(node, row)
        local fn
        for p in function(_, n) return n:parent() end, nil, node do
            if p:type() == "function_declaration" or p:type() == "method_declaration" then
                fn = p
            elseif p:type() == "func_literal" and not fn then
                fn = p
            end
        end
        if not fn then
            return nil
        end
        local src = table.concat(vim.api.nvim_buf_get_lines(bufnr, fn:start(), row, false), "\n")
        -- var wg sync.WaitGroup / wg *sync.WaitGroup (параметр, поле)
        -- wg := sync.WaitGroup{} / &sync.WaitGroup{} / new(sync.WaitGroup)
        return src:match("([%w_]+)%s+%*?sync%.WaitGroup")
            or src:match("([%w_]+)%s*:?=%s*&?sync%.WaitGroup")
            or src:match("([%w_]+)%s*:?=%s*new%(sync%.WaitGroup%)")
    end

    local function to_wg_go(stmt)
        local call = stmt:named_child(0)
        local lit = call:field("function")[1]
        if call:field("arguments")[1]:named_child_count() > 0
            or lit:field("parameters")[1]:named_child_count() > 0 then
            vim.notify("wg.Go принимает только func() — уберите аргументы горутины", vim.log.levels.WARN)
            return
        end

        local prev = stmt:prev_named_sibling()
        local add = prev and prev:type() == "expression_statement" and alone_on_line(prev)
            and prev:named_child(0):field("arguments")[1]
            and text(prev:named_child(0):field("arguments")[1]) == "(1)"
            and selector_call(prev:named_child(0), "Add")
        local name = add or find_wg_name(stmt, stmt:start())

        -- defer wg.Done() первой строкой тела больше не нужен
        local lines = vim.split(text(lit), "\n")
        local body = lit:field("body")[1]:named_child(0)
        if body and body:type() == "statement_list" then
            body = body:named_child(0)
        end
        if body and body:type() == "defer_statement" and alone_on_line(body)
            and selector_call(body:named_child(0), "Done") == (name or "wg") then
            table.remove(lines, body:start() - lit:start() + 1)
        end

        lines[1] = (name or "wg") .. ".Go(" .. lines[1]
        lines[#lines] = lines[#lines] .. ")"

        local sr, sc, er, ec = stmt:range()
        vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, lines)
        if add then
            vim.api.nvim_buf_set_lines(bufnr, prev:start(), prev:start() + 1, false, {})
        elseif not name then
            local indent = vim.api.nvim_buf_get_lines(bufnr, sr, sr + 1, false)[1]:match("^%s*")
            vim.api.nvim_buf_set_lines(bufnr, sr, sr, false, { indent .. "var wg sync.WaitGroup" })
        end
    end

    local node = vim.treesitter.get_node()
    while node do
        -- go func() {...}()
        if node:type() == "go_statement" then
            local call = node:named_child(0)
            if call and call:type() == "call_expression" and call:field("function")[1]:type() == "func_literal" then
                return to_wg_go(node)
            end
        end
        -- wg.Go(func() {...})
        if selector_call(node, "Go") then
            local args = node:field("arguments")[1]
            local lit = args:named_child_count() == 1 and args:named_child(0)
            if lit and lit:type() == "func_literal" then
                local lines = vim.split(text(lit), "\n")
                lines[1] = "go " .. lines[1]
                lines[#lines] = lines[#lines] .. "()"
                local sr, sc, er, ec = node:range()
                vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, lines)
                return
            end
        end
        node = node:parent()
    end
    vim.notify("Курсор не в go func() {...}() и не в wg.Go(func() {...})", vim.log.levels.WARN)
end

-- ============================================================
-- 🛝 playground: одноразовый модуль для быстрой проверки идеи
-- ============================================================

-- Модуль в /tmp: с go.mod gopls работает полноценно, go get и тесты тоже.
-- Удалять руками не нужно — /tmp чистится при перезагрузке.
local playground_files = {
    ["main.go"] = {
        "package main",
        "",
        'import "fmt"',
        "",
        "func main() {",
        '\tfmt.Println("hello")',
        "}",
    },
    ["main_test.go"] = {
        "package main",
        "",
        'import "testing"',
        "",
        "func TestPlay(t *testing.T) {",
        "}",
    },
}

local function go_playground()
    local dir = vim.trim(vim.fn.system({ "mktemp", "-d", "/tmp/goplay-XXXX" }))
    local out = vim.system({ "go", "mod", "init", "play" }, { cwd = dir, text = true }):wait()
    if out.code ~= 0 then
        vim.notify("go mod init:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
        return
    end
    for name, lines in pairs(playground_files) do
        vim.fn.writefile(lines, dir .. "/" .. name)
    end

    -- своя вкладка со своим cwd, чтобы не сбить cwd текущего проекта;
    -- пустой стартовый буфер (nvim без аргументов) переиспользуем
    local buf = vim.api.nvim_get_current_buf()
    local empty = vim.api.nvim_buf_get_name(buf) == "" and not vim.bo[buf].modified
    if not empty then
        vim.cmd("tabnew")
    end
    vim.cmd("tcd " .. vim.fn.fnameescape(dir))
    vim.cmd("edit main.go")
    vim.api.nvim_win_set_cursor(0, { 6, 0 })
end

vim.api.nvim_create_user_command("GoPlay", go_playground, { desc = "Go playground в /tmp" })
vim.keymap.set("n", "<leader>gop", go_playground, { desc = "Go playground" })

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

        map("<leader>gos", sqlc_generate, "SQLC Generate")

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
        map("<leader>goe", "<cmd>GoIfErr<cr>", "Add if err")
        map("<leader>gow", goroutine_toggle, "go func() <-> wg.Go")
        map("<leader>goc", function() gen_constructor(false) end, "Constructor (пустой)")
        map("<leader>goC", function() gen_constructor(true) end, "Constructor (поля в аргументах)")
        map("<leader>god", "<cmd>GoCmt<cr>", "Add doc comment")
        map("<leader>goi", impl_interface_picker, "Impl interface (picker)")
        map("<leader>goI", function()
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
