return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- Рекомендуется для отображения иконок
    "MunifTanjim/nui.nvim",
    {
      -- Опционально для поддержки предпросмотра изображений
      "3rd/image.nvim",
      -- Конфигурация для image.nvim, чтобы использовать ImageMagick CLI и избежать ошибок компиляции
      opts = {
        backend = "kitty", -- или "ueberzug", "wezterm", "iterm2" в зависимости от вашего терминала
        integrations = {
          -- Интеграция с NeoTree
          neotree = {
            enabled = true,
            -- Список поддерживаемых расширений файлов
            supported_extensions = { "png", "jpg", "jpeg", "gif", "bmp", "webp" },
          },
        },
        max_width = 100,      -- Максимальная ширина предпросмотра
        max_height = 12,      -- Максимальная высота предпросмотра
        exact_resize = false, -- Изменять размер пропорционально
      },
      -- Ключевая настройка: используем CLI процессор вместо Lua rock
      build = function()
        -- Эта функция запускается при установке плагина.
        -- Мы можем установить необходимые системные зависимости здесь или просто пропустить сборку rock.
        -- Для большинства систем достаточно установить ImageMagick.
        vim.cmd [[
          silent !sudo apt install -y imagemagick > /dev/null 2>&1 || true
        ]]
      end,
    }, },
  config = function()
    require("neo-tree").setup({
      open_on_setup = false,
      -- Источники для отображения в NeoTree
      sources = { "filesystem", "buffers", "git_status" },

      -- Типы файлов, которые не заменяются при открытии
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline", "oil" },

      -- Настройки файловой системы
      filesystem = {
        bind_to_cwd = false,                      -- Не привязываться к текущей рабочей директории
        follow_current_file = { enabled = true }, -- Следить за текущим файлом
        use_libuv_file_watcher = true,            -- Использовать libuv для отслеживания изменений
        hijack_netrw_behavior = "disabled",
      },

      -- Настройки окна
      window = {
        position = "float",     -- Положение окна (можно изменить на "right")
        width = 40,             -- Ширина окна
        mappings = {
          ["l"] = "open",       -- Открыть файл или директорию
          ["h"] = "close_node", -- Закрыть текущий узел
          ["<space>"] = "none", -- Отключить действие для пробела
          --["Y"] = "copy_path_to_clipboard", -- Копировать путь в буфер обмена
          --["O"] = "open_with_system_app", -- Открыть файл в системном приложении
          ["P"] = { "toggle_preview", config = { use_float = false } }, -- Переключить предпросмотр
        },
      },

      -- Конфигурация компонентов по умолчанию
      default_component_configs = {
        indent = {
          with_expanders = true, -- Показывать индикаторы для директорий
          expander_collapsed = "", -- Иконка для свернутых директорий
          expander_expanded = "", -- Иконка для развернутых директорий
          expander_highlight = "NeoTreeExpander", -- Подсветка индикаторов
        },
        git_status = {
          symbols = {
            unstaged = "󰄱", -- Символ для незакоммиченных изменений
            staged = "󰱒", -- Символ для закоммиченных изменений
          },
        },
      },
    })
  end,
}
