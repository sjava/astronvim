-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",

        -- install formatters
        "stylua",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = function(_, opts)
      local null_ls = require "null-ls"
      local parsers = {
        javascript = "babel",
        scss = "scss",
        json = "json",
        html = "html",
        vue = "vue",
      }
      -- add more things to the ensure_installed table protecting against community packs modifying it
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "prettier",
        "stylua",
        -- add more arguments for adding more null-ls sources
      })
      opts.handlers = {
        prettierd = function() end,
        prettier = function()
          null_ls.register(null_ls.builtins.formatting.prettier.with {
            extra_args = function(params)
              local parser = parsers[params.ft]
              if parser then return { "--parser", parsers[params.ft] } end
            end,
          })
        end,
      }
    end,
  },
}
