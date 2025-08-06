return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup({
      options = {
        numbers = "none", -- "none" | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
        close_command = function(bufnum) vim.cmd("bdelete! " .. bufnum) end,
        right_mouse_command = function(bufnum) vim.cmd("bdelete! " .. bufnum) end,
        left_mouse_command = "buffer %d",    -- can be a string or a function, see "Mouse actions"
        middle_mouse_command = nil,          -- can be a string or a function, see "Mouse actions"
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        --- @deprecated, use close_command instead
        -- diagnostics = "nvim_lsp",
        -- diagnostics_update_in_insert = false,
        -- diagnostics_indicator = function(count, level, diagnostics_dict)
        --   return "(" .. count .. ")"
        -- end,
        -- offsets = {
        --     {
        --         filetype = "NvimTree",
        --         text = "File Explorer",
        --         text_align = "left",
        --         separator = true
        --     }
        -- },
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        -- can also be a table containing a list of bufferline color option types and a list of statusline color option types
        -- separator_style = "slant", -- "slant" | "padded_slant" | "thick" | "thin" | { ' ', ' ' }
        enforce_regular_tabs = true,
        always_show_bufferline = true,
        sort_by = 'insert_after_current',
      }
    })
  end
}
