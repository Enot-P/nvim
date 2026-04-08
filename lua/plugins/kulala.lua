vim.pack.add({
	{ src = "https://github.com/mistweaverco/kulala.nvim" },
})

-- Kulala вызывает vim.lsp.start без capabilities — blink.cmp тогда не получает snippet/resolve.
local blink_ok, blink = pcall(require, "blink.cmp")
local lsp_caps = blink_ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()
local orig_lsp_start = vim.lsp.start
function vim.lsp.start(config, opts)
	if type(config) == "table" and config.name == "kulala" then
		config = vim.tbl_extend("force", {}, config)
		config.capabilities = vim.tbl_deep_extend("force", lsp_caps, config.capabilities or {})
	end
	return orig_lsp_start(config, opts)
end

require("kulala").setup({
	global_keymaps = true,
	global_keymaps_prefix = "<leader>R",
	kulala_keymaps_prefix = "",
	ui = {
		-- Контраст: метод / URL / версия не должны сливаться в один «синий» (как у @function + @string.special).
		syntax_hl = {
			["@punctuation.bracket.kulala_http"] = "@punctuation.bracket",
			["@character.special.kulala_http"] = "@character.special",
			["@operator.kulala_http"] = "@operator",
			["@variable.kulala_http"] = "@variable",
			["@function.method.kulala_http"] = "@keyword",
			["@string.special.url.kulala_http"] = "@string",
			["@string.special.kulala_http"] = "@character.special",
			["@constant.kulala_http"] = "@constant",
			["@number.kulala_http"] = "@number",
			["@comment.kulala_http"] = "@comment",
			["@redirect_path.kulala_http"] = "@markup.link",
			["@external_body_path.kulala_http"] = "@string.special",
			["@query_param.name.kulala_http"] = "@keyword",
			["@query_param.value.kulala_http"] = "@string",
			["@form_param_name.kulala_http"] = "@keyword",
			["@form_param_value.kulala_http"] = "@string",
		},
	},
	-- Форматтер Kulala при невалидном методе (например GT вместо GET) может подставить GET, оставив «GT» в URL — см. formatter.lua request().
})
