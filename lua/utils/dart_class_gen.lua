local M = {}

-- 1. Парсинг полей (читает весь класс, но берет только поля)
local function parse_class_fields(class_content)
    local fields = {}
    for line in class_content:gmatch("[^\r\n]+") do
        -- Игнорируем методы (есть скобки), аннотации (@) и комментарии
        if line:match(";%s*$") and not line:match("%(") and not line:match("@") and not line:match("^%s*//") then
            local field_type, field_name = line:match("%s*([%w<>%[%]?,]+)%s+([%w_]+)%s*;")
            if field_type and field_name then
                table.insert(fields, {
                    type = field_type,
                    name = field_name,
                    is_nullable = field_type:match("%?$") ~= nil
                })
            end
        end
    end
    return fields
end

-- 2. Получение информации о классе
local function get_class_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    local class_start, class_name = nil, nil
    -- Ищем начало класса вверх от курсора
    for i = cursor_line, 1, -1 do
        local name = lines[i]:match("^%s*class%s+([%w_]+)")
        if name then
            class_name = name
            class_start = i
            break
        end
    end

    if not class_name then return nil end

    -- Ищем конец класса
    local class_end, brace_count, found_opening = nil, 0, false
    for i = class_start, #lines do
        for char in lines[i]:gmatch(".") do
            if char == "{" then
                brace_count = brace_count + 1
                found_opening = true
            elseif char == "}" then
                brace_count = brace_count - 1
                if found_opening and brace_count == 0 then
                    class_end = i
                    break
                end
            end
        end
        if class_end then break end
    end

    return class_name, class_start, class_end
end

-- 3. Генераторы (код тот же)
local function generate_constructor(class_name, fields)
    local params = {}
    for _, f in ipairs(fields) do
        table.insert(params, f.is_nullable and ("    this." .. f.name .. ",") or ("    required this." .. f.name .. ","))
    end
    return "  " .. class_name .. "({\n" .. table.concat(params, "\n") .. "\n  });"
end

local function generate_copy_with(class_name, fields)
    local params, assignments = {}, {}
    for _, f in ipairs(fields) do
        table.insert(params, "    " .. f.type .. "? " .. f.name .. ",")
        table.insert(assignments, "      " .. f.name .. ": " .. f.name .. " ?? this." .. f.name .. ",")
    end
    return "  " .. class_name .. " copyWith({\n" .. table.concat(params, "\n") .. "\n  }) {\n    return " ..
        class_name .. "(\n" .. table.concat(assignments, "\n") .. "\n    );\n  }"
end

local function generate_to_json(fields)
    local entries = {}
    for _, f in ipairs(fields) do table.insert(entries, "      '" .. f.name .. "': " .. f.name .. ",") end
    return "  Map<String, dynamic> toJson() {\n    return {\n" .. table.concat(entries, "\n") .. "\n    };\n  }"
end

local function generate_from_json(class_name, fields)
    local assignments = {}
    for _, f in ipairs(fields) do
        local key = "json['" .. f.name .. "']"
        local base = f.type:gsub("%?$", "")
        if base == "int" or base == "double" or base == "String" or base == "bool" or base == "num" then
            table.insert(assignments, "      " .. f.name .. ": " .. key .. " as " .. f.type .. ",")
        else
            local call = base .. ".fromJson(" .. key .. ")"
            if f.is_nullable then
                table.insert(assignments, "      " .. f.name .. ": " .. key .. " != nil ? " .. call .. " : null,")
            else
                table.insert(assignments, "      " .. f.name .. ": " .. call .. ",")
            end
        end
    end
    return "  factory " .. class_name .. ".fromJson(Map<String, dynamic> json) {\n    return " ..
        class_name .. "(\n" .. table.concat(assignments, "\n") .. "\n    );\n  }"
end

local function generate_to_string(class_name, fields)
    local f_str = {}
    for _, f in ipairs(fields) do table.insert(f_str, f.name .. ": $" .. f.name) end
    return "  @override\n  String toString() {\n    return '" ..
        class_name .. "(" .. table.concat(f_str, ", ") .. ")';\n  }"
end

local function generate_equality(class_name, fields)
    local conds = {}
    for _, f in ipairs(fields) do table.insert(conds, "        " .. f.name .. " == other." .. f.name) end
    local eq = "  @override\n  bool operator ==(Object other) {\n    if (identical(this, other)) return true;\n" ..
        "    return other is " .. class_name .. " &&\n" .. table.concat(conds, " &&\n") .. ";\n  }"
    local hash = "  @override\n  int get hashCode => Object.hash(" ..
        table.concat(vim.tbl_map(function(f) return f.name end, fields), ", ") .. ");"
    return eq .. "\n\n" .. hash
end

