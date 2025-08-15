-- Отладочная функция для просмотра структуры AST (только для случая когда поля не найдены)
local function debug_ast_structure(node, depth)
  if depth > 5 then return end

  local indent = string.rep("  ", depth)
  local node_type = node:type()
  local text = vim.treesitter.get_node_text(node, 0)

  -- Ограничиваем длину текста для читаемости
  if #text > 50 then
    text = text:sub(1, 50) .. "..."
  end
  text = text:gsub("\n", "\\n")

  print(indent .. node_type .. ": " .. text)

  -- Рекурсивно показываем дочерние узлы
  for child in node:iter_children() do
    debug_ast_structure(child, depth + 1)
  end
end

local M = {}

-- Вспомогательные функции для работы с Treesitter
local function get_dart_parser()
  local ok, parser = pcall(vim.treesitter.get_parser, 0, "dart")
  if not ok then
    vim.notify("Treesitter parser for Dart not found", vim.log.levels.ERROR)
    return nil
  end
  return parser
end

-- Найти класс в текущей позиции курсора
local function find_current_class()
  local parser = get_dart_parser()
  if not parser then return nil end

  local tree = parser:parse()[1]
  local root = tree:root()

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed

  -- Поиск узла класса
  local query = vim.treesitter.query.parse("dart", [[
    (class_definition
      name: (identifier) @class_name
      body: (class_body) @class_body) @class
  ]])

  for id, node, metadata in query:iter_captures(root, 0) do
    local capture_name = query.captures[id]
    if capture_name == "class" then
      local start_row, _, end_row, _ = node:range()
      if cursor_line >= start_row and cursor_line <= end_row then
        local class_name_node = nil
        local class_body_node = nil

        -- Получаем имя класса и тело
        for child_id, child_node in query:iter_captures(node, 0) do
          local child_capture = query.captures[child_id]
          if child_capture == "class_name" then
            class_name_node = child_node
          elseif child_capture == "class_body" then
            class_body_node = child_node
          end
        end

        if class_name_node and class_body_node then
          local class_name = vim.treesitter.get_node_text(class_name_node, 0)
          return {
            name = class_name,
            node = node,
            body_node = class_body_node,
            start_row = start_row,
            end_row = end_row
          }
        end
      end
    end
  end

  return nil
end

-- Анализ конструкторов класса
local function analyze_constructors(class_body_node, class_name)
  local start_row, start_col, end_row, end_col = class_body_node:range()
  local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

  local constructors = {}

  for line_num, line in ipairs(lines) do
    -- Ищем конструкторы по паттернам
    local patterns = {
      -- Основной конструктор: User(this.field1, this.field2)
      "^%s*" .. class_name .. "%s*%((.*)%);",
      -- Именованный конструктор: User.named(...)
      "^%s*" .. class_name .. "%.%w+%s*%((.*)%);",
      -- Const конструктор: const User(...)
      "^%s*const%s+" .. class_name .. "%s*%((.*)%);",
    }

    for _, pattern in ipairs(patterns) do
      local params = line:match(pattern)
      if params then
        print("Найден конструктор: " .. line:gsub("^%s+", ""):gsub("%s+$", ""))

        -- Анализируем параметры
        local constructor_info = {
          line = line:gsub("^%s+", ""):gsub("%s+$", ""),
          positional_params = {},
          named_params = {},
          required_params = {},
          optional_params = {}
        }

        -- Простой анализ параметров
        if params and params ~= "" then
          -- Убираем лишние пробелы
          params = params:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

          -- Проверяем на именованные параметры (наличие фигурных скобок)
          local has_named = params:match("{.*}")

          -- Разбираем параметры
          if has_named then
            -- Есть именованные параметры
            local before_named = params:match("^(.*)%{")
            local named_part = params:match("%{(.*)%}")

            if before_named and before_named:gsub("^%s+", ""):gsub("%s+$", "") ~= "" then
              -- Есть позиционные параметры перед именованными
              for param in before_named:gmatch("[^,]+") do
                param = param:gsub("^%s+", ""):gsub("%s+$", "")
                if param:match("this%.(%w+)") then
                  local field_name = param:match("this%.(%w+)")
                  table.insert(constructor_info.positional_params, field_name)
                  table.insert(constructor_info.required_params, field_name)
                end
              end
            end

            if named_part then
              for param in named_part:gmatch("[^,]+") do
                param = param:gsub("^%s+", ""):gsub("%s+$", "")
                if param:match("this%.(%w+)") then
                  local field_name = param:match("this%.(%w+)")
                  table.insert(constructor_info.named_params, field_name)
                  -- Проверяем на required
                  if param:match("required%s+") then
                    table.insert(constructor_info.required_params, field_name)
                  else
                    table.insert(constructor_info.optional_params, field_name)
                  end
                end
              end
            end
          else
            -- Только позиционные параметры
            for param in params:gmatch("[^,]+") do
              param = param:gsub("^%s+", ""):gsub("%s+$", "")
              if param:match("this%.(%w+)") then
                local field_name = param:match("this%.(%w+)")
                table.insert(constructor_info.positional_params, field_name)
                table.insert(constructor_info.required_params, field_name)
              end
            end
          end
        end

        print("  Позиционные: " .. table.concat(constructor_info.positional_params, ", "))
        print("  Именованные: " .. table.concat(constructor_info.named_params, ", "))

        table.insert(constructors, constructor_info)
        break -- Берем первый найденный конструктор
      end
    end
  end

  -- Если не найдено конструкторов, создаем дефолтный
  if #constructors == 0 then
    print("Конструкторы не найдены, используем дефолтную стратегию")
    return {
      line = "default",
      positional_params = {},
      named_params = {},
      required_params = {},
      optional_params = {}
    }
  end

  return constructors[1] -- Возвращаем первый конструктор
