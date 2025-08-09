return {
  {
    "folke/snacks.nvim",
    opts = {
      indent = {
        enabled = true, -- Включить направляющие отступов
        char = "│", -- Символ для направляющих отступов
        only_scope = false, -- Показывать все отступы, а не только область видимости
        only_current = false, -- Показывать отступы во всех окнах
        hl = "SnacksIndent", -- Группа подсветки для направляющих отступов
        animate = {
          enabled = vim.fn.has("nvim-0.10") == 1, -- Включить анимацию для Neovim >= 0.10
          style = "out", -- Анимация от курсора наружу
          easing = "linear", -- Линейная анимация
          duration = {
            step = 20, -- Время на шаг анимации (мс)
            total = 500, -- Общая длительность анимации (мс)
          },
        },
        scope = {
          enabled = true, -- Включить подсветку текущей области видимости
          priority = 200, -- Приоритет области видимости
          char = "│", -- Символ для области видимости
          underline = false, -- Без подчеркивания начала области
          only_current = false, -- Показывать область во всех окнах
          hl = "SnacksIndentScope", -- Группа подсветки для области
        },
        chunk = {
          enabled = false,          -- Отключить отображение областей как кусков
          only_current = false,     -- Показывать куски во всех окнах
          priority = 200,           -- Приоритет кусков
          hl = "SnacksIndentChunk", -- Группа подсветки для кусков
          char = {
            corner_top = "┌",
            corner_bottom = "└",
            horizontal = "─",
            vertical = "│",
            arrow = ">",
          },
        },
        filter = function(buf)
          return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
        end,
      },
      statuscolumn = {
        enabled = true,            -- Включить кастомную строку состояния
        left = { "mark", "sign" }, -- Приоритет компонентов слева (высокий к низкому)
        right = { "fold", "git" }, -- Приоритет компонентов справа (высокий к низкому)
        folds = {
          open = false,            -- Не показывать иконки открытых складок
          git_hl = false,          -- Не использовать подсветку Git Signs для иконок складок
        },
        git = {
          patterns = { "GitSign", "MiniDiffSign" }, -- Шаблоны для Git-знаков
        },
        refresh = 50,                               -- Обновление каждые 50 мс
      },
      words = {
        enabled = true,            -- Включить функцию words
        debounce = 200,            -- Задержка перед обновлением (мс)
        notify_jump = false,       -- Не показывать уведомления при прыжке
        notify_end = true,         -- Показывать уведомление при достижении конца списка ссылок
        foldopen = true,           -- Открывать складки при прыжке
        jumplist = true,           -- Добавлять точку прыжка в jumplist
        modes = { "n", "i", "c" }, -- Режимы, в которых показывать ссылки
        filter = function(buf)
          return vim.g.snacks_words ~= false and vim.b[buf].snacks_words ~= false
        end,
      },
    },
  },
}