-- 4. Функция "Умного удаления"
-- Она ищет конкретный метод по паттерну и удаляет только его блок кода
local function remove_existing_method(lines, patterns, class_name)
    local new_lines = {}
    local i = 1

    while i <= #lines do
        local line = lines[i]
        local match_found = false

        for _, pat in ipairs(patterns) do
            -- Подставляем имя класса в паттерн, если нужно
            local final_pat = pat:gsub("CLASSNAME", class_name)
            if line:match(final_pat) then
                match_found = true
                -- Если нашли метод, считаем скобки и пропускаем его тело
                local brace_level = 0
                local started = false

                -- Проверка на аннотацию @override строкой выше (если мы её не захватили)
                if #new_lines > 0 and new_lines[#new_lines]:match("@override") then
                    table.remove(new_lines)
                end

                repeat
                    local curr = lines[i]
                    if not curr then break end
                    local _, opens = curr:gsub("{", "")
                    local _, closes = curr:gsub("}", "")
                    if opens > 0 then started = true end
                    brace_level = brace_level + opens - closes
                    i = i + 1
                until (started and brace_level <= 0) or (not curr:match("{") and curr:match(";%s*$"))
                break
            end
        end

        if not match_found then
            table.insert(new_lines, line)
            i = i + 1
        end
    end
    return new_lines
end

-- 5. Основная логика
M.generate_data_class_methods = function()
    local class_name, start_idx, end_idx = get_class_info()
    if not class_name then return Snacks.notify.error("Курсор не в классе") end

    local bufnr = vim.api.nvim_get_current_buf()
    -- Получаем только тело класса (включая скобки)
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_idx - 1, end_idx, false)
    local fields = parse_class_fields(table.concat(lines, "\n"))

    if #fields == 0 then return Snacks.notify.error("Поля не найдены") end

    local options = {
        "Конструктор",
        "JSON (toJson + fromJson)",
        "toString",
        "copyWith",
        "Equality (== + hash)",
        "Обновить всё (Пересоздать методы)"
    }

    Snacks.picker.select(options, { prompt = "Работа с методами: " .. class_name }, function(choice)
        if not choice then return end

        local methods_to_add = {}

        -- Логика: 1. Удаляем старую версию выбранного метода. 2. Генерируем новую.

        if choice == "Конструктор" then
            -- Паттерн: ИмяКласса({ или const ИмяКласса({ или ИмяКласса(
            lines = remove_existing_method(lines, { "^%s*const%s+CLASSNAME%s*%(", "^%s*CLASSNAME%s*%(" }, class_name)
            table.insert(methods_to_add, generate_constructor(class_name, fields))
        elseif choice == "JSON (toJson + fromJson)" then
            lines = remove_existing_method(lines, { "toJson", "fromJson" }, class_name)
            table.insert(methods_to_add, generate_to_json(fields))
            table.insert(methods_to_add, generate_from_json(class_name, fields))
        elseif choice == "toString" then
            lines = remove_existing_method(lines, { "toString" }, class_name)
            table.insert(methods_to_add, generate_to_string(class_name, fields))
        elseif choice == "copyWith" then
            lines = remove_existing_method(lines, { "copyWith" }, class_name)
            table.insert(methods_to_add, generate_copy_with(class_name, fields))
        elseif choice == "Equality (== + hash)" then
            lines = remove_existing_method(lines, { "operator%s*==", "hashCode" }, class_name)
            table.insert(methods_to_add, generate_equality(class_name, fields))
        elseif choice == "Обновить всё (Пересоздать методы)" then
            -- Удаляем ВСЕ поддерживаемые методы
            lines = remove_existing_method(lines, {
                "^%s*const%s+CLASSNAME%s*%(", "^%s*CLASSNAME%s*%(", -- Constructor
                "toJson", "fromJson", "copyWith", "toString", "operator%s*==", "hashCode"
            }, class_name)

            -- Добавляем всё в правильном порядке
            table.insert(methods_to_add, generate_constructor(class_name, fields))
            table.insert(methods_to_add, generate_copy_with(class_name, fields))
            table.insert(methods_to_add, generate_to_json(fields))
            table.insert(methods_to_add, generate_from_json(class_name, fields))
            table.insert(methods_to_add, generate_to_string(class_name, fields))
            table.insert(methods_to_add, generate_equality(class_name, fields))
        end

        -- Вставка новых методов
        -- Мы удаляем последнюю скобку '}', вставляем методы, потом возвращаем '}'
        if lines[#lines]:match("^%s*}%s*$") then
            table.remove(lines)
        end

        -- Добавляем пустую строку перед методами для красоты
        if #methods_to_add > 0 then
            table.insert(lines, "")
        end

        for _, method_code in ipairs(methods_to_add) do
            for l in method_code:gmatch("[^\r\n]+") do
                table.insert(lines, l)
            end
            table.insert(lines, "") -- Отступ между методами
        end

        table.insert(lines, "}")

        -- Применяем изменения в буфер
        vim.api.nvim_buf_set_lines(bufnr, start_idx - 1, end_idx, false, lines)

        -- Форматирование
        vim.defer_fn(function() vim.cmd("normal! =ap") end, 50)

        Snacks.notify.info("Методы обновлены: " .. choice)
    end)
end

return M
