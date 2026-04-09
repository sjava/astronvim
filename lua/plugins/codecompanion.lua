return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts, {
      adapters = {
        http = {
          qwen3 = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "qwen3",
              env = {
                api_key = os.getenv "QWEN_API_KEY",
                url = "https://dashscope.aliyuncs.com/compatible-mode",
                chat_url = "/v1/chat/completions",
                models_endpoint = "/v1/models",
              },
              schema = {
                model = {
                  default = "qwen3-max",
                },
              },
            })
          end,
          qiniu = function()
            -- 1. 首先解析并获取内置的 openai_compatible 适配器基础对象
            local openai_compatible = require("codecompanion.adapters").resolve "openai_compatible"

            -- 2. 使用 extend 方法进行扩展
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "qiniu",
              env = {
                api_key = os.getenv "QINIU_API_KEY",
                url = "https://api.qnaigc.com",
              },
              schema = {
                model = {
                  -- 设置默认启动模型
                  default = "gemini-3.0-pro-preview",
                  -- 3. 重写选择逻辑以合并手动模型
                  choices = function(self)
                    -- 执行原有的动态获取逻辑（即从 /v1/models 获取）
                    local models = openai_compatible.schema.model.choices(self)

                    -- 4. 手动追加你想要的特定模型
                    local manual_models = {
                      "gemini-3.0-pro-preview",
                      "claude-3-5-sonnet-latest", -- 你也可以顺便多加几个
                    }

                    -- 将手动模型插入列表（检查是否已存在以避免重复）
                    for _, m in ipairs(manual_models) do
                      local exists = false
                      for _, existing_m in ipairs(models) do
                        if existing_m == m then
                          exists = true
                          break
                        end
                      end
                      if not exists then
                        table.insert(models, 1, m) -- 插入到列表最前方，方便选择
                      end
                    end

                    return models
                  end,
                },
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          adapter = "qwen3",
          slash_commands = {
            ["symbols"] = {
              opts = {
                provider = "snacks",
              },
            },
            ["buffer"] = {
              opts = {
                provider = "snacks",
              },
            },
            ["file"] = {
              opts = {
                provider = "snacks", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks"
              },
            },
            ["help"] = {
              opts = {
                provider = "snacks",
                max_lines = 1000,
              },
            },
          },
          keymaps = (function()
            local keymaps = vim.deepcopy(require("codecompanion.config").config.interactions.chat.keymaps)
            for _, keymap in pairs(keymaps) do
              if type(keymap.modes) == "string" then keymap.modes = { keymap.modes } end
              local new_modes = {}
              for mode, keys in pairs(keymap.modes or {}) do
                if type(keys) == "string" then
                  keys = { keys }
                elseif type(keys) ~= "table" then
                  keys = {}
                end
                for i, key in ipairs(keys) do
                  if type(key) == "string" and key:sub(1, 1) == "g" then keys[i] = "<localleader>" .. key:sub(2) end
                end
                new_modes[mode] = keys
              end
              keymap.modes = new_modes
            end
            return keymaps
          end)(),
        },
        inline = { adapter = "qwen3" },
        cmd = { adapter = "qwen3" },
      },
    })
  end,
}
