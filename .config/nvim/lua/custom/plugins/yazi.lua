return {
  {
    'mikavilpas/yazi.nvim',
    config = function()
      require('yazi').setup {
        open_for_directories = true,
        floating_window_scaling_factor = 0.8,
        keymaps = { show_help = '<f1>' },
      }
    end,
  },
}
