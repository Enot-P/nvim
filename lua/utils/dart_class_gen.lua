local M = {}

-- Функция для парсинга полей класса
local function parse_class_fields(class_content)
    local fields = {}

    -- Ищем все поля класса (например: "  String name;" или "  final int age;")
    for line in class_content:gmatch("[^\r\n]+") do
        -- Пропускаем комментарии и пустые строки
        if not line:match("^%s*//") and not line:match("^%s*$") then
            -- Ищем объявления полей: [final] Type name;
            local final_modifier = line:match("^%s*(final)%s+")
            local field_type, field_name = line:match("%s*(?:final%s+)?([%w<>%[%]?,]+)%s+([%w_]+)%s*;")

            if not field_type then
                -- Попытка без final
                field_type, field_name = line:match("%s*([%w<>%[%]?,]+)%s+([%w_]+)%s*;")
            end

            if field_type and field_name then
                table.insert(fields, {
                    type = field_type,
                    name = field_name,
                    is_final = final_modifier ~= nil,
                    is_nullable = field_type:match("%?$") ~= nil
                })
            end
        end
    end

    return fields
end

-- Функция для получения имени класса и его содержимого
local function get_class_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Ищем начало класса (идём вверх от курсора)
    local class_start = nil
    local class_name = nil

    for i = cursor_line, 1, -1 do
        local line = lines[i]
        local name = line:match("^%s*class%s+([%w_]+)")
        if name then
            class_name = name
            class_start = i
            break
        end
    end

    if not class_name or not class_start then
        return nil, nil, nil, nil
    end

    -- Ищем конец класса (первую закрывающую скобку на том же уровне)
    local class_end = nil
    local brace_count = 0
    local found_opening = false

    for i = class_start, #lines do
        local line = lines[i]

        for char in line:gmatch(".") do
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

        if class_end then
            break
        end
    end

    if not class_end then
        return nil, nil, nil, nil
    end

    -- Получаем содержимое класса
    local class_lines = {}
    for i = class_start, class_end do
        table.insert(class_lines, lines[i])
    end
    local class_content = table.concat(class_lines, "\n")

    return class_name, class_content, class_start, class_end
end

-- Генерация конструктора
local function generate_constructor(class_name, fields)
    local params = {}

    for _, field in ipairs(fields) do
        if field.is_nullable then
            table.insert(params, "    this." .. field.name .. ",")
        else
            table.insert(params, "    required this." .. field.name .. ",")
        end
    end

    local constructor = "  " .. class_name .. "({\n"
        .. table.concat(params, "\n") .. "\n"
        .. "  });"

    return constructor
end

-- Генерация copyWith
local function generate_copy_with(class_name, fields)
    local params = {}
    local assignments = {}

    for _, field in ipairs(fields) do
        table.insert(params, "    " .. field.type .. "? " .. field.name .. ",")
        table.insert(assignments, "      " .. field.name .. ": " .. field.name .. " ?? this." .. field.name .. ",")
    end

    local copy_with = "  " .. class_name .. " copyWith({\n"
        .. table.concat(params, "\n") .. "\n"
        .. "  }) {\n"
        .. "    return " .. class_name .. "(\n"
        .. table.concat(assignments, "\n") .. "\n"
        .. "    );\n"
        .. "  }"

    return copy_with
end

-- Генерация toJson
local function generate_to_json(fields)
    local map_entries = {}

    for _, field in ipairs(fields) do
        table.insert(map_entries, "      '" .. field.name .. "': " .. field.name .. ",")
    end

    local to_json = "  Map<String, dynamic> toJson() {\n"
        .. "    return {\n"
        .. table.concat(map_entries, "\n") .. "\n"
        .. "    };\n"
        .. "  }"

    return to_json
end

-- Генерация fromJson
local function generate_from_json(class_name, fields)
    local assignments = {}

    for _, field in ipairs(fields) do
        local json_key = "json['" .. field.name .. "']"
        local base_type = field.type:gsub("%?$", "")

        -- Определяем, нужно ли приведение типа
        if base_type == "int" or base_type == "double" or base_type == "num" then
            if field.is_nullable then
                table.insert(assignments, "      " .. field.name .. ": " .. json_key .. " as " .. field.type .. ",")
            else
                table.insert(assignments, "      " .. field.name .. ": " .. json_key .. " as " .. base_type .. ",")
            end
        elseif base_type == "String" or base_type == "bool" then
            if field.is_nullable then
                table.insert(assignments, "      " .. field.name .. ": " .. json_key .. " as " .. field.type .. ",")
            else
                table.insert(assignments, "      " .. field.name .. ": " .. json_key .. " as " .. base_type .. ",")
            end
        else
            -- Для пользовательских типов предполагаем, что у них есть fromJson
            if field.is_nullable then
                table.insert(assignments,
                    "      " ..
                    field.name ..
                    ": " .. json_key .. " != null ? " .. base_type .. ".fromJson(" .. json_key .. ") : null,")
            else
                table.insert(assignments, "      " .. field.name .. ": " .. base_type .. ".fromJson(" .. json_key .. "),")
            end
        end
    end

    local from_json = "  factory " .. class_name .. ".fromJson(Map<String, dynamic> json) {\n"
        .. "    return " .. class_name .. "(\n"
        .. table.concat(assignments, "\n") .. "\n"
        .. "    );\n"
        .. "  }"

    return from_json
