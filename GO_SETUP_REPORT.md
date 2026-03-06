# Поддержка Go в Neovim (dotfiles/nvim)

## Установка Go

- Убедиться, что Go установлен:
  - `go version`
  - `go env GOPATH GOROOT GOMODCACHE`
- Если Go не установлен (Arch Linux):
  - `sudo pacman -S --needed go`

## Установленные / настраиваемые инструменты для Go

Через `mason.nvim` и `mason-tool-installer` автоматически подтягиваются:

- `gopls` — LSP‑сервер для Go.
- `gofumpt` — строгий форматтер кода.
- `goimports` — форматтер + автоматическое управление импортами.
- `golangci-lint` — агрегирующий линтер.
- `delve` (`dlv`) — отладчик Go, используется адаптерами DAP.

## Добавленные плагины

- LSP / инструменты:
  - `WhoIsSethDaniel/mason-tool-installer.nvim` — автоустановка CLI‑инструментов (goimports, gofumpt, golangci-lint, delve и др.).
  - `neovim/nvim-lspconfig` + `williamboman/mason.nvim` + `williamboman/mason-lspconfig.nvim`
    - Добавлен сервер `gopls` в таблицу `servers` (файл `lua/plugins/lsp/lsp.lua`).
- Форматирование:
  - `stevearc/conform.nvim`
    - Для `ft=go` настроен пайплайн: `gofumpt` → `goimports` → `gofmt`.
- Линтеры:
  - `mfussenegger/nvim-lint`
    - Для `ft=go` используется `golangci_lint`.
- Отладка:
  - `mfussenegger/nvim-dap` + `rcarriga/nvim-dap-ui` + `theHamsta/nvim-dap-virtual-text`
  - `jay-babu/mason-nvim-dap.nvim` — автоматическая установка адаптеров DAP (`delve` добавлен в ensure_installed).
  - `leoluz/nvim-dap-go` — go‑специфичная интеграция с DAP.
- Тесты:
  - `nvim-neotest/neotest`
  - `nvim-neotest/neotest-go` — адаптер для Go‑тестов.
- Сниппеты:
  - `L3MON4D3/LuaSnip`
  - `rafamadriz/friendly-snippets` — готовые VSCode‑сниппеты (включая Go).
- Go‑утилиты:
  - `olexsmir/gopher.nvim` — генерация тегов, `if err`, тестов, реализаций интерфейсов и т.п.

## Что работает для файлов Go

### LSP (gopls)

Активируется автоматически для файлов `*.go`, если установлен `gopls`.

Ключевые шорткаты (из `lua/plugins/lsp/lsp.lua`, общие для всех LSP‑языков, включая Go):

- **Переходы**:
  - `gd` — перейти к определению (definition).
  - `gr` — найти все вхождения (references).
  - `gI` — перейти к реализации (implementation).
  - `gD` — перейти к объявлению (declaration).
- **Тип/документация**:
  - `<leader>D` — перейти к определению типа.
  - `K` — показать документацию (hover).
- **Рефакторинг**:
  - `<leader>rn` — переименовать символ (rename).
  - `<leader>ca` — вызвать code actions (например, quick‑fix, organize imports и т.п.).
- **Диагностика**:
  - `gl` — всплывающее окно с ошибками/варнингами для текущей строки.
  - `[d` / `]d` — перейти к предыдущей/следующей диагностике.
  - `<leader>q` — отправить диагностики в quickfix‑список.

### Форматирование (conform.nvim)

- **Автоформат при сохранении**:
  - Для всех LSP‑буферов, в т.ч. Go, сохранение по `<C-s>`:
    - вызывает `conform.format(...)` с `lsp_fallback = true`;
    - затем выполняет `:w`.
- **Явный формат (без сохранения)**:
  - `<leader>mp` в normal/visual:
    - запускает `conform.format()` на текущем файле/выделении.
- Для файлов Go:
  - сначала пытается `gofumpt`;
  - затем `goimports`;
  - в конце — `gofmt` (если предыдущие недоступны).

### Линтинг (golangci-lint через nvim-lint)

- Линтеры запускаются:
  - при `BufWritePost` (после сохранения файла);
  - при `BufEnter` (при входе в буфер).
- Для Go используется `golangci_lint`.
- Диагностики отображаются тем же механизмом, что и LSP (используйте `gl`, `[d`, `]d` и т.п.).

### Отладка Go (nvim-dap + nvim-dap-go)

Общие шорткаты DAP (работают и для Go), определены в `lua/plugins/lsp/dap.lua`:

- Управление:
  - `<F5>` — продолжить/старт отладки.
  - `<F1>` — step into.
  - `<F2>` — step over.
  - `<F3>` — step out.
- Breakpoints:
  - `<leader>db` — toggle breakpoint.
  - `<leader>dB` — conditional breakpoint.
  - `<leader>dC` — очистить все breakpoints.