end

-- Очищенная функция извлечения полей класса (логи только при отсутствии полей)
local function extract_class_fields(class_body_node)
  local fields = {}
  local start_row, start_col, end_row, end_col = class_body_node:range()
  local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

  for line_num, line in ipairs(lines) do
    -- Пропускаем нерелевантные строки
    if line:match("^%s*class%s+") or
        line:match("^%s*}%s*$") or
        line:match("^%s*{%s*$") or
        line:match("^%s*$") or
        line:match("^%s*//") or
        line:match("^%s*/%*") or
        line:match("%*/") then
      goto continue
    end

    -- Пропускаем конструкторы и методы
    if line:match("%(.*%)") then
      goto continue
    end

    -- Поля должны заканчиваться точкой с запятой
    if not line:match(";%s*$") then
      goto continue
    end

    -- Паттерны для разных типов полей
    local patterns = {
      { pattern = "^%s*final%s+([^%s;]+)%s+([%w_]+)%s*;",          modifiers = { "final" } },
      { pattern = "^%s*const%s+([^%s;]+)%s+([%w_]+)%s*;",          modifiers = { "const" } },
      { pattern = "^%s*late%s+final%s+([^%s;]+)%s+([%w_]+)%s*;",   modifiers = { "late", "final" } },
      { pattern = "^%s*late%s+([^%s;]+)%s+([%w_]+)%s*;",           modifiers = { "late" } },
      { pattern = "^%s*static%s+final%s+([^%s;]+)%s+([%w_]+)%s*;", modifiers = { "static", "final" } },
      { pattern = "^%s*static%s+([^%s;]+)%s+([%w_]+)%s*;",         modifiers = { "static" } },
      { pattern = "^%s*([^%s;]+)%s+([%w_]+)%s*;",                  modifiers = {} }
    }

    for _, pattern_info in ipairs(patterns) do
      local field_type, field_name = line:match(pattern_info.pattern)

      if field_type and field_name then
        -- Проверяем, что имя поля не является ключевым словом
        local dart_keywords = {
          "abstract", "as", "assert", "async", "await", "break", "case", "catch",
          "class", "const", "continue", "default", "deferred", "do", "dynamic",
          "else", "enum", "export", "extends", "external", "factory", "false",
          "final", "finally", "for", "Function", "get", "hide", "if", "implements",
          "import", "in", "interface", "is", "late", "library", "mixin", "new",
          "null", "on", "operator", "part", "required", "rethrow", "return",
          "set", "show", "static", "super", "switch", "sync", "this", "throw",
          "true", "try", "typedef", "var", "void", "while", "with", "yield"
        }

        local is_keyword = false
        for _, keyword in ipairs(dart_keywords) do
          if field_name == keyword then
            is_keyword = true
            break
          end
        end

        if not is_keyword then
          -- Проверяем на дублирование
          local already_exists = false
          for _, existing_field in ipairs(fields) do
            if existing_field.name == field_name then
              already_exists = true
              break
            end
          end

          if not already_exists then
            table.insert(fields, {
              name = field_name,
              type = field_type,
              modifiers = pattern_info.modifiers,
              node = class_body_node
            })
          end
        end

        break
      end
    end

    ::continue::
  end

  -- Логи только если поля не найдены
  if #fields == 0 then
    print("=== ОТЛАДКА: ПОЛЯ НЕ НАЙДЕНЫ ===")
    print("Диапазон узла класса: строки " .. start_row .. "-" .. end_row)
    print("Анализируем строки:")

    for i, line in ipairs(lines) do
      print(string.format("  %d: '%s'", start_row + i - 1, line))

      -- Показываем причины пропуска для каждой строки
      if line:match("^%s*class%s+") then
        print("    → Пропуск: объявление класса")
      elseif line:match("^%s*}%s*$") then
        print("    → Пропуск: закрывающая скобка")
      elseif line:match("^%s*{%s*$") then
        print("    → Пропуск: открывающая скобка")
      elseif line:match("^%s*$") then
        print("    → Пропуск: пустая строка")
      elseif line:match("^%s*//") then
        print("    → Пропуск: комментарий")
      elseif line:match("%(.*%)") then
        print("    → Пропуск: содержит скобки (конструктор/метод)")
      elseif not line:match(";%s*$") then
        print("    → Пропуск: не заканчивается точкой с запятой")
      else
        print("    → Анализируется как потенциальное поле")

        -- Проверяем каждый паттерн
        local patterns_debug = {
          { pattern = "^%s*final%s+([^%s;]+)%s+([%w_]+)%s*;",          desc = "final field" },
          { pattern = "^%s*const%s+([^%s;]+)%s+([%w_]+)%s*;",          desc = "const field" },
          { pattern = "^%s*late%s+final%s+([^%s;]+)%s+([%w_]+)%s*;",   desc = "late final field" },
          { pattern = "^%s*late%s+([^%s;]+)%s+([%w_]+)%s*;",           desc = "late field" },
          { pattern = "^%s*static%s+final%s+([^%s;]+)%s+([%w_]+)%s*;", desc = "static final field" },
          { pattern = "^%s*static%s+([^%s;]+)%s+([%w_]+)%s*;",         desc = "static field" },
          { pattern = "^%s*([^%s;]+)%s+([%w_]+)%s*;",                  desc = "simple field" }
        }

        local matched = false
        for j, pattern_info in ipairs(patterns_debug) do
          local field_type, field_name = line:match(pattern_info.pattern)
          if field_type and field_name then
            print(string.format("      ✓ Совпал паттерн %d (%s): тип='%s', имя='%s'",
              j, pattern_info.desc, field_type, field_name))
            matched = true
            break
          end
        end

        if not matched then
          print("      ✗ Не совпал ни один паттерн")
        end
      end
    end

    print("==============================")
  end

  return fields
