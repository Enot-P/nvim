local M = {}

local session_defaults = {
  open_main_file = true,
  generate_barrel = true,
}

local user_opts = {
  defaults = {},
}

local function merge_tables(base, override)
  local result = {}
  for k, v in pairs(base or {}) do
    result[k] = v
  end
  for k, v in pairs(override or {}) do
    result[k] = v
  end
  return result
end

function M.setup(opts)
  user_opts = opts or {}
end

-- string utils
local function to_snake_case(str)
  local s = str
  s = s:gsub("[^%w]+", "_")
  s = s:gsub("(%l)(%u)", "%1_%2")
  s = s:gsub("(%d)(%a)", "%1_%2")
  s = s:gsub("(%a)(%d)", "%1_%2")
  s = s:gsub("_+", "_")
  s = s:gsub("^_+", ""):gsub("_+$", "")
  return s:lower()
end

local function to_pascal_case(str)
  -- Нормализуем: заменим все не-алфанум символы на пробелы
  local s = str:gsub("[^%w]+", " ")
  -- Разобьём CamelCase границы на пробелы: aB -> a B; ABCd -> AB Cd
  s = s:gsub("(%l)(%u)", "%1 %2")
  s = s:gsub("(%u)(%u%l)", "%1 %2")
  -- Разделим границы между цифрами и буквами
  s = s:gsub("(%d)(%a)", "%1 %2")
  s = s:gsub("(%a)(%d)", "%1 %2")
  local out = {}
  for w in s:gmatch("%w+") do
    local lower = w:lower()
    table.insert(out, lower:sub(1,1):upper() .. lower:sub(2))
  end
  return table.concat(out, "")
end

-- fs utils
local function path_join(a, b)
  if a:sub(-1) == "/" then return a .. b end
  return a .. "/" .. b
end

local function exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

local function is_dir(path)
  local st = vim.uv.fs_stat(path)
  return st and st.type == "directory"
end

local function mkdirp(path)
  if exists(path) then return true end
  return vim.fn.mkdir(path, "p") == 1
end

local function write_file(path, lines)
  mkdirp(vim.fn.fnamemodify(path, ":h"))
  return vim.fn.writefile(type(lines) == "string" and vim.split(lines, "\n", { plain = true }) or lines, path) == 0
end

-- project root detection
local function find_upwards(start_dir, target)
  local dir = start_dir
  while dir and dir ~= "/" do
    local candidate = path_join(dir, target)
    if exists(candidate) then return dir end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end
  return nil
end

local function detect_package_root(dir)
  return find_upwards(dir, "pubspec.yaml")
end

-- pubspec.yaml parsing (honors indentation for sections)
local function read_pubspec_yaml(project_root)
  local pubspec_path = path_join(project_root, "pubspec.yaml")
  if not exists(pubspec_path) then
    return nil
  end

  local lines = vim.fn.readfile(pubspec_path)
  if not lines or #lines == 0 then
    return nil
  end

  local dependencies = {}
  local dev_dependencies = {}
  local in_dependencies = false
  local in_dev_dependencies = false

  for _, raw in ipairs(lines) do
    local trimmed = raw:gsub("^%s+", ""):gsub("%s+$", "")

    -- skip empty/comment
    if trimmed == "" or trimmed:match("^#") then goto continue end

    -- section headers (must be top-level: no leading spaces in raw)
    if raw:match("^%S") then
      if trimmed == "dependencies:" then
        in_dependencies = true
        in_dev_dependencies = false
        goto continue
      elseif trimmed == "dev_dependencies:" then
        in_dependencies = false
        in_dev_dependencies = true
        goto continue
      elseif trimmed:match("^[%w_]+:%s*$") then
        -- another top-level section starts
        in_dependencies = false
        in_dev_dependencies = false
        -- fall through
      end
    end

    -- parse dependencies only for indented lines under current section
    if (in_dependencies or in_dev_dependencies) and raw:match("^%s+") then
      local dep_name = trimmed:match("^([%w_%-]+):")
      if dep_name then
        local tbl = in_dependencies and dependencies or dev_dependencies
        tbl[dep_name] = true
      end
    end

    ::continue::
  end

  return { dependencies = dependencies, dev_dependencies = dev_dependencies }
