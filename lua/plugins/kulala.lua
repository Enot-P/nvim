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
		-- Без summary JSON в output-буфере парсится чище (InspectTree без массы ERROR до body).
		show_request_summary = false,
		-- icons = {
		-- 	-- Более нейтральные группы для summary-строки в окне ответа.
		-- 	textHighlight = "Comment",
		-- 	loadingHighlight = "Comment",
		-- 	doneHighlight = "DiagnosticOk",
		-- 	errorHighlight = "DiagnosticError",
		-- },
		-- Явно задаем цвета, чтобы группы Kulala не сливались в один оттенок.
		syntax_hl = {
			["@function.method.kulala_http"] = { fg = "#e5c07b", bold = true },
			["@string.special.url.kulala_http"] = { fg = "#61afef", underline = true },
			["@variable.kulala_http"] = { fg = "#98c379" },
			["@character.special.kulala_http"] = { fg = "#c678dd" },
			["@string.special.kulala_http"] = { fg = "#56b6c2" },
			["@constant.kulala_http"] = { fg = "#d19a66" },
			["@number.kulala_http"] = { fg = "#d19a66" },
			["@operator.kulala_http"] = { fg = "#abb2bf" },
			["@punctuation.bracket.kulala_http"] = { fg = "#abb2bf" },
			["@query_param.name.kulala_http"] = { fg = "#e06c75" },
			["@query_param.value.kulala_http"] = { fg = "#98c379" },
			["@form_param_name.kulala_http"] = { fg = "#e06c75" },
			["@form_param_value.kulala_http"] = { fg = "#98c379" },
			["@redirect_path.kulala_http"] = { fg = "#56b6c2", underline = true },
			["@external_body_path.kulala_http"] = { fg = "#56b6c2", italic = true },
			["@comment.kulala_http"] = { fg = "#7f848e", italic = true },
		},
	},
})
