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
		cmp_mappings["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif require("luasnip").expand_or_jumpable() then
				require("luasnip").expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" })
		cmp_mappings["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif require("luasnip").jumpable(-1) then
				require("luasnip").jump(-1)
			else
				fallback()
			end
		end, { "i", "s" })

		---@diagnostic disable-next-line: missing-fields
		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "luasnip", priority = 900 },
			}, {
				{ name = "buffer", priority = 800, keyword_length = 3 },
				{ name = "path", priority = 700 },
			}),
			mapping = cmp_mappings,
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			-- Добавляем дедупликацию
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
			-- Настройки для предотвращения дублирования
			experimental = {
				ghost_text = true,
			},
			formatting = {
				duplicates = {
					buffer = 1,
					path = 1,
					nvim_lsp = 0, -- Не показываем дубли LSP
					luasnip = 1,
				},
				format = require("lspkind").cmp_format({
					mode = "symbol_text",
					maxwidth = 50,
					before = function(entry, vim_item)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
							nvim_lua = "[Lua]",
						})[entry.source.name]
						return vim_item
					end,
				}),
			},
		})

		-- Очистка и загрузка кастомных сниппетов
		require("luasnip").cleanup()
		require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/lua/snippets/" } })
	end,
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lua",
		"onsails/lspkind.nvim",
		{
			"L3MON4D3/LuaSnip",
			dependencies = {
				"saadparwaiz1/cmp_luasnip",
			},
		},
	},
}
