-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

-- Clipboard: copy via OSC 52 (reaches the local terminal through zellij/SSH).
-- Paste via the host's native tool: terminals/multiplexers don't answer OSC 52
-- read queries. Hosts without any tool fall back to an OSC 52 read attempt.
local osc52 = require "vim.ui.clipboard.osc52"
local paste_cmd ---@type string[]?
if vim.fn.has "macunix" == 1 then
  paste_cmd = { "pbpaste" }
elseif vim.fn.executable "wl-paste" == 1 then
  paste_cmd = { "wl-paste", "--no-newline" }
elseif vim.fn.executable "xclip" == 1 then
  paste_cmd = { "xclip", "-o", "-selection", "clipboard" }
elseif vim.fn.executable "xsel" == 1 then
  paste_cmd = { "xsel", "-o", "-b" }
end

local clipboard = {
  name = "osc52-copy+" .. (paste_cmd and (paste_cmd[1] .. "-paste") or "osc52-paste"),
  copy = { ["+"] = osc52.copy "+", ["*"] = osc52.copy "*" },
  paste = paste_cmd and { ["+"] = paste_cmd, ["*"] = paste_cmd }
    or { ["+"] = osc52.paste "+", ["*"] = osc52.paste "*" },
}

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
        wxml = "html",
        wxss = "css",
        mpx = "vue",
        http = "http",
        wxs = "javascript",
        svg = "html",
      },
      filename = {
        ["Foofile"] = "fooscript",
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        python3_host_prog = "python",
        node_host_prog = "node",
        clipboard = clipboard, -- defined at top of file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        ["<Leader>ws"] = { "<C-w>s", desc = "horizontal split window" },
        ["<Leader>wv"] = { "<C-w>v", desc = "vertical split window" },
        ["<Leader>wh"] = { "<C-w>h", desc = "left window" },
        ["<Leader>wj"] = { "<C-w>j", desc = "below window" },
        ["<Leader>wl"] = { "<C-w>l", desc = "right window" },
        ["<Leader>wk"] = { "<C-w>k", desc = "up window" },
        ["<Leader>ww"] = {
          function()
            local picker = require "window-picker"
            local picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
            vim.api.nvim_set_current_win(picked_window_id)
          end,
          desc = "Pick a window",
        },
        -- mappings seen under group name "Buffer"
        ["<Leader>b"] = { desc = "Buffers" },
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },
        ["<Leader>um"] = { function() require("render-markdown").toggle() end, desc = "Toggle render-markdown" },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      i = {
        ["<C-a>"] = { "<C-o>^", desc = "move to beginning of line" },
        ["<C-e>"] = { "<C-o>A", desc = "move to end of line" },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
        -- ["<esc>"] = { "<C-\\><C-n>", desc = "escape terminal" },
      },
    },
  },
}
