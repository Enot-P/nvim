return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lua",
		"onsails/lspkind.nvim",
		{
			"L3MON4D3/LuaSnip",
			build = "make install_jsregexp",
			config = function()
				-- Загружаем только свои сниппеты
				require("luasnip.loaders.from_lua").lazy_load({
					paths = { "~/.config/nvim/lua/snippets/" },
				})
			end,
			dependencies = {
				"saadparwaiz1/cmp_luasnip",
			},
		},
	},
	config = function()
		-- Внутри config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		local cmp_mappings = cmp.mapping.preset.insert({
			["<C-u>"] = cmp.mapping.scroll_docs(-4),
			["<C-d>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = false }),

			-- Переход по параметрам и выбор автодополнения с помощью Tab
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item() -- Выбираем следующий элемент в меню автодополнения
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump() -- Расширяем или переходим к следующему параметру в сниппете
				else
					fallback() -- Если нет меню или сниппета, используем стандартное поведение Tab
				end
			end, { "i", "s" }),

			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item() -- Выбираем предыдущий элемент в меню автодополнения
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1) -- Переходим к предыдущему параметру в сниппете
				else
					fallback() -- Если нет меню или сниппета, используем стандартное поведение Shift-Tab
				end
			end, { "i", "s" }),

			["<C-f>"] = cmp.mapping(function(fallback)
				if cmp.visible_docs() then
					cmp.close_docs()
				else
					cmp.open_docs()
				end
			end, { "i" }),
		})
		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "luasnip", priority = 900 },
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
					luasnip = 1,
				},
				format = require("lspkind").cmp_format({
					mode = "symbol_text",
					maxwidth = 50,
					before = function(entry, vim_item)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snip]",
							buffer = "[Buffer]",
							path = "[Path]",
							nvim_lua = "[Lua]",
						})[entry.source.name]
						return vim_item
					end,
				}),
			},
		})
	end,
}