end


-- Проверить, существует ли уже метод в классе
local function method_exists(class_body_node, method_name)
  local start_row, start_col, end_row, end_col = class_body_node:range()
  local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

  local class_text = table.concat(lines, "\n")

  -- Ищем различные варианты определения методов
  if method_name == "toString" then
    return class_text:match("String%s+toString%s*%(") ~= nil or
        class_text:match("@override%s+String%s+toString") ~= nil
  elseif method_name == "copyWith" then
    return class_text:match("%w+%s+copyWith%s*%(") ~= nil
  elseif method_name == "==" then
    return class_text:match("bool%s+operator%s*==%s*%(") ~= nil or
        class_text:match("operator%s*==%s*%(") ~= nil
  end

  -- Общий поиск по имени метода
  return class_text:match(method_name .. "%s*%(") ~= nil
end

-- Генерация toString метода
local function generate_toString(class_name, fields)
  local field_strings = {}
  for _, field in ipairs(fields) do
    table.insert(field_strings, field.name .. ": $" .. field.name)
  end

  local toString_body = table.concat(field_strings, ", ")

  return {
    "  @override",
    "  String toString() {",
    "    return '" .. class_name .. "(" .. toString_body .. ")';",
    "  }"
  }
end

-- Улучшенная генерация copyWith с учетом конструктора
local function generate_copyWith_improved(class_name, fields, constructor_info)
  local lines = {}

  -- Параметры метода copyWith (всегда именованные и optional)
  local params = {}
  for _, field in ipairs(fields) do
    table.insert(params, "    " .. field.type .. "? " .. field.name)
  end

  table.insert(lines, "  " .. class_name .. " copyWith({")
  for i, param in ipairs(params) do
    if i == #params then
      table.insert(lines, param)
    else
      table.insert(lines, param .. ",")
    end
  end
  table.insert(lines, "  }) {")

  -- Генерируем вызов конструктора на основе анализа
  local constructor_call = "    return " .. class_name .. "("

  if constructor_info.line == "default" then
    -- Дефолтная стратегия - пробуем именованные параметры
    table.insert(lines, constructor_call)
    for i, field in ipairs(fields) do
      local assignment = "      " .. field.name .. ": " .. field.name .. " ?? this." .. field.name
      if i == #fields then
        table.insert(lines, assignment)
      else
        table.insert(lines, assignment .. ",")
      end
    end
  else
    -- На основе анализа конструктора
    if #constructor_info.positional_params > 0 and #constructor_info.named_params == 0 then
      -- Только позиционные параметры
      table.insert(lines, constructor_call)
      for i, field_name in ipairs(constructor_info.positional_params) do
        local assignment = "      " .. field_name .. " ?? this." .. field_name
        if i == #constructor_info.positional_params then
          table.insert(lines, assignment)
        else
          table.insert(lines, assignment .. ",")
        end
      end
    elseif #constructor_info.named_params > 0 then
      -- Есть именованные параметры
      table.insert(lines, constructor_call)

      -- Сначала позиционные
      for i, field_name in ipairs(constructor_info.positional_params) do
        local assignment = "      " .. field_name .. " ?? this." .. field_name .. ","
        table.insert(lines, assignment)
      end

      -- Затем именованные
      for i, field_name in ipairs(constructor_info.named_params) do
        local assignment = "      " .. field_name .. ": " .. field_name .. " ?? this." .. field_name
        if i == #constructor_info.named_params then
          table.insert(lines, assignment)
        else
          table.insert(lines, assignment .. ",")
        end
      end
    else
      -- Fallback - именованные параметры для всех полей
      table.insert(lines, constructor_call)
      for i, field in ipairs(fields) do
        local assignment = "      " .. field.name .. ": " .. field.name .. " ?? this." .. field.name
        if i == #fields then
          table.insert(lines, assignment)
        else
          table.insert(lines, assignment .. ",")
        end
      end
    end
  end

  table.insert(lines, "    );")
  table.insert(lines, "  }")

  return lines
