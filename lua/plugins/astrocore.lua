-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

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
      },
      filename = {
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
        opencode_opts = {
          lsp = {
            enabled = true,
            handlers = {
              hover = {
                enabled = false,
              },
            },
          },
          server = {
            -- 启动：在新标签页 (Tab) 中打开
            start = function()
              vim
                .system({
                  "kitty",
                  "@",
                  "launch",
                  "--type=tab", -- 关键改动：从 window 改为 tab
                  "--tab-title=opencode", -- 给标签页起个名字，方便识别
                  "opencode",
                  "--agent",
                  "plan",
                  "--port",
                })
                :wait()

              -- 将焦点切回之前的标签页（Neovim 所在的标签页）
              -- Kitty 的 recent:1 在标签页维度同样适用
              vim.system { "kitty", "@", "focus-window", "--match", "recent:1" }
            end,

            -- 停止：匹配标签页标题并关闭
            stop = function()
              vim.system {
                "kitty",
                "@",
                "close-tab", -- 关键改动：关闭整个标签页
                "--match",
                "title:opencode",
              }
            end,

            -- 切换逻辑
            toggle = function()
              -- 检查是否存在名为 opencode 的标签页
              local check = vim.system({ "kitty", "@", "ls" }):wait()
              if check.stdout and check.stdout:find '"title": "opencode"' then
                vim.g.opencode_opts.server.stop()
              else
                vim.g.opencode_opts.server.start()
              end
            end,
          },
        },
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
        ["<Leader>wc"] = {
          function() require("nvim_winpick").pick_close_window() end,
          desc = "Pick close window",
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

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
        -- ["<esc>"] = { "<C-\\><C-n>", desc = "escape terminal" },
      },
    },
  },
}
