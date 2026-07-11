local M = {}

function M.toggle()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()

  local new = nil

  -- [ ] -> [x]
  if line:match "^%s*[-*+] %[%s%]" then
    new = line:gsub("%[%s%]", "[x]", 1)

  -- [x] -> [ ]
  elseif line:match "^%s*[-*+] %[x%]" then
    new = line:gsub("%[x%]", "[ ]", 1)

  -- [X] -> [ ]
  elseif line:match "^%s*[-*+] %[X%]" then
    new = line:gsub("%[X%]", "[ ]", 1)
  end

  if new then vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new }) end
end

return M
