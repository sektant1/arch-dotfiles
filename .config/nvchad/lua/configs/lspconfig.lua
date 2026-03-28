require("nvchad.configs.lspconfig").defaults()

local servers = {
    "html",
    "cssls",
    "ts_ls", -- TypeScript / JavaScript / JSX / TSX
    "eslint", -- ESLint diagnostics + code actions
    "jsonls", -- JSON with schema validation
    "yamlls", -- YAML (docker-compose, CI configs, etc.)
    "dockerls", -- Dockerfile
    "docker_compose_language_service", -- docker-compose.yml
    "lua_ls",
    "bash_ls",
    "pyright",
    "ruff",
    "clangd",
}

vim.api.nvim_create_augroup("CssNavigation", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = "CssNavigation",
    pattern = { "html", "css", "javascriptreact", "typescriptreact" },
    callback = function()
        -- Enable CSS Intellisense or specific LSP settings here
        vim.lsp.enable "cssls"
    end,
})

vim.lsp.enable(servers)

-- JSON: validate against SchemaStore (package.json, tsconfig, eslintrc, etc.)
vim.lsp.config("jsonls", {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
})

-- YAML: validate docker-compose, GitHub Actions, Kubernetes, etc.
vim.lsp.config("yamlls", {
    settings = {
        yaml = {
            schemaStore = { enable = false, url = "" }, -- use schemastore.nvim instead
            schemas = require("schemastore").yaml.schemas(),
        },
    },
})
