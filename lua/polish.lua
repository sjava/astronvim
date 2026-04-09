-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
    wxml = "html",
    wxss = "css",
    mpx = "vue",
    http = "http",
    wxs = "javascript",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
  },
}

vim.cmd [[
      command! -nargs=* -bang -range -complete=filetype NN
      \ call luaeval("require('yode-nvim').createSeditorReplace(_A[1], _A[2])", [<line1>, <line2>])
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
  desc = "Absolutnumber unfoccused enter",
})
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  group = augroup,
  callback = function(_)
    if not contains(ignore_filetypes, vim.bo.filetype) then
      vim.wo.number = true
      vim.wo.relativenumber = false
    end
  end,
  desc = "Absolutnumber unfoccused leave",
})

if vim.g.neovide then
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_fullscreen = true
  vim.g.neovide_refresh_rate = 60

  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0

  vim.keymap.set("c", "<C-v>", "<C-R>+") -- Paste command mode

  -- Allow clipboard copy paste in neovim
  vim.api.nvim_set_keymap("", "<C-S-v>", "+p<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("!", "<C-S-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("t", "<C-S-v>", '<C-\\><C-N>"+pi', { noremap = true, silent = true })
  vim.api.nvim_set_keymap("v", "<C-S-v>", "<C-R>+", { noremap = true, silent = true })
end
