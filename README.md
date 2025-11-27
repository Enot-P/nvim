# Обзор плагинов Neovim (актуальный)

- **akinsho/bufferline.nvim** — панель буферов/вкладок.
- **nvim-lualine/lualine.nvim** — статус-строка.
- **nvim-telescope/telescope.nvim** (+ fzy-native, live-grep-args, ui-select) — поиск/пикеры.
- **nvim-treesitter/nvim-treesitter** (+ textobjects, context) — подсветка/AST.
- **neovim/nvim-lspconfig**, **williamboman/mason.nvim**, **williamboman/mason-lspconfig.nvim** — LSP и менеджер серверов.
- **hrsh7th/nvim-cmp** (+ cmp-nvim-lsp, cmp-buffer, cmp-path), **L3MON4D3/LuaSnip**, **saadparwaiz1/cmp_luasnip** — автодополнение и сниппеты.
- **numToStr/Comment.nvim** — комментирование.
- **windwp/nvim-autopairs** — автопары.
- **NvChad/nvim-colorizer.lua** — подсветка цветов.
- **lewis6991/gitsigns.nvim**, **tpope/vim-fugitive**, **kdheepak/lazygit.nvim** — Git-интеграция.
- **folke/which-key.nvim** — подсказки по клавишам.
- **folke/flash.nvim** — быстрые прыжки/навигация.
- **akinsho/flutter-tools.nvim** — инструменты Flutter/Dart.
- **kevinhwang91/nvim-ufo** — сворачивание кода.
- **akinsho/toggleterm.nvim** — встроенные терминалы.
- **stevearc/oil.nvim** — файловый менеджер в буфере.
- **nvim-neo-tree/neo-tree.nvim** — альтернативный файловый браузер (при необходимости).
- **spharma/smear-cursor.nvim** — эффект размытия курсора.
- **jay-babu/mason-null-ls.nvim** или **nvimtools/none-ls.nvim** (см. конфиг `none-ls.lua`) — форматтеры/линтеры через null-ls.
- **Lenslina** (см. `lenslina.lua`) — визуальные улучшения/настройки.
- **snacks.nvim** (см. `snacks.lua`) — набор утилит UI/UX.
- **kylechui/nvim-surround** — работа с окружениями (кавычки/скобки и т.п.).
- **christoomey/vim-tmux-runner** — интеграция с tmux.
- **tema/skin (theme.lua)** — тема оформления и настройки подсветки.
- **todo-comments.nvim** (см. `to-do_comments.lua`) — заметки TODO/FIXME в коде.

## Flutter_Tree (генерация дерева виджетов из аббревиатуры)

Расширение для быстрого создания дерева Flutter-виджетов по краткой записи (DSL), аналог VSCode-расширения «Flutter Tree».

### Команда
- `:FlutterTree` — генерирует код и вставляет его:
  - если есть визуальное выделение — берёт выделенный текст;
  - иначе берёт текущую строку;
  - если пусто — запросит ввод аббревиатуры.

### Хоткеи (в Dart-файлах)
- Нормальный режим: `<leader>ft` — сгенерировать из текущей строки (или запрос ввода).
- Визуальный режим: `<leader>ft` — сгенерировать из выделения.

### Синтаксис DSL
- Один ребёнок: `Parent>Child`
- Несколько детей: `Parent[ChildOne,ChildTwo]`
- Вложенность: `Parent[One,Two>Nested>Leaf]`
- Допустим сахар `Widget()`; параметры внутри `()` пока не поддерживаются.

### Примеры
- Ввод: `SingleChild>Child`

```dart
SingleChild(
    child: Child(),
),
```

- Ввод: `MultipleChild[ChildOne,ChildTwo>NestedChild>Child]`

```dart
MultipleChild(
    children: <Widget>[
        ChildOne(),
        ChildTwo(
            child: NestedChild(
                child: Child(),
            ),
        ),
    ]
),
```

### Сообщения об ошибках
Ошибки парсинга показываются через `vim.notify`. Проверьте корректность скобок `[]`, стрелок `>` и запятых.

## Генерация экспортов Dart (barrel file)

Автоматически создаёт `export`-файл для текущей папки и рекурсивно для подпапок.

### Хоткей
- `<leader>de` — сгенерировать экспортный файл для текущей директории (рекурсивно).

Итоговый файл называется как текущая папка, например для `lib/widgets` будет создан `lib/widgets/widgets.dart` со строками вида:

```dart
export 'button.dart';
export 'card.dart';
export 'inputs/inputs.dart';
```

### Альтернативный вызов
- Команда Lua: `:lua require('me.utils').dart_export.generate_exports()`
- Нерекурсивный вариант: `:lua require('me.utils').dart_export.generate_exports_current_only()`

## Генератор flutter_bloc / cubit

Создаёт заготовки BLoC или Cubit (main/event/state) для вашей фичи с учётом структуры Flutter-пакета.

### Где запускать
Рекомендуется запускать из файлового менеджера Oil:
- Откройте Oil: `-` (минус) в нормальном режиме.
- Перейдите в нужную папку проекта/фичи.

### Хоткей (в Oil)
- `<leader>dgb` — меню выбора генерации в текущей директории Oil: `Bloc` или `Cubit`.
  - Далее будет запрос на имя (фичи/блока). Вводите, например: `auth` или `user_profile`.

### Что создаётся
- Для Bloc: `<feature>/<feature>_bloc.dart`, `<feature>/<feature>_event.dart`, `<feature>/<feature>_state.dart`
- Для Cubit: `<feature>/<feature>_cubit.dart`, `<feature>/<feature>_state.dart`

### Куда сохраняется
- Генерация происходит в ТЕКУЩЕЙ директории Oil.
- Если текущая папка по нормализации совпадает с именем фичи — файлы кладутся прямо сюда; иначе создаётся подпапка с именем фичи в `snake_case`.

### Именование
- Можно вводить имя в любом формате: `snake_case`, `camelCase`, `PascalCase`, с пробелами или дефисами (например: `Auth View`, `auth-view`).
- Директория фичи всегда создаётся в `snake_case`.
- Имена классов генерируются в `PascalCase`.
- Директивы `part`/`part of` формируются из `snake_case` и совпадают с именами файлов.

### Открытие файла и обновление интерфейса
- После генерации основной файл (bloc/cubit) автоматически открывается.
- Маски/буферы Oil корректно закрываются/обновляются.

## Code Actions (Dart): фильтр импортов и расширенное окно

- **Фильтрация импортов**: хоткей `ca` вызывает обёртку над `vim.lsp.buf.code_action`, которая скрывает ТОЛЬКО относительные варианты импорта (`./`, `../`).
  - Варианты `package:...` и `dart:...` остаются и отображаются.
  - Реализация: `lua/me/utils/lsp_dart_keymaps.lua` → функция `filtered_code_actions`.
- **Ширина окна выбора**: увеличена для всех `vim.ui.select` (через `telescope-ui-select`).
  - Глобально: `layout_config = { width = 0.75, height = 0.6 }` в `defaults` Telescope.
  - Для `ui-select`: тема `get_dropdown({ previewer = false, layout_config = { width = 0.8, height = 0.6 } })`.

### Как изменить размеры
- Правьте `layout_config` в `lua/plugins/telescope.lua`.
- Пример: `width = 0.9` сделает окно почти полноэкранным.
