return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            theme = 'tokyonight',
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { 'filename' },
                lualine_x = {
                    { function()
                        local f = io.open(vim.fn.getcwd() .. "/.fvm/version", "r")
                        if not f then return "" end
                        local v = f:read("*l")
                        f:close()
                        return v and ("  " .. v) or ""
                    end },
                    'encoding', 'fileformat', 'filetype'
                },
                lualine_y = { 'progress' },
                lualine_z = { 'location' },
            },
        }
    }
}
