return {
  {
    "saxon1964/neovim-tips",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      user_file = vim.fn.stdpath "config" .. "/neovim_tips/user_tips.md",
      daily_tip = 0,
    },
  },
}
