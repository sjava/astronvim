-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.colorscheme.catppuccin" },

  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.zig" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.vue" },
  { import = "astrocommunity.pack.elixir-phoenix" },

  { import = "astrocommunity.pack.python.base" },
  { import = "astrocommunity.pack.python.pyrefly" },
  { import = "astrocommunity.pack.python.ruff" },

  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.utility.noice-nvim" },
  { import = "astrocommunity.motion.mini-bracketed" },

  { import = "astrocommunity.motion.flash-nvim" },

  { import = "astrocommunity.icon.mini-icons" },
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.motion.vim-matchup" },
  { import = "astrocommunity.motion.nvim-tree-pairs" },
  { import = "astrocommunity.motion.mini-ai" },
  {
    "echasnovski/mini.ai",
    opts = { custom_textobjects = { t = false }, n_lines = 500 },
  },

  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },
  { import = "astrocommunity.editing-support.suda-vim" },
  { import = "astrocommunity.editing-support.treesj" },
  { import = "astrocommunity.editing-support.text-case-nvim" },

  { import = "astrocommunity.test.neotest" },
  { import = "astrocommunity.recipes.astrolsp-no-insert-inlay-hints" },
  { import = "astrocommunity.recipes.picker-lsp-mappings" },
  { import = "astrocommunity.neovim-lua-development.helpview-nvim" },

  { import = "astrocommunity.completion.blink-cmp" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },

  { import = "astrocommunity.search.grug-far-nvim" },
  { import = "astrocommunity.bars-and-lines.dropbar-nvim" },
  { import = "astrocommunity.fuzzy-finder.snacks-picker" },

  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      anti_conceal = {
        enabled = false,
      },
    },
  },

  { import = "astrocommunity.media.image-nvim" },
  { import = "astrocommunity.note-taking.zk-nvim" },

  { import = "astrocommunity.ai.opencode-nvim" },
}