end

-- Check for specific packages
local function has_package(pubspec_data, package_name)
  if not pubspec_data then return false end
  return pubspec_data.dependencies[package_name] or pubspec_data.dev_dependencies[package_name] or false
end

-- Determine which approach to use for bloc generation
local function determine_bloc_approach(project_root)
  local pubspec_data = read_pubspec_yaml(project_root)
  if not pubspec_data then
    return "basic" -- No pubspec.yaml found, use basic approach
  end
  
  if has_package(pubspec_data, "freezed") then
    return "freezed"
  elseif has_package(pubspec_data, "equatable") then
    return "equatable"
  else
    return "basic"
  end
end

local function lib_dir_for(dir)
  local root = detect_package_root(dir)
  if not root then return nil end
  local lib = path_join(root, "lib")
  if not exists(lib) then mkdirp(lib) end
  return lib
end

local function resolve_feature_dir(target_dir, feature_name)
  -- Директория фичи всегда в snake_case
  local feature_snake = to_snake_case(feature_name)
  local tail = vim.fn.fnamemodify(target_dir, ":t")
  if to_snake_case(tail) == feature_snake then
    return target_dir, nil
  end
  return path_join(target_dir, feature_snake), nil
end

-- minimal templates
local templates = require('me.templates.bloc')

local function create_bloc_files_at(feature_dir, feature_name, class_name, approach)
  local name_snake = to_snake_case(feature_name)
  local dir = feature_dir
  mkdirp(dir)
  local main_path = path_join(dir, name_snake .. "_bloc.dart")
  local event_path = path_join(dir, name_snake .. "_event.dart")
  local state_path = path_join(dir, name_snake .. "_state.dart")
  
  -- Choose template based on approach
  local main_template, event_template, state_template
  if approach == "freezed" then
    main_template = templates.bloc_main_freezed
    event_template = templates.bloc_event_freezed
    state_template = templates.bloc_state_freezed
  elseif approach == "equatable" then
    main_template = templates.bloc_main_equatable
    event_template = templates.bloc_event_equatable
    state_template = templates.bloc_state_equatable
  else -- basic
    main_template = templates.bloc_main
    event_template = templates.bloc_event
    state_template = templates.bloc_state
  end
  
  write_file(main_path, main_template(feature_name, class_name))
  write_file(event_path, event_template(class_name, feature_name))
  write_file(state_path, state_template(class_name, feature_name))
  return main_path
end

local function create_cubit_files_at(feature_dir, feature_name, class_name, approach)
  local name_snake = to_snake_case(feature_name)
  local dir = feature_dir
  mkdirp(dir)
  local main_path = path_join(dir, name_snake .. "_cubit.dart")
  local state_path = path_join(dir, name_snake .. "_state.dart")
  
  -- Choose template based on approach
  local main_template, state_template
  if approach == "freezed" then
    main_template = templates.cubit_main_freezed
    state_template = templates.cubit_state_freezed
  elseif approach == "equatable" then
    main_template = templates.cubit_main_equatable
    state_template = templates.cubit_state_equatable
  else -- basic
    main_template = templates.cubit_main
    state_template = templates.cubit_state
  end
  
  write_file(main_path, main_template(class_name))
  write_file(state_path, state_template(class_name))
  return main_path
end

local function prompt_name(default_name, on_done)
  vim.ui.input({ prompt = "Имя фичи/блока:", default = default_name }, function(input)
    if not input or input == "" then
      vim.notify("Отменено: пустое имя", vim.log.levels.WARN)
      return
    end
    on_done(input)
  end)
end

