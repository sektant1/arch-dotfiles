require "nvchad.mappings"

local map = vim.keymap.set

-- ── Motion & editing ─────────────────────────────────────────────────────────
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "o", "<cmd>:call append(line('.'), '')<CR>")
map("n", "O", "<cmd>:call append(line('.')-1, '')<CR>")
map("n", "Y", "y$",    { desc = "Yank to end of line" })
map("n", "D", "d$",    { desc = "Delete to end of line" })
map("v", "H", "^",     { desc = "Start of line" })
map("v", "L", "$",     { desc = "End of line" })
map("x", "<leader>P", [["_dP]], { desc = "Replace selection without yanking" })

map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==",                         { desc = "Move line down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==",                   { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi",                                         { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi",                                         { desc = "Move line up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",             { desc = "Move block down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",      { desc = "Move block up" })

map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- ── Window management (<leader>w) ─────────────────────────────────────────────
map("n", "<leader>ws", "<cmd>split<cr>",   { desc = "Split horizontal" })
map("n", "<leader>wv", "<cmd>vsplit<cr>",  { desc = "Split vertical" })
map("n", "<leader>we", "<C-w>=",           { desc = "Equalize splits" })
map("n", "<leader>wc", "<cmd>close<cr>",   { desc = "Close window" })

-- ── LSP (<leader>l) ───────────────────────────────────────────────────────────
map("n", "<leader>la", vim.lsp.buf.code_action,  { desc = "Code action" })
-- map("n", "<leader>lr", vim.lsp.buf.rename,       { desc = "Rename symbol" })
map("n", "<leader>lR", vim.lsp.buf.references,   { desc = "References" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>li", "<cmd>LspInfo<cr>",        { desc = "LSP info" })
map("n", "<leader>lI", "<cmd>Mason<cr>",          { desc = "Mason installer" })

-- Diagnostic navigation
-- map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
-- map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

-- ── Git / Gitsigns (<leader>g) ────────────────────────────────────────────────
map("n", "<leader>gb", function() require("gitsigns").blame_line()  end, { desc = "Blame line" })
map("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
map("n", "<leader>gs", function() require("gitsigns").stage_hunk()  end, { desc = "Stage hunk" })
map("n", "<leader>gr", function() require("gitsigns").reset_hunk()  end, { desc = "Reset hunk" })
map("n", "<leader>gS", function() require("gitsigns").stage_buffer() end, { desc = "Stage buffer" })
map("n", "<leader>gR", function() require("gitsigns").reset_buffer() end, { desc = "Reset buffer" })
map("n", "<leader>gd", function() require("gitsigns").diffthis()    end, { desc = "Diff this" })
map("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Undo stage hunk" })

-- Hunk navigation
map("n", "]g", function() require("gitsigns").next_hunk() end, { desc = "Next hunk" })
map("n", "[g", function() require("gitsigns").prev_hunk() end, { desc = "Prev hunk" })

-- ── Debug / DAP (<leader>d) ───────────────────────────────────────────────────
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end,                          { desc = "Toggle breakpoint" })
map("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input "Condition: ") end,  { desc = "Conditional breakpoint" })
map("n", "<leader>dc", function() require("dap").continue()    end, { desc = "Continue" })
map("n", "<leader>di", function() require("dap").step_into()   end, { desc = "Step into" })
map("n", "<leader>do", function() require("dap").step_over()   end, { desc = "Step over" })
map("n", "<leader>dO", function() require("dap").step_out()    end, { desc = "Step out" })
map("n", "<leader>dl", function() require("dap").run_last()    end, { desc = "Run last" })
map("n", "<leader>dr", function() require("dap").repl.open()   end, { desc = "Open REPL" })
map("n", "<leader>du", function() require("dapui").toggle()    end, { desc = "Toggle UI" })
map("n", "<leader>dt", function() require("dap").terminate()   end, { desc = "Terminate" })
