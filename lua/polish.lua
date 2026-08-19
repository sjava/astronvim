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

local diff_group = vim.api.nvim_create_augroup("MyDiff", { clear = true })
local md_diff_disabled = {}

local function codediff_buffer(buf)
  local session_mod = package.loaded["codediff.ui.lifecycle.session"]
  if not session_mod then return false end
  for _, sess in pairs(session_mod.get_active_diffs()) do
    for _, win in ipairs { sess.original_win, sess.modified_win } do
      if win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then return true end
    end
  end
  return false
end

local function has_diff_window(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    if vim.api.nvim_get_option_value("diff", { win = win }) then return true end
  end
  return false
end

local function set_render_markdown(buf, enable)
  if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "markdown" then
    pcall(require("render-markdown.core.manager").set_buf, buf, enable)
  end
end

local function sync_render_markdown_diff()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "markdown" then return end
  if codediff_buffer(buf) or has_diff_window(buf) then
    md_diff_disabled[buf] = true
    set_render_markdown(buf, false)
  elseif md_diff_disabled[buf] then
    md_diff_disabled[buf] = nil
    set_render_markdown(buf, true)
  end
end

local function reenable_all()
  for buf in pairs(md_diff_disabled) do
    if vim.api.nvim_buf_is_valid(buf) and not codediff_buffer(buf) and not has_diff_window(buf) then
      md_diff_disabled[buf] = nil
      set_render_markdown(buf, true)
    end
  end
end

local function win_in_diff(win)
  if vim.api.nvim_get_option_value("diff", { win = win }) then return true end
  local session_mod = package.loaded["codediff.ui.lifecycle.session"]
  if session_mod then
    for _, sess in pairs(session_mod.get_active_diffs()) do
      if sess.original_win == win or sess.modified_win == win then return true end
    end
  end
  return false
end

local function sync_winbar(win)
  if not vim.api.nvim_win_is_valid(win) then return end
  if win_in_diff(win) then
    -- 关闭 diff 窗口上的 winbar（dropbar 的 bar.enable 已阻止其重新 attach）
    vim.api.nvim_set_option_value("winbar", "", { win = win })
  else
    -- 离开 diff 后主动恢复 winbar，不必等 dropbar 的 attach 事件
    pcall(function() require("dropbar.utils.bar").attach(vim.api.nvim_win_get_buf(win), win) end)
  end
end

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  group = diff_group,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    sync_winbar(win)
    sync_render_markdown_diff()
    -- codediff 的 session 注册/更新晚于 buffer/窗口就绪，延迟复查一次
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_call(win, sync_render_markdown_diff)
        sync_winbar(win)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("OptionSet", {
  group = diff_group,
  pattern = "diff",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_call(win, sync_render_markdown_diff)
        sync_winbar(win)
      end
    end)
  end,
})

-- codediff.nvim 不使用 vim 的 'diff' 选项，通过它的 User 事件同步两个 pane
vim.api.nvim_create_autocmd("User", {
  group = diff_group,
  pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
  callback = function(args)
    local tabpage = args.data and args.data.tabpage
    if not tabpage then return end
    vim.schedule(function()
      local lifecycle = package.loaded["codediff.ui.lifecycle"]
      if not lifecycle then return end
      local sess = lifecycle.get_session(tabpage)
      if not sess then return end
      for _, win in ipairs { sess.original_win, sess.modified_win } do
        if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_call(win, sync_render_markdown_diff) end
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = diff_group,
  pattern = "CodeDiffClose",
  callback = function() vim.schedule(reenable_all) end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = diff_group,
  callback = function(args) md_diff_disabled[args.buf] = nil end,
})

require("ai_copy").setup()

vim.keymap.set("n", "<leader>tt", function() require("toggle_task").toggle() end, {
  desc = "Toggle Markdown Task",
  silent = true,
})

-- only enable input method switching on macOS
if vim.fn.has "mac" == 1 then require("im").setup() end
