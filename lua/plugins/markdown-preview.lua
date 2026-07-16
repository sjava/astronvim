return {
  {
    "selimacerbas/markdown-preview.nvim",
    dependencies = { "selimacerbas/live-server.nvim" },
    config = function()
      require("markdown_preview").setup {
        -- all optional; sane defaults shown
        instance_mode = "multi", -- "takeover" (one tab) or "multi" (tab per instance)
        port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
        host = "10.126.126.10",
        open_browser = false,
        default_theme = "dark", -- "dark" or "light"; initial preview theme
        debounce_ms = 300,
        mermaid_renderer = "js",
        hooks = {
          on_start = function(url) vim.notify("Markdown Preview: " .. url, vim.log.levels.INFO) end,
        },
      }
    end,
  },
}
