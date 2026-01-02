local M = {}

local function write_file(path, content)
  local file = io.open(path, "w")
  if file then
    file:write(content)
    file:close()
    return true
  end
  return false
end

-- Функция для безопасной замены плейсхолдеров
local function fill_template(template, vars)
  local result = template
  for k, v in pairs(vars) do
    result = result:gsub("{{ " .. k .. " }}", v)
  end
  return result
end

M.generate_flutter_logic = function(picker)
  local item = picker:current()
  if not (item and item.file) then
    return
  end

  local target_dir = vim.fn.isdirectory(item.file) == 1 and item.file or vim.fn.fnamemodify(item.file, ":p:h")

  Snacks.picker.select({ "Bloc", "Cubit" }, { prompt = "Выберите тип" }, function(choice)
    if not choice then
      return
    end

    vim.ui.input({ prompt = "Имя (snake_case): " }, function(input_name)
      if not input_name or input_name == "" then
        return
      end

      local type_dir = choice:lower()
      local final_dir = target_dir .. "/" .. type_dir
      if vim.fn.isdirectory(final_dir) == 0 then
        vim.fn.mkdir(final_dir, "p")
      end

      local class_name = input_name:gsub("_(%l)", string.upper):gsub("^%l", string.upper)
      local file_prefix = final_dir .. "/" .. input_name

      -- Общие переменные для шаблонов
      local vars = {
        name = input_name,
        class = class_name,
      }

      if choice == "Bloc" then
        -- BLOC
        write_file(
          file_prefix .. "_bloc.dart",
          fill_template(
            [[
import 'package:flutter_bloc/flutter_bloc.dart';

part '{{ name }}_event.dart';
part '{{ name }}_state.dart';

class {{ class }}Bloc extends Bloc<{{ class }}Event, {{ class }}State> {
  {{ class }}Bloc() : super(const {{ class }}Initial()) {
    on<{{ class }}Started>((event, emit) {
      // Logic
    });
  }
}
]],
            vars
          )
        )

        -- EVENT
        write_file(
          file_prefix .. "_event.dart",
          fill_template(
            [[
part of '{{ name }}_bloc.dart';

sealed class {{ class }}Event {
  const {{ class }}Event();
}

final class {{ class }}Started extends {{ class }}Event {}
]],
            vars
          )
        )

        -- STATE
        write_file(
          file_prefix .. "_state.dart",
          fill_template(
            [[
part of '{{ name }}_bloc.dart';

sealed class {{ class }}State {
  const {{ class }}State();
}

final class {{ class }}Initial extends {{ class }}State {
  const {{ class }}Initial();
}
]],
            vars
          )
        )
      else
        -- CUBIT
        write_file(
          file_prefix .. "_cubit.dart",
          fill_template(
            [[
import 'package:flutter_bloc/flutter_bloc.dart';

part '{{ name }}_state.dart';

class {{ class }}Cubit extends Cubit<{{ class }}State> {
  {{ class }}Cubit() : super(const {{ class }}Initial());
}
]],
            vars
          )
        )

        -- STATE (Cubit)
        write_file(
          file_prefix .. "_state.dart",
          fill_template(
            [[
part of '{{ name }}_cubit.dart';

sealed class {{ class }}State {
  const {{ class }}State();
}

final class {{ class }}Initial extends {{ class }}State {
  const {{ class }}Initial();
}
]],
            vars
          )
        )
      end

      Snacks.notify.info(choice .. " " .. class_name .. " успешно создан!")
    end)
  end)
end

return M