end

-- Генерация toString
local function generate_to_string(class_name, fields)
    local field_strings = {}

    for _, field in ipairs(fields) do
        table.insert(field_strings, field.name .. ": $" .. field.name)
    end

    local to_string = "  @override\n"
        .. "  String toString() {\n"
        .. "    return '" .. class_name .. "(" .. table.concat(field_strings, ", ") .. ")';\n"
        .. "  }"

    return to_string
end

-- Генерация operator ==
local function generate_equals(class_name, fields)
    local comparisons = {}

    for _, field in ipairs(fields) do
        table.insert(comparisons, "        " .. field.name .. " == other." .. field.name)
    end

    local equals = "  @override\n"
        .. "  bool operator ==(Object other) {\n"
        .. "    if (identical(this, other)) return true;\n"
        .. "    return other is " .. class_name .. " &&\n"
        .. table.concat(comparisons, " &&\n") .. ";\n"
        .. "  }"

    return equals
end

-- Генерация hashCode
local function generate_hash_code(fields)
    local field_names = {}

    for _, field in ipairs(fields) do
        table.insert(field_names, field.name)
    end

    local hash_code = "  @override\n"
        .. "  int get hashCode => Object.hash(" .. table.concat(field_names, ", ") .. ");"

    return hash_code
end

-- Основная функция
M.generate_data_class_methods = function()
    local class_name, class_content, class_start, class_end = get_class_info()

    if not class_name then
        Snacks.notify.error("Курсор не находится в классе")
        return
    end

    local fields = parse_class_fields(class_content)

    if #fields == 0 then
        Snacks.notify.error("Не найдено полей в классе " .. class_name)
        return
    end

    -- Показываем список методов для генерации
    local method_options = {
        "Все методы",
        "Конструктор",
        "copyWith",
        "toJson",
        "fromJson",
        "toString",
        "operator ==",
        "hashCode",
        "toJson + fromJson",
        "Equatable (== + hashCode)",
    }

    Snacks.picker.select(method_options, { prompt = "Выберите что генерировать" }, function(choice)
        if not choice then
            return
        end

        local methods = {}

        if choice == "Все методы" then
            table.insert(methods, generate_constructor(class_name, fields))
            table.insert(methods, generate_copy_with(class_name, fields))
            table.insert(methods, generate_to_json(fields))
            table.insert(methods, generate_from_json(class_name, fields))
            table.insert(methods, generate_to_string(class_name, fields))
            table.insert(methods, generate_equals(class_name, fields))
            table.insert(methods, generate_hash_code(fields))
        elseif choice == "Конструктор" then
            table.insert(methods, generate_constructor(class_name, fields))
        elseif choice == "copyWith" then
            table.insert(methods, generate_copy_with(class_name, fields))
        elseif choice == "toJson" then
            table.insert(methods, generate_to_json(fields))
        elseif choice == "fromJson" then
            table.insert(methods, generate_from_json(class_name, fields))
        elseif choice == "toString" then
            table.insert(methods, generate_to_string(class_name, fields))
        elseif choice == "operator ==" then
            table.insert(methods, generate_equals(class_name, fields))
        elseif choice == "hashCode" then
            table.insert(methods, generate_hash_code(fields))
        elseif choice == "toJson + fromJson" then
            table.insert(methods, generate_to_json(fields))
            table.insert(methods, generate_from_json(class_name, fields))
        elseif choice == "Equatable (== + hashCode)" then
            table.insert(methods, generate_equals(class_name, fields))
            table.insert(methods, generate_hash_code(fields))
        end

        -- Вставляем методы перед закрывающей скобкой класса
        local bufnr = vim.api.nvim_get_current_buf()
        local insert_line = class_end - 1

        -- Разбиваем каждый метод на отдельные строки
        local lines_to_insert = {}
        table.insert(lines_to_insert, "") -- Пустая строка перед методами

        for _, method in ipairs(methods) do
            -- Разбиваем метод по символам переноса строки
            for line in method:gmatch("[^\r\n]+") do
                table.insert(lines_to_insert, line)
            end
        end

        vim.api.nvim_buf_set_lines(bufnr, insert_line, insert_line, false, lines_to_insert)

        Snacks.notify.info("Методы успешно добавлены в класс " .. class_name)
    end)
end

return M
