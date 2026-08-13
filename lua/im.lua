local M = {}
local english = "com.apple.keylayout.ABC"
local previous = english

-- 获取当前输入法
local function current_im()
  local out = vim.system({ "im-select" }):wait().stdout or ""
  return vim.trim(out)
end

-- 切换输入法（异步，不阻塞）
local function switch_im(im) vim.system({ "im-select", im }, { detach = true }) end

function M.setup(opts)
  opts = opts or {}

  -- 退出插入模式时切英文
  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      previous = current_im()
      switch_im(english)
    end,
  })

  -- 进入插入模式时恢复之前输入法
  vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function() switch_im(previous) end,
  })

  -- 离开命令行模式也切英文
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function() switch_im(english) end,
  })

  -- 从其他应用切回 Neovim 时切英文
  vim.api.nvim_create_autocmd("FocusGained", {
    callback = function() switch_im(english) end,
  })
end

return M
