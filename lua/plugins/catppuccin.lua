return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      dim_inactive = { enabled = true },
      term_colors = true,
      integrations = {
        aerial = true,
        cmp = true,
        mason = true,
        notify = true,
        neotree = true,
        telescope = {
          enabled = true,
        },
        which_key = true,
        blink_cmp = true,
        snacks = {
          enabled = true,
        },
        mini = {
          enabled = true,
          indentscope_color = "", -- catppuccin color (eg. `lavender`) Default: text
        },
        noice = true,
        gitsigns = true,
        lsp_trouble = true,
        ts_rainbow2 = true,
        treesitter = true,
        window_picker = true,
        overseer = true,
        grug_far = false,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
      },
    },
  },
}
