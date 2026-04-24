return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gosum" },
  root_markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        -- Анализаторы
        analyses = {
          unusedparams = true,   -- неиспользуемые параметры
          shadow = true,         -- затенение переменных
          nilness = true,        -- анализ nil-значений
          unusedwrite = true,    -- запись в переменную, которая больше не читается
          useany = true,         -- подсказывает заменить interface{} на any
        },

        -- Линтер
        staticcheck = true,

        -- Форматирование
        gofumpt = true,

        -- Автодополнение
        usePlaceholders = true,
        completeUnimported = true,
        matcher = "Fuzzy",          -- нечёткий поиск при автодополнении

        -- Подсказки (inlay hints)
        hints = {
          parameterNames = true,        -- имена параметров при вызове функции
          assignVariableTypes = true,   -- типы переменных при := 
          constantValues = true,        -- значения констант
          compositeLiteralFields = true, -- имена полей в структурах
        },

        -- Code lens (кнопки над функциями)
        codelenses = {
          generate = true,      -- go generate
          test = true,          -- запуск тестов
          tidy = true,          -- go mod tidy
          gc_details = true,    -- детали компилятора (escape analysis)
        },

        -- Проверка уязвимостей
        vulncheck = "Imports",  -- или "Off"
      },
    }
}
