return {
	"hrsh7th/nvim-cmp",
	config = function()
		local cmp = require("cmp")
		local cmp_mappings = cmp.mapping.preset.insert({
			["<C-u>"] = cmp.mapping.scroll_docs(-4),
			["<C-d>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = false }),
			["<C-f>"] = cmp.mapping(function(fallback)
				if cmp.visible_docs() then
					cmp.close_docs()
				else
					cmp.open_docs()
				end
			end, { "i" }),
		})

		---@diagnostic disable-next-line: missing-fields
		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- Необходимо для работы сниппетов
				end,
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "buffer", priority = 800, keyword_length = 3 },
				{ name = "path", priority = 700 },
			}),
			mapping = cmp_mappings,
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			sorting = {
				comparators = {
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					cmp.config.compare.locality,
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},
			experimental = {
				ghost_text = true,
			},
			formatting = {
				duplicates = {
					buffer = 1,
					path = 1,
					nvim_lsp = 0,
				},
				format = require("lspkind").cmp_format({
					mode = "symbol_text",
					maxwidth = 50,
					before = function(entry, vim_item)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							buffer = "[Buffer]",
							path = "[Path]",
							nvim_lua = "[Lua]",
						})[entry.source.name]
						return vim_item
					end,
				}),
			},
		})

		-- Очистка и загрузка только ваших сниппетов
		require("luasnip").cleanup()
		require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/lua/snippets/" } })
	end,
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lua",
		"onsails/lspkind.nvim",
		{
			"L3MON4D3/LuaSnip", -- Возвращаем LuaSnip
			dependencies = {
				"saadparwaiz1/cmp_luasnip", -- Необходимо для интеграции с cmp
			},
		},
	},
}
