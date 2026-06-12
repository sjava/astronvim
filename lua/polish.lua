-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- NOTE: custom filetypes are now configured in lua/plugins/astrocore.lua opts.filetypes

vim.cmd [[
      command! -nargs=* -bang -range -complete=filetype NN
      \ call luaeval("pcall(require('yode-nvim').createSeditorReplace, _A[1], _A[2])", [<line1>, <line2>])
      \ | set filetype=<args>
    ]]
vim.cmd [[autocmd FileType * set formatoptions-=ro]]

local function contains(table, val)
  for i = 1, #table do
    if table[i] == val then return true end
  end
  return false
end
local augroup = vim.api.nvim_create_augroup("MySetNumber", { clear = true })
local ignore_filetypes = { "snacks_dashboard", "neo-tree", "Trouble" }
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = augroup,
  callback = function(_)
    if not contains(ignore_filetypes, vim.bo.filetype) then
      vim.wo.number = true
      vim.wo.relativenumber = true
    end
  end,
  desc = "Absolute number unfocused enter",
})
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  group = augroup,
  callback = function(_)
    if not contains(ignore_filetypes, vim.bo.filetype) then
      vim.wo.number = true
      vim.wo.relativenumber = false
    end
  end,
  desc = "Absolute number unfocused leave",
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  pattern = "*",
  callback = function()
    -- 检测当前窗口是否开启了 diff 模式
    if vim.wo.diff then
      -- 禁用当前窗口的 winbar（dropbar 依赖 winbar 显示）
      vim.wo.winbar = ""
      -- 如果 dropbar 还在强行渲染，可以调用其内部 API 关闭（可选）
      pcall(function() require("dropbar.api").goto_context(-1) end)
    end
  end,
})