end

-- Генерация operator == и hashCode
local function generate_equality(class_name, fields)
  local lines = {}

  -- operator ==
  table.insert(lines, "  @override")
  table.insert(lines, "  bool operator ==(Object other) {")
  table.insert(lines, "    if (identical(this, other)) return true;")
  table.insert(lines, "")
  table.insert(lines, "    return other is " .. class_name)

  for _, field in ipairs(fields) do
    table.insert(lines, "        && other." .. field.name .. " == " .. field.name)
  end
  table.insert(lines, "        ;")
  table.insert(lines, "  }")

  table.insert(lines, "")

  -- hashCode
  table.insert(lines, "  @override")
  if #fields == 0 then
    table.insert(lines, "  int get hashCode => 0;")
  elseif #fields == 1 then
    table.insert(lines, "  int get hashCode => " .. fields[1].name .. ".hashCode;")
  else
    local hash_fields = {}
    for _, field in ipairs(fields) do
      table.insert(hash_fields, field.name)
    end
    table.insert(lines, "  int get hashCode => Object.hash(" .. table.concat(hash_fields, ", ") .. ");")
  end

  return lines
end

-- Основная функция генерации data class методов
function M.generate_data_class_methods(options)
  options = options or {}
  local include_toString = options.toString ~= false
  local include_copyWith = options.copyWith ~= false
  local include_equality = options.equality ~= false

  local class_info = find_current_class()
  if not class_info then
    vim.notify("Не удалось найти класс в текущей позиции курсора", vim.log.levels.WARN)
    return
  end

  local fields = extract_class_fields(class_info.body_node)
  if #fields == 0 then
    vim.notify("В классе " .. class_info.name .. " не найдено полей", vim.log.levels.WARN)
    return
  end

  print("Найдено полей: " .. #fields)
  for i, field in ipairs(fields) do
    print("  " .. i .. ". " .. field.name .. " (" .. field.type .. ")")
  end

  -- Анализируем конструкторы
  local constructor_info = analyze_constructors(class_info.body_node, class_info.name)

  local lines_to_insert = {}
  local methods_added = {}

  table.insert(lines_to_insert, "")

  -- toString
  if include_toString and not method_exists(class_info.body_node, "toString") then
    local toString_lines = generate_toString(class_info.name, fields)
    for _, line in ipairs(toString_lines) do
      table.insert(lines_to_insert, line)
    end
    table.insert(lines_to_insert, "")
    table.insert(methods_added, "toString")
  end

  -- copyWith с анализом конструктора
  if include_copyWith and not method_exists(class_info.body_node, "copyWith") then
    local copyWith_lines = generate_copyWith_improved(class_info.name, fields, constructor_info)
    for _, line in ipairs(copyWith_lines) do
      table.insert(lines_to_insert, line)
    end
    table.insert(lines_to_insert, "")
    table.insert(methods_added, "copyWith")
  end

  -- equality
  if include_equality then
    local has_equals = method_exists(class_info.body_node, "==")
    local start_row, start_col, end_row, end_col = class_info.body_node:range()
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
    local class_text = table.concat(lines, "\n")
    local has_hashCode = class_text:match("int%s+get%s+hashCode") ~= nil

    if not has_equals or not has_hashCode then
      local equality_lines = generate_equality(class_info.name, fields)
      for _, line in ipairs(equality_lines) do
        table.insert(lines_to_insert, line)
      end
      table.insert(methods_added, "operator == и hashCode")
    end
  end

  if #lines_to_insert > 1 then
    local insert_line = class_info.end_row
    vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, lines_to_insert)
    vim.notify("Добавлены методы: " .. table.concat(methods_added, ", "), vim.log.levels.INFO)
  else
    vim.notify("Все методы уже существуют в классе", vim.log.levels.INFO)
  end
