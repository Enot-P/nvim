vim.pack.add({
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
})

-- Библиотечные сниппеты (friendly-snippets) с runtimepath. Раньше их читал сам
-- blink, но он раскрывает через LuaSnip (snippets.preset), а тот знает только о
-- том, что загрузили ему -- без этой строки из меню пропал бы, например, `func`.
require("luasnip.loaders.from_vscode").lazy_load()

-- Свои сниппеты
require("luasnip.loaders.from_vscode").lazy_load({
	paths = { vim.fn.stdpath("config") .. "/snippets" },
})
