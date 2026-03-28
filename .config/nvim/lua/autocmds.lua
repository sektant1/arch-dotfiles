vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Prefer the LSP root dir (clangd will set this to the project root)
    local root = client.config.root_dir
    if root and root ~= '' then
      -- Change global cwd (use :lcd for window-local if you prefer)
      vim.cmd('cd ' .. vim.fn.fnameescape(root))
    end
  end,
})
