vim.pack.add({
	{ src = "https://github.com/jake-stewart/multicursor.nvim", branch = "1.0" },
})

local mc = require("multicursor-nvim")
mc.setup()

local set = vim.keymap.set

set({ "n", "x" }, "<up>", function()
	mc.lineAddCursor(-1)
end)
set({ "n", "x" }, "<down>", function()
	mc.lineAddCursor(1)
end)
set({ "n", "x" }, "<leader><up>", function()
	mc.lineSkipCursor(-1)
end)
set({ "n", "x" }, "<leader><down>", function()
	mc.lineSkipCursor(1)
end)

-- <leader>n занят snacks (notification history): префикс m
set({ "n", "x" }, "<leader>mn", function()
	mc.matchAddCursor(1)
end, { desc = "Multicursor: match add next" })
set({ "n", "x" }, "<leader>ms", function()
	mc.matchSkipCursor(1)
end, { desc = "Multicursor: match skip next" })
set({ "n", "x" }, "<leader>mN", function()
	mc.matchAddCursor(-1)
end, { desc = "Multicursor: match add prev" })
set({ "n", "x" }, "<leader>mS", function()
	mc.matchSkipCursor(-1)
end, { desc = "Multicursor: match skip prev" })

set("n", "<c-leftmouse>", mc.handleMouse)
set("n", "<c-leftdrag>", mc.handleMouseDrag)
set("n", "<c-leftrelease>", mc.handleMouseRelease)

set({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "Multicursor: toggle" })

mc.addKeymapLayer(function(layerSet)
	layerSet({ "n", "x" }, "<left>", mc.prevCursor)
	layerSet({ "n", "x" }, "<right>", mc.nextCursor)
	layerSet({ "n", "x" }, "<leader>mx", mc.deleteCursor, { desc = "Multicursor: delete cursor" })
	-- как глобальный <C-c> (:nohl), но при мультикурсоре — сбросить до одного основного
	layerSet({ "n", "x", "i" }, "<c-c>", function()
		mc.clearCursors()
		vim.cmd.nohl()
	end, { desc = "Multicursor: один курсор, снять hl поиска" })
	layerSet("n", "<esc>", function()
		if not mc.cursorsEnabled() then
			mc.enableCursors()
		else
			mc.clearCursors()
		end
	end)
end)

local hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor", { reverse = true })
hl(0, "MultiCursorVisual", { link = "Visual" })
hl(0, "MultiCursorSign", { link = "SignColumn" })
hl(0, "MultiCursorMatchPreview", { link = "Search" })
hl(0, "MultiCursorDisabledCursor", { reverse = true })
hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
