vim.pack.add({
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
})

require("lualine").setup({
    options = {
        -- У Atlas свой статуслайн: через него идут подсказки клавиш, прогресс
        -- загрузки и уведомления. Без этой строки lualine его перекрывает и
        -- ревью остаётся без обратной связи (README atlas.nvim).
        disabled_filetypes = { statusline = { "atlas" } },
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
    },
    sections = {
        lualine_a = {
            {
                "mode",
                fmt = function(str)
                    local recording = vim.fn.reg_recording()
                    if recording ~= "" then
                        return "RECORDING @" .. recording
                    end
                    return str
                end,
            },
        },
    },
})