- Прочее:
  - `<leader>dc` — continue.
  - `<leader>di` / `<leader>do` / `<leader>dO` — шаги (into/over/out).
  - `<leader>dr` — открыть/закрыть REPL.
  - `<leader>dl` — запустить последний DAP‑запуск.
  - `<leader>du` — показать/скрыть DAP UI.
  - `<leader>dx` — завершить сессию.

Go‑специфические команды (`nvim-dap-go`):

- `<leader>dgt` — запустить отладку ближайшего Go‑теста.
- `<leader>dgl` — повторно отладить последний Go‑тест.

### Тестирование Go (neotest + neotest-go)

Ключевые шорткаты для Go (см. `lua/plugins/neotest.lua`):

- Запуск:
  - `<leader>gtr` — запустить ближайший тест (под курсором).
  - `<leader>gtf` — запустить все тесты в текущем файле.
  - `<leader>gta` — запустить все тесты в проекте (`vim.loop.cwd()`).
- Отладка:
  - `<leader>gtd` — запустить ближайший тест в режиме отладки (через DAP).
- Повтор/остановка:
  - `<leader>gtl` — повторить последний запуск тестов.
  - `<leader>gtx` — остановить текущий прогон тестов.
- Вывод/summary:
  - `<leader>gts` — открыть/закрыть панель summary (дерево тестов).
  - `<leader>gto` — открыть панель вывода последнего запуска.
  - `<leader>gtp` — переключить панель полного вывода.

### Сниппеты для Go (LuaSnip + friendly-snippets)

Конфигурация в `lua/plugins/lsp/snippets.lua`:

- Загружаются:
  - стандартные VSCode‑сниппеты из `friendly-snippets` (включая набор для Go);
  - пользовательские сниппеты из `stdpath("config") .. "/snippets"` (обычно `~/.config/nvim/snippets`).
- Работа со сниппетами (через `blink.cmp` + LuaSnip):
  - `Ctrl-Space` — открыть completion‑меню (в т.ч. сниппеты).
  - `<Tab>` / `<S-Tab>` — переход по элементам completion и плейсхолдерам в активном сниппете.
  - `<CR>` — принять выбранный элемент (в т.ч. развернуть сниппет).

Примеры типичных Go‑сниппетов (имена могут отличаться, так как берутся из `friendly-snippets`):

- `func` — генерация шаблона функции.
- `iferr` или аналог — шаблон `if err != nil { ... }`.
- `forr` — цикл по слайсу/map.

### Go‑утилиты (gopher.nvim)

Шорткаты (см. `lua/plugins/go.lua`):

- Теги структур:
  - `<leader>goj` — `GoTagAdd json` (добавить `json`‑теги к полям структуры).
  - `<leader>gox` — `GoTagAdd xml` (добавить `xml`‑теги).
- Обработка ошибок:
  - `<leader>goe` — `GoIfErr` — обернуть текущий вызов в `if err != nil { ... }`.
- Реализация интерфейсов:
  - `<leader>goi` — `GoImpl` — сгенерировать методы реализации интерфейса.
- Генерация тестов:
  - `<leader>got` — `GoTestsAll` — сгенерировать тесты для текущего файла.

Эти команды работают в Go‑файлах и используют установленные через `go install` бинарники (`gomodifytags`, `gotests`, `impl` и т.п.), если вы их добавите в `$PATH`. Плагин сам дергает соответствующие команды.

## Итог: как пользоваться Go в этом конфиге

1. Открыть любой `*.go` файл в Neovim.
2. Убедиться, что `:Mason` показывает установленные `gopls`, `gofumpt`, `goimports`, `golangci-lint`, `delve` (при необходимости доустановить).
3. Писать код с автодополнением (`Ctrl-Space`, `<Tab>`, `<CR>`), подсветкой ошибок и переходами по коду (LSP‑шорткаты).
4. Форматировать код:
   - по сохранению (`<C-s>`) или вручную (`<leader>mp`).
5. Проверять линтинг:
   - сохранять файл и смотреть диагностики (`gl`, `[d`, `]d`).
6. Запускать тесты:
   - `<leader>gtr` / `<leader>gtf` / `<leader>gta` и другие Go‑шорткаты из блока neotest.
7. Отлаживать:
   - `<leader>dgt` / `<leader>dgl` для Go‑тестов;
   - общие DAP‑шорткаты (`<F5>`, `<leader>db`, `<leader>du` и др.) для обычных бинарей.
8. Пользоваться сниппетами и Go‑утилитами:
   - разворачивать VSCode‑сниппеты через completion;
   - использовать команды из `gopher.nvim` (`<leader>goj`, `<leader>goe`, `<leader>goi`, `<leader>got` и др.) для ускорения типичных Go‑паттернов.

