local M = {}

----------------------------------------------------------------------
-- utils
----------------------------------------------------------------------

local function git_relative(path)
  local root = vim.fs.root(path, { ".git" })
  if not root then return vim.fn.fnamemodify(path, ":.") end

  return vim.fs.relpath(root, path) or vim.fn.fnamemodify(path, ":.")
end

local function make_output(path, start_line, end_line, text)
  local ft = vim.bo.filetype
  if ft == "" then ft = "text" end

  return string.format("%s:%d-%d\n\n```%s\n%s\n```", path, start_line, end_line, ft, text)
end

local function copy_to_clipboard(text, start_line, end_line)
  local path = git_relative(vim.api.nvim_buf_get_name(0))
  local output = make_output(path, start_line, end_line, text)

  vim.fn.setreg("+", output)

  vim.notify(string.format("Copied %s:%d-%d", path, start_line, end_line), vim.log.levels.INFO, { title = "AI Copy" })
end

----------------------------------------------------------------------
-- Visual Mode
----------------------------------------------------------------------

local function visual_copy()
  local p1 = vim.fn.getpos "v"
  local p2 = vim.fn.getpos "."

  local start_line = math.min(p1[2], p2[2])
  local end_line = math.max(p1[2], p2[2])

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  copy_to_clipboard(table.concat(lines, "\n"), start_line, end_line)
end

----------------------------------------------------------------------
-- Normal Mode
----------------------------------------------------------------------

local FUNCTION_NODES = {
  function_item = true, -- Rust
  function_definition = true, -- Lua / C / Python ...
  method_definition = true,
}

local function normal_copy()
  local node = vim.treesitter.get_node()

  while node do
    if FUNCTION_NODES[node:type()] then
      local sr, _, er, _ = node:range()

      copy_to_clipboard(vim.treesitter.get_node_text(node, 0), sr + 1, er + 1)

      return
    end

    node = node:parent()
  end

  vim.notify("No function found", vim.log.levels.WARN, { title = "AI Copy" })
end

----------------------------------------------------------------------
-- setup
----------------------------------------------------------------------

function M.setup(opts)
  opts = opts or {}

  local key = opts.keymap or "<leader>ay"

  vim.keymap.set("x", key, visual_copy, {
    desc = "AI Copy Selection",
  })

  vim.keymap.set("n", key, normal_copy, {
    desc = "AI Copy Function",
  })
end

return M
