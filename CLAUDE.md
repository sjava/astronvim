# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal AstroNvim v6+ user configuration. Deployed to `~/.config/nvim`. Uses lazy.nvim as plugin manager.

## Deployment

This repo is deployed to `~/.config/nvim`. The standard install flow: back up existing nvim config → `git clone <this-repo> ~/.config/nvim` → `nvim` (lazy.nvim auto-bootstraps and installs all plugins).

## File architecture

```
init.lua                  # Entry point: bootstraps lazy.nvim → lazy_setup → polish
lua/lazy_setup.lua        # lazy.nvim setup; imports AstroNvim core, community, user plugins
lua/community.lua         # Imports from AstroCommunity (lang packs, editing, motion, etc.)
lua/polish.lua            # Runs last; custom Lua/Vimscript that doesn't fit plugin specs
lua/plugins/*.lua         # One file per plugin/group; each returns a LazySpec
lazy-lock.json            # Pinned plugin versions (lazy.nvim lockfile)
selene.toml               # selene linter config (Lua linting, neovim std)
neovim.yml                # luacheck config (globals: vim)
.stylua.toml              # Formatter config: 120 cols, 2-space indent, no call parens
.luarc.json               # Disables built-in Lua formatter (stylua used instead)
.neoconf.json             # Neodev config for lua_ls (enables Neovim API completions)
```

## How config loads

1. `init.lua` clones lazy.nvim if missing, adds it to rtp, then calls `require "lazy_setup"` and `require "polish"`
2. `lazy_setup.lua` calls `require("lazy").setup()` with three import groups:
   - `astronvim.plugins` — AstroNvim built-in plugins (astrocore, astrolsp, astroui, treesitter, etc.)
   - `community` — AstroCommunity packs (language support, editing tools, motion, etc.)
   - `plugins` — user overrides and additional plugins (one file per plugin/group)
3. `polish.lua` runs immediately after `lazy_setup` is `require`d — it doesn't wait for lazy.nvim to finish loading plugins. Contains: the `:NN` command (yode-nvim editor replacement with filetype), an autocmd stripping `formatoptions-=ro` on all filetypes, relative number toggling on focus/blur (excluding snacks_dashboard, neo-tree, Trouble), and Neovide GUI settings.

## Key plugin configs

- **astrocore.lua** — Central mappings (`<Leader>` = space), vim options, filetypes, autocommands, features toggles (autopairs, cmp, diagnostics, etc.). Also configures treesitter, opencode LSP.
- **astrolsp.lua** — LSP features (codelens, inlay hints, format-on-save), server configs, custom elixirls cmd. Rust-specific keymaps via rustaceanvim + ferris.nvim in `on_attach`.
- **astroui.lua** — Colorscheme (catppuccin-nvim), highlight overrides, LSP loading icons.
- **blink-cmp.lua** — Completion engine with copilot integration (`<C-e>` to dismiss), ripgrep source via `blink-ripgrep.nvim`, cmdline completion, buffer filtering (excludes non-normal buftypes).
- **blink-cmp-fuzzy-path.lua** — Fuzzy path completion for markdown/json files (trigger: `@`). Injects itself into blink.cmp's sources via `specs`.
- **catppuccin.lua** — Full catppuccin integration config: dim_inactive, term_colors, per-plugin integration toggles (blink_cmp, snacks, noice, mini, etc.), native_lsp virtual_text/underlines styling.
- **mason.lua** — Auto-installs lua-language-server, stylua, debugpy, tree-sitter-cli, prettier. Configures prettier parser mapping for JS/SCSS/JSON/HTML/Vue.
- **none-ls.lua** — Null-ls/none-ls formatter/linter config stub (currently empty, sources appended via `list_insert_unique`).
- **treesitter.lua** — Extends astrocore treesitter opts: highlight + indent enabled, auto_install on, ensures lua/vim parsers.
- **user.lua** — Catch-all: autopairs custom rules, window management (windows.nvim, window-picker), testing (vim-test + shtuff strategy), HTTP client (kulala.nvim), markdown preview (markview.nvim), goto-preview, focus.nvim, paren-hint, caps-word, rip-substitute, in-and-out, and more. Each plugin block follows the standard spec/opts/dependencies pattern.
- **neovim_tips.lua** — Startup tips from `neovim_tips/user_tips.md`.

## Plugin configuration pattern

Every plugin file returns a `LazySpec` (a table or list of tables). Two patterns for extending AstroNvim defaults:

1. **Override plugin's own opts**: return a spec with the same plugin name and new `opts` — lazy.nvim deep-merges opts tables.

2. **Extend another plugin via `specs`**: a plugin can inject config into another plugin's spec. Two directions:
   - **User plugin → AstroNvim core** (e.g., adding keymaps to astrocore):
     ```lua
     return {
       "my-plugin",
       specs = {
         { "AstroNvim/astrocore", opts = function(_, opts)
             local maps = assert(opts.mappings)
             maps.n["<Leader>x"] = { ":Something<CR>", desc = "Do thing" }
         end },
       },
     }
     ```
   - **Plugin → another plugin** (e.g., blink-cmp-fuzzy-path injecting into blink.cmp):
     ```lua
     return {
       "newtoallofthis123/blink-cmp-fuzzy-path",
       dependencies = { "saghen/blink.cmp" },
       specs = {
         "saghen/blink.cmp",
         opts = function(_, opts)
           table.insert(opts.sources.default, "fuzzy-path")
           return require("astrocore").extend_tbl(opts, { ... })
         end,
       },
     }
     ```

3. **Use `astrocore.extend_tbl` / `astrocore.list_insert_unique`** when merging tables in opts overrides to avoid clobbering upstream defaults.

## Linting/formatting

- **Formatter**: stylua (enforced; `selene.toml` references it)
- **Linter**: selene with `std = "neovim"` configured in `selene.toml`
- Run: `stylua .` to format all Lua files; `selene .` to lint
- `neovim.yml` provides luacheck globals config (vim global)

## Testing changes

No test suite. Workflow: edit Lua files → restart Neovim or run `:Lazy reload <plugin>` or `:luafile %` to reload a single file. Pin plugin versions via `lazy-lock.json` (auto-updated by `:Lazy update`).

## Community imports

Language packs: lua, rust, python (pyrefly + ruff), zig, typescript, markdown, toml, yaml, json, docker, vue, elixir-phoenix, html-css, proto.

Tools from astrocommunity: trouble-nvim, noice-nvim, mini-bracketed/surround/ai/icons, flash-nvim, todo-comments, rainbow-delimiters, suda.vim, treesj, neotest, copilot-lua, grug-far, dropbar, snacks-picker, opencode-nvim, diffview-nvim.
