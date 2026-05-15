vim.pack.add({
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
})

require("lualine").setup({
    options = {
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
