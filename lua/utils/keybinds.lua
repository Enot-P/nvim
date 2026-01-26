-- -- Горячие клавиши для утилит
vim.keymap.set("n", "<leader>dgc", function()
    require("utils.dart_class_gen").generate_data_class_methods()
end, { desc = "Генерировать Dart класс" })
