# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal AstroNvim v6+ user configuration. Deployed to `~/.config/nvim`. Uses lazy.nvim as plugin manager.

## File architecture

```
init.lua                  # Entry point: bootstraps lazy.nvim → lazy_setup → polish
lua/lazy_setup.lua        # lazy.nvim setup; imports AstroNvim core, community, user plugins
lua/community.lua         # Imports from AstroCommunity (lang packs, editing, motion, etc.)
lua/polish.lua            # Runs last; custom Lua that doesn't fit plugin specs
lua/plugins/*.lua         # One file per plugin/group; each returns a LazySpec
lazy-lock.json            # Pinned plugin versions (lazy.nvim lockfile)
selene.toml               # selene linter config (Lua linting, neovim std)
neovim.yml                # luacheck config (globals: vim)
```

## How config loads

1. `init.lua` clones lazy.nvim if missing, adds it to rtp
2. `lazy_setup.lua` calls `require("lazy").setup()` with three import groups:
   - `astronvim.plugins` — AstroNvim built-in plugins (astrocore, astrolsp, astroui, treesitter, etc.)
   - `community` — AstroCommunity packs (language support, editing tools, motion, etc.)
   - `plugins` — user overrides and additional plugins
3. `polish.lua` runs after lazy setup completes — raw Vimscript/Lua for edge cases

## Key plugin configs

- **astrocore.lua** — Central mappings (`<Leader>` = space), vim options, filetypes, autocommands, features toggles (autopairs, cmp, diagnostics, etc.)
- **astrolsp.lua** — LSP features (codelens, inlay hints, format-on-save), server configs, on_attach (rust-analyzer keymaps via rustaceanvim + ferris.nvim)
- **astroui.lua** — Colorscheme (catppuccin), highlight overrides, icons
- **blink-cmp.lua** — Completion engine with copilot integration, ripgrep source, buffer filtering
- **mason.lua** — Auto-installs lua-language-server, stylua, debugpy, tree-sitter-cli, prettier
- **treesitter.lua** — Highlight + indent enabled, auto_install on, ensures lua/vim parsers
- **user.lua** — Misc plugins: autopairs rules, git tools, window management, testing (vim-test), HTTP client (kulala.nvim), markdown preview, etc.

## Plugin configuration pattern

Every plugin file returns a `LazySpec`. Two patterns for extending AstroNvim defaults:

1. **Override plugin's own opts**: return a spec with the same plugin name and new `opts`
2. **Extend astrocore/astroui**: use `specs` to hook into core plugin configs, e.g.:

```lua
return {
  "some-plugin",
  opts = { ... },
  specs = {
    { "AstroNvim/astrocore", opts = function(_, opts)
        local maps = assert(opts.mappings)
        maps.n["<Leader>x"] = { ":Something<CR>", desc = "Do thing" }
    end },
  },
}
```

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
