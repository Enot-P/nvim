return {
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      require("dbee").install()
    end,
    config = function()
      local dbee = require("dbee")

      dbee.setup({})

      vim.keymap.set("n", "<leader>da", dbee.toggle, { desc = "Открыть dbee UI" })
    end,
  },
}
