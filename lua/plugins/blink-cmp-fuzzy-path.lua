return {
  "newtoallofthis123/blink-cmp-fuzzy-path",
  dependencies = { "saghen/blink.cmp" },
  opts = {
    filetypes = { "markdown", "json" },
    trigger_char = "@",
    max_results = 5,
  },
  specs = {
    "Saghen/blink.cmp",
    opts = function(_, opts)
      table.insert(opts.sources.default, "fuzzy-path")
      return require("astrocore").extend_tbl(opts, {
        sources = {
          providers = {
            ["fuzzy-path"] = {
              name = "Fuzzy Path",
              module = "blink-cmp-fuzzy-path",
              score_offset = 0,
            },
          },
        },
      })
    end,
  },
}