local function open_file_if_needed(path)
  local opts = merge_tables(session_defaults, user_opts.defaults or {})
  if opts.open_main_file then
    vim.cmd("edit " .. path)
  end
  -- Закрыть все окна Oil во всех вкладках и полностью удалить их буферы
  local oil_bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf] and vim.bo[buf].filetype == 'oil' then
      table.insert(oil_bufs, buf)
    end
  end
  -- Закрываем окна с этими буферами во всех табах
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local b = vim.api.nvim_win_get_buf(win)
      for _, ob in ipairs(oil_bufs) do
        if b == ob then
          pcall(vim.api.nvim_win_close, win, true)
        end
      end
    end
  end
  -- Удаляем сами буферы Oil, чтобы точно не кэшировались
  for _, ob in ipairs(oil_bufs) do
    if vim.api.nvim_buf_is_loaded(ob) then
      pcall(vim.api.nvim_buf_delete, ob, { force = true })
    end
  end
  -- Обновить Oil, если модуль загружен (на случай последующих открытий)
  local ok, oil = pcall(require, 'oil')
  if ok then pcall(oil.refresh) end
end

function M.create_bloc_at(target_dir)
  local default_name = vim.fn.fnamemodify(target_dir, ":t")
  prompt_name(default_name, function(input_name)
    local feature_dir, err = resolve_feature_dir(target_dir, input_name)
    if not feature_dir then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end
    
    -- Determine approach based on pubspec.yaml
    local project_root = detect_package_root(target_dir)
    local approach = determine_bloc_approach(project_root)
    
    local class_name = to_pascal_case(input_name)
    local main_path = create_bloc_files_at(feature_dir, input_name, class_name, approach)
    
    local approach_text = approach == "freezed" and " (Freezed)" or 
                         approach == "equatable" and " (Equatable)" or 
                         " (Basic)"
    vim.notify("BLoC сгенерирован в: " .. feature_dir .. approach_text, vim.log.levels.INFO)
    open_file_if_needed(main_path)
  end)
end

function M.create_cubit_at(target_dir)
  local default_name = vim.fn.fnamemodify(target_dir, ":t")
  prompt_name(default_name, function(input_name)
    local feature_dir, err = resolve_feature_dir(target_dir, input_name)
    if not feature_dir then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end
    
    -- Determine approach based on pubspec.yaml
    local project_root = detect_package_root(target_dir)
    local approach = determine_bloc_approach(project_root)
    
    local class_name = to_pascal_case(input_name)
    local main_path = create_cubit_files_at(feature_dir, input_name, class_name, approach)
    
    local approach_text = approach == "freezed" and " (Freezed)" or 
                         approach == "equatable" and " (Equatable)" or 
                         " (Basic)"
    vim.notify("Cubit сгенерирован в: " .. feature_dir .. approach_text, vim.log.levels.INFO)
    open_file_if_needed(main_path)
  end)
end

function M.create_feature_at(target_dir)
  -- По умолчанию создаём BLoC-фичу (bloc + event + state)
  return M.create_bloc_at(target_dir)
end

-- Dry run: возвращает таблицу операций без записи на диск и опционально показывает нотификацию
function M.dry_run_bloc_at(target_dir, name)
  local feature_name = name and name ~= '' and name or vim.fn.fnamemodify(target_dir, ":t")
  local feature_snake = to_snake_case(feature_name)
  local base
  do
    local tail = vim.fn.fnamemodify(target_dir, ":t")
    if to_snake_case(tail) == feature_snake then
      base = target_dir
    else
      base = path_join(target_dir, feature_snake)
    end
  end
  local bloc_dir = base
  local files = {
    path_join(bloc_dir, feature_snake .. "_bloc.dart"),
    path_join(bloc_dir, feature_snake .. "_event.dart"),
    path_join(bloc_dir, feature_snake .. "_state.dart"),
  }
  return { ok = true, base = base, files = files }
end

return M


