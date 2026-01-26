local M = {}

-- 1. Извлекаем только поля класса
local function parse_class_fields(class_content)
    local fields = {}
    for line in class_content:gmatch("[^\r\n]+") do
        -- Ищем строки вида: "String name;" или "final int? id;"
        -- Исключаем строки с методами (содержат "(") и аннотации
        if line:match(";%s*$") and not line:match("%(") and not line:match("@") then
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

-- 2. Получаем границы и имя класса
local function get_class_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    local class_start, class_name = nil, nil
    for i = cursor_line, 1, -1 do
        local name = lines[i]:match("^%s*class%s+([%w_]+)")
        if name then
            class_name = name
            class_start = i
            break
        end
    end

    if not class_name then return nil end

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

-- 3. Функции генерации (без изменений в логике)
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

-- 4. Главная логика: Полная переборка класса
M.generate_data_class_methods = function()
    local class_name, start_idx, end_idx = get_class_info()
    if not class_name then
        return Snacks.notify.error("Курсор не в классе Dart")
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local original_lines = vim.api.nvim_buf_get_lines(bufnr, start_idx - 1, end_idx, false)

    -- Шаг 1: Извлекаем поля
    local fields = parse_class_fields(table.concat(original_lines, "\n"))
    if #fields == 0 then return Snacks.notify.error("Поля не найдены") end

    -- Шаг 2: Создаем новый чистый список строк (только заголовок класса и поля)
    local new_content = {}
    table.insert(new_content, "class " .. class_name .. " {")

    for _, f in ipairs(fields) do
        table.insert(new_content, "  " .. f.type .. " " .. f.name .. ";")
    end

    -- Шаг 3: Выбор методов для добавления
    local options = { "Обновить всё", "Конструктор", "JSON", "copyWith", "Equality" }

    Snacks.picker.select(options, { prompt = "Data Class Generator (" .. class_name .. ")" }, function(choice)
        if not choice then return end

        local function add_section(text)
            table.insert(new_content, "")
            for line in text:gmatch("[^\r\n]+") do table.insert(new_content, line) end
        end

        if choice == "Обновить всё" or choice == "Конструктор" then add_section(generate_constructor(class_name, fields)) end
        if choice == "Обновить всё" or choice == "copyWith" then add_section(generate_copy_with(class_name, fields)) end
        if choice == "Обновить всё" or choice == "JSON" then
            add_section(generate_to_json(fields))
            add_section(generate_from_json(class_name, fields))
        end
        if choice == "Обновить всё" then add_section(generate_to_string(class_name, fields)) end
        if choice == "Обновить всё" or choice == "Equality" then add_section(generate_equality(class_name, fields)) end

        table.insert(new_content, "}")

        -- Шаг 4: Полная замена старого кода новым
        vim.api.nvim_buf_set_lines(bufnr, start_idx - 1, end_idx, false, new_content)

        -- Вызываем форматирование через небольшую паузу
        vim.defer_fn(function()
            vim.cmd("normal! =ap")
        end, 50)

        Snacks.notify.info("Класс " .. class_name .. " полностью пересобран!")
    end)
end

return M
