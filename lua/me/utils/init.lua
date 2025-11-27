-- /lua/me/utils/init.lua

local M = {}

-- Загружаем каждую утилиту как подмодуль
M.dart_data_class = require("me.utils.dart_data_class_generate")
M.dart_export = require("me.utils.dart_export_file_generate")
M.lsp_keymaps = require("me.utils.lsp_dart_keymaps")
M.flutter_tree = require("me.utils.flutter_tree")

-- Для обратной совместимости с вашими текущими конфигами,
-- которые используют require('me.utils').on_attach
M.on_attach = M.lsp_keymaps.on_attach
M.on_attach_flutter = M.lsp_keymaps.on_attach_flutter

-- Для обратной совместимости с generate_exports
M.generate_exports = M.dart_export.generate_exports

return M