end

-- Интерактивный выбор методов для генерации
function M.generate_data_class_interactive()
  local class_info = find_current_class()
  if not class_info then
    vim.notify("Не удалось найти класс в текущей позиции курсора", vim.log.levels.WARN)
    return
  end

  local fields = extract_class_fields(class_info.body_node)
  if #fields == 0 then
    vim.notify("В классе " .. class_info.name .. " не найдено полей", vim.log.levels.WARN)
    return
  end

  -- Проверяем какие методы уже существуют
  local has_toString = method_exists(class_info.body_node, "toString")
  local has_copyWith = method_exists(class_info.body_node, "copyWith")
  local has_equals = method_exists(class_info.body_node, "==")

  -- Создаем список опций
  local choices = {}
  if not has_toString then
    table.insert(choices, { name = "toString", desc = "Генерировать toString метод" })
  end
  if not has_copyWith then
    table.insert(choices, { name = "copyWith", desc = "Генерировать copyWith метод" })
  end
  if not has_equals then
    table.insert(choices, { name = "equality", desc = "Генерировать operator == и hashCode" })
  end
  table.insert(choices, { name = "all", desc = "Генерировать все доступные методы" })

  if #choices == 1 and choices[1].name == "all" then
    vim.notify("Все методы data class уже существуют", vim.log.levels.INFO)
    return
  end

  -- Показываем меню выбора
  vim.ui.select(choices, {
    prompt = "Выберите методы для генерации:",
    format_item = function(item)
      return item.desc
    end,
  }, function(choice)
    if not choice then return end

    local options = {}
    if choice.name == "toString" then
      options = { toString = true, copyWith = false, equality = false }
    elseif choice.name == "copyWith" then
      options = { toString = false, copyWith = true, equality = false }
    elseif choice.name == "equality" then
      options = { toString = false, copyWith = false, equality = true }
    else -- all
      options = { toString = true, copyWith = true, equality = true }
    end

    M.generate_data_class_methods(options)
  end)
end

-- Генерация конструктора data class
function M.generate_constructor()
  vim.notify("Функция генерации конструктора удалена", vim.log.levels.INFO)
end

-- В конец файла добавьте:
function M.debug_current_class()
  local class_info = find_current_class()
  if class_info then
    print("=== ОТЛАДКА КЛАССА ===")
    print("Имя класса: " .. class_info.name)
    local start_row, _, end_row, _ = class_info.body_node:range()
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
    for i, line in ipairs(lines) do
      print(string.format("Строка %d: '%s' (длина: %d)", i, line, #line))
      -- Показываем ASCII коды для первых/последних символов
      if #line > 0 then
        print(string.format("  Первый символ: %d, последний: %d",
          string.byte(line, 1), string.byte(line, -1)))
      end
    end
    extract_class_fields(class_info.body_node)
  end
end

return M
