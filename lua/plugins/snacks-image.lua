---@type LazySpec
-- 禁用 snacks 图片预览:
-- 预览图片时 snacks 会向终端发送 kitty 图形协议查询,
-- 应答经 tmux passthrough 返回后被 nvim 误当作键盘输入注入,
-- 导致 picker 输入框收到 ESC/乱码字节而被关闭 (picker.lua:310),
-- 并触发 input.lua:89 的 nil picker 报错。
return {
  "folke/snacks.nvim",
  opts = {
    image = { enabled = false },
  },
}
