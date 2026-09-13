# Локальные патчи плагинов

Правки исходников плагинов, которые нужны, но не приняты в upstream.
Живут они в `~/.local/share/nvim/site/pack/core/opt/<плагин>/`, то есть
**затираются при каждом обновлении плагина**. Отсюда — копия в репозитории.

## Как применить

```sh
P=~/.local/share/nvim/site/pack/core/opt
git -C $P/flutter-tools.nvim apply ~/.config/nvim/patches/flutter-tools-document-color-guard.patch
git -C $P/friendly-snippets  apply ~/.config/nvim/patches/friendly-snippets-make-escaping.patch
git -C $P/goplements.nvim   apply ~/.config/nvim/patches/goplements-treesitter-has-parser.patch
```

Проверить, применён ли патч: `git -C $P/<плагин> status --porcelain` — должна
быть строка ` M` на пропатченном файле.

## Что за патчи

- **flutter-tools-document-color-guard** — некоторые версии dartls объявляют
  capability `colorProvider`, но не реализуют обработчик `textDocument/documentColor`.
  Патч проверяет наличие обработчика и оборачивает запрос в `pcall`, иначе сыпятся
  ошибки.
- **friendly-snippets-make-escaping** — в `snippets/make.json` одиночные `$`
  разбираются движком сниппетов как табстопы, из-за чего сниппеты `help` и `print`
  вставляются поломанными. Патч экранирует их до `$$`.
- **goplements-treesitter-has-parser** — `nvim-treesitter` (ветка main) выкинул
  `has_parser`: `parsers.lua` теперь просто таблица конфигов парсеров. Апстрим
  goplements.nvim мёртв с 2025-09, и `:checkhealth` падал с
  «attempt to call field 'has_parser' (a nil value)». Патч спрашивает ядро —
  `vim.treesitter.language.add(lang)`. Добавлен 2026-09-08.

Первые два были сделаны ещё во времена lazy.nvim и потерялись при переезде на `vim.pack`
(в новых копиях плагинов их не оказалось). Восстановлены 2026-07-31.

Родственная правка живёт отдельно — локальные изменения в claudecode.nvim
помечены в коде маркером `[enot patch]`.
