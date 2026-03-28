return {
  {
    'nvimdev/dashboard-nvim',
    lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
    opts = function()
      local logo = [[
.▄▄ · ▄▄▄ .▄ •▄ ▄▄▄▄▄ ▄▄▄·  ▐ ▄ ▄▄▄▄▄
▐█ ▀. ▀▄.▀·█▌▄▌▪•██  ▐█ ▀█ •█▌▐█•██  
▄▀▀▀█▄▐▀▀▪▄▐▀▀▄· ▐█.▪▄█▀▀█ ▐█▐▐▌ ▐█.▪
▐█▄▪▐█▐█▄▄▌▐█.█▌ ▐█▌·▐█ ▪▐▌██▐█▌ ▐█▌·
 ▀▀▀▀  ▀▀▀ ·▀  ▀ ▀▀▀  ▀  ▀ ▀▀ █▪ ▀▀▀ 
 ]]

      logo = string.rep('\n', 8) .. logo .. '\n\n'

      local opts = {
        theme = 'doom',
        hide = {
          statusline = false,
        },

        config = {
          header = vim.split(logo, '\n'),
          center = {
            {
              action = function()
                require('telescope.builtin').find_files()
              end,
              desc = ' Find File',
              icon = ' ',
              key = 'f',
            },
            {
              action = function()
                local ok, telescope = pcall(require, 'telescope')
                if ok and telescope.extensions and telescope.extensions.projects then
                  telescope.extensions.projects.projects {}
                  return
                end

                -- Fallback if project.nvim extension isn't available yet.
                require('telescope.builtin').find_files { cwd = vim.loop.cwd() }
              end,
              desc = ' Find Project',
              icon = ' ',
              key = 'p',
            },

            {
              action = function()
                vim.api.nvim_input '<cmd>qa<cr>'
              end,
              desc = ' Quit',
              icon = ' ',
              key = 'q',
            },
          },
          sections = {
            {
              section = 'terminal',
              cmd = 'pokemon-colorscripts -r --no-title; sleep .1',
              random = 10,
              indent = 4,
              height = 30,
            },
            { section = 'header' },
            { section = 'keys', gap = 1, padding = 1 },
            { section = 'startup' },
          },
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
        button.key_format = '  %s'
      end

      return opts
    end,
  },
}
