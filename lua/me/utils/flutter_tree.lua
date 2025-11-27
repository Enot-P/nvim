-- Minimal Flutter Tree DSL parser and Dart code generator
-- Syntax examples:
--   SingleChild>Child
--   MultipleChild[ChildOne,ChildTwo>Nested]

local M = {}

-- Lexer ----------------------------------------------------------------------
local function is_ident_char(ch)
  return ch:match("[A-Za-z0-9_]") ~= nil
end

local function tokenize(input)
  local tokens = {}
  local i = 1
  local n = #input
  while i <= n do
    local ch = input:sub(i, i)
    if ch:match("%s") then
      i = i + 1
    elseif ch == '>' or ch == '[' or ch == ']' or ch == ',' or ch == '(' or ch == ')' then
      table.insert(tokens, { type = ch, value = ch })
      i = i + 1
    else
      if is_ident_char(ch) then
        local j = i
        while j <= n and is_ident_char(input:sub(j, j)) do
          j = j + 1
        end
        local ident = input:sub(i, j - 1)
        table.insert(tokens, { type = 'IDENT', value = ident })
        i = j
      else
        return nil, string.format("Неожиданный символ '%s' в позиции %d", ch, i)
      end
    end
  end
  table.insert(tokens, { type = 'EOF', value = '' })
  return tokens
end

-- Parser ---------------------------------------------------------------------
-- Grammar (упрощенная):
-- Node := IDENT [ '()' ] [ '>' Node | '[' Node (',' Node)* ']' ]
-- Примечание: скобки '()' после имени допускаем как синтаксический сахар, но параметры не поддерживаем.

local function Parser(tokens)
  return {
    tokens = tokens,
    pos = 1,

    peek = function(self)
      return self.tokens[self.pos]
    end,

    consume = function(self, expected)
      local t = self:peek()
      if expected and t.type ~= expected then
        error(string.format("Ожидался токен '%s', получен '%s'", expected, t.type))
      end
      self.pos = self.pos + 1
      return t
    end,

    try_consume = function(self, expected)
      local t = self:peek()
      if t.type == expected then
        self.pos = self.pos + 1
        return true
      end
      return false
    end,
  }
end

local function parse_node(p)
  local t = p:peek()
  if t.type ~= 'IDENT' then
    error("Ожидался идентификатор виджета")
  end
  local name = p:consume('IDENT').value

  -- optional '()'
  if p:try_consume('(') then
    if not p:try_consume(')') then
      error("Поддерживаются только пустые скобки '()' после имени виджета")
    end
  end

  local node = { name = name }

  local t2 = p:peek()
  if t2.type == '>' then
    p:consume('>')
    node.child = parse_node(p)
  elseif t2.type == '[' then
    p:consume('[')
    node.children = {}
    -- allow optional whitespace/comma patterns: Node (, Node)*
    if p:peek().type ~= ']' then
      repeat
        local child = parse_node(p)
        table.insert(node.children, child)
      until not p:try_consume(',')
    end
    p:consume(']')
  end

  return node
end

local function parse(input)
  local tokens, err = tokenize(input or "")
  if not tokens then return nil, err end
  local p = Parser(tokens)
  local ok, result = pcall(function()
    local root = parse_node(p)
    if p:peek().type ~= 'EOF' then
      error("Неожиданные токены после конца выражения")
    end
    return root
  end)
  if not ok then
    return nil, result
  end
  return result, nil
end

-- Codegen --------------------------------------------------------------------
local function indent_str(level)
  return string.rep("    ", level) -- 4 spaces
end

local function gen_node(node, level)
  level = level or 0
  local lines = {}
  local indent = indent_str(level)
  local open = string.format("%s%s(", indent, node.name)
  table.insert(lines, open)

  if node.child then
    table.insert(lines, string.format("%schild: %s", indent_str(level + 1), gen_node(node.child, level + 1)))
  elseif node.children then
    table.insert(lines, string.format("%schildren: <Widget>[", indent_str(level + 1)))
    for _, ch in ipairs(node.children) do
      local child_code = gen_node(ch, level + 2)
      table.insert(lines, child_code .. ",")
    end
    table.insert(lines, string.format("%s]", indent_str(level + 1)))
  end

  table.insert(lines, indent .. ")")

  -- collapse single-line child output if returned recursively
  return table.concat(lines, "\n")
end

function M.generate(input)
  local ast, err = parse(input)
  if not ast then
    return nil, err
  end
  local code = gen_node(ast, 0)
  -- Добавляем запятую в конце блока, как в примерах расширения
  return code .. ",\n"
end

-- Neovim integration ----------------------------------------------------------
local function get_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    return nil
  end
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))
  if ls == 0 or le == 0 then return nil end
  local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
  if #lines == 0 then return '' end
  lines[1] = string.sub(lines[1], cs)
  lines[#lines] = string.sub(lines[#lines], 1, ce)
  return table.concat(lines, "\n"), { ls = ls, le = le }
end

local function replace_range(range, text)
  vim.api.nvim_buf_set_lines(0, range.ls - 1, range.le, false, vim.split(text, "\n"))
end

local function insert_at_cursor(text)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, vim.split(text, "\n"))
end

function M.run()
  local selected, range = get_visual_selection()
  local source = selected or vim.api.nvim_get_current_line()
  if not source or source:gsub("%s+", "") == "" then
    source = vim.fn.input("FlutterTree > ")
  end
  if not source or source == '' then
    vim.notify("Пустой ввод", vim.log.levels.WARN)
    return
  end

  local code, err = M.generate(source)
  if not code then
    vim.notify("Ошибка FlutterTree: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  if range then
    replace_range(range, code)
  else
    insert_at_cursor(code)
  end
end

function M.setup()
  vim.api.nvim_create_user_command('FlutterTree', function()
    M.run()
  end, { desc = 'Flutter: Сгенерировать дерево виджетов из аббревиатуры' })
end

return M


