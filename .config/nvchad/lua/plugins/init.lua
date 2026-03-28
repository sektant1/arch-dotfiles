return {
    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        opts = require "configs.conform",
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = function()
            require("lazy").load { plugins = { "markdown-preview.nvim" } }
            vim.fn["mkdp#util#install"]()
        end,
        keys = {
            {
                "<leader>mp",
                ft = "markdown",
                "<cmd>MarkdownPreviewToggle<cr>",
                desc = "Markdown Preview",
            },
        },
        config = function()
            vim.cmd [[do FileType]]
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        event = "VeryLazy",
        config = function()
            require("nvim-ts-autotag").setup {
                opts = {
                    enable_close = true, -- Auto close tags
                    enable_rename = true, -- Auto rename pairs
                    enable_close_on_slash = false, -- Auto close on </
                },
            }
        end,
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = { "b0o/schemastore.nvim" },
        config = function()
            require "configs.lspconfig"
        end,
    },

    -- test new blink
    { import = "nvchad.blink.lazyspec" },

    -- which-key group labels
    {
        "folke/which-key.nvim",
        opts = function(_, opts)
            opts.spec = opts.spec or {}
            vim.list_extend(opts.spec, {
                { "<leader>d", group = "debug" },
                { "<leader>f", group = "find" },
                { "<leader>g", group = "git" },
                { "<leader>l", group = "lsp" },
                { "<leader>t", group = "ui" },
                { "<leader>w", group = "window" },
                { "]", group = "next" },
                { "[", group = "prev" },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "vim",
                "lua",
                "vimdoc",
                "html",
                "css",
                "javascript",
                "typescript",
                "tsx",
                "json",
                "jsonc",
                "yaml",
                "dockerfile",
                "bash",
                "python",
            },
        },
    },

    -- Node.js / JS / TS / React debugger via vscode-js-debug
    {
        "mxsdev/nvim-dap-vscode-js",
        dependencies = {
            "mfussenegger/nvim-dap",
            {
                "microsoft/vscode-js-debug",
                version = "1.*",
                build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
            },
        },
        config = function()
            require("dap-vscode-js").setup {
                debugger_path = vim.fn.stdpath "data" .. "/lazy/vscode-js-debug",
                adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
            }

            local dap = require "dap"
            local js_langs = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

            for _, lang in ipairs(js_langs) do
                dap.configurations[lang] = {
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch Node file",
                        program = "${file}",
                        cwd = "${workspaceFolder}",
                    },
                    {
                        type = "pwa-node",
                        request = "attach",
                        name = "Attach to Node process",
                        processId = require("dap.utils").pick_process,
                        cwd = "${workspaceFolder}",
                    },
                    {
                        type = "pwa-chrome",
                        request = "launch",
                        name = "Launch Chrome (localhost:3000)",
                        url = "http://localhost:3000",
                        webRoot = "${workspaceFolder}",
                    },
                }
            end
        end,
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            require("dapui").setup()
        end,
    },
}
