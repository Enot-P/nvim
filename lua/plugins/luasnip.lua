vim.pack.add({
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
})

-- Без этого незаконченный сниппет (не дошёл Tab'ом до $0) остаётся активным
-- навсегда: такие копятся, и Tab прыгает к их табстопам через весь файл.
-- Ушёл курсор из области сниппета -- выходим из него; удалил его текст -- забываем.
require("luasnip").setup({
	region_check_events = "CursorMoved,CursorMovedI,InsertEnter",
	delete_check_events = "TextChanged,InsertLeave",
	-- выделить код, <Tab> -- он вырезается и попадает в $TM_SELECTED_TEXT
	-- следующего сниппета (например, gow оборачивает его в wg.Go)
	store_selection_keys = "<Tab>",
})

-- Библиотечные сниппеты (friendly-snippets) с runtimepath. Раньше их читал сам
-- blink, но он раскрывает через LuaSnip (snippets.preset), а тот знает только о
-- том, что загрузили ему -- без этой строки из меню пропал бы, например, `func`.
require("luasnip.loaders.from_vscode").lazy_load()

-- Свои сниппеты
require("luasnip.loaders.from_vscode").lazy_load({
	paths = { vim.fn.stdpath("config") .. "/snippets" },
})
