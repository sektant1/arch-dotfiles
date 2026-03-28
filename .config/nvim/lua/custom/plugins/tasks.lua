return {
  'Shatur/neovim-tasks',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'mfussenegger/nvim-dap', -- optional (needed for :Task start cmake debug / configureDebug)
  },
  event = 'VeryLazy',
  config = function()
    local Path = require 'plenary.path'

    require('tasks').setup {
      default_params = {
        cmake = {
          cmd = 'cmake',
          build_type = 'Debug',
          -- default kit
          build_kit = 'clang-ninja',
          -- point to the kits file
          cmake_kits_file = tostring(Path:new(vim.fn.stdpath 'config', 'cmake-kits.json')),
          dap_name = 'codelldb',
          build_dir = tostring(Path:new('{cwd}', 'bin', '{build_type}')),
          restart_clangd_after_configure = true,
          ignore_presets = false,
        },
      },
      save_before_run = true,
      params_file = 'neovim.json',
      quickfix = { pos = 'botright', height = 12, only_on_error = false },
    }

    -- Add a global task that builds the CMake target "tests" and then runs ctest.
    -- Run with: :Task start cmake test
    do
      local cmake_mod = require 'tasks.module.cmake'
      local function build_target(target_name)
        return function(module_config, prev)
          local cfg = vim.tbl_deep_extend('force', {}, module_config, { target = target_name })
          return cmake_mod.tasks.build(cfg, prev)
        end
      end
      cmake_mod.tasks.build_tests = build_target 'tests'
      cmake_mod.tasks.test = { build_target 'tests', cmake_mod.tasks.ctest }
    end

    -- IMPORTANT: this plugin uses the *global* Neovim cwd (vim.loop.cwd()) for:
    -- - expanding {cwd} in build_dir
    -- - where neovim.json is read/written
    -- So prefer :cd (global), not :lcd (window-local).
    local function cd_to_cmake_root()
      local buf = vim.api.nvim_buf_get_name(0)
      local start = (buf ~= '' and vim.fs and vim.fs.dirname(buf)) or vim.loop.cwd()
      if not (vim.fs and vim.fs.find) then
        return nil
      end
      local found = vim.fs.find('CMakeLists.txt', { path = start, upward = true })[1]
      if not found then
        return nil
      end
      local root = vim.fs.dirname(found)
      if root and vim.loop.cwd() ~= root then
        vim.cmd('cd ' .. vim.fn.fnameescape(root))
      end
      return root
    end

    local function task(cmdline)
      return function()
        cd_to_cmake_root()
        vim.cmd(cmdline)
      end
    end

    -- Keymaps (CMake)
    vim.keymap.set('n', '<leader>cc', task 'Task start cmake configure', { desc = 'CMake: configure' })
    vim.keymap.set('n', '<leader>cb', task 'Task start cmake build', { desc = 'CMake: build (selected target)' })
    vim.keymap.set('n', '<leader>ca', task 'Task start cmake build_all', { desc = 'CMake: build all' })
    vim.keymap.set('n', '<leader>cr', task 'Task start cmake run', { desc = 'CMake: run (build+run)' })
    vim.keymap.set('n', '<leader>cd', task 'Task start cmake debug', { desc = 'CMake: debug (build+dap)' })

    -- “tests target” + ctest (global task added above)
    vim.keymap.set('n', '<leader>cT', task 'Task start cmake test', { desc = 'CMake: build "tests" + ctest' })

    -- ctest only
    vim.keymap.set('n', '<leader>ct', task 'Task start cmake ctest', { desc = 'CMake: ctest' })

    -- selection UI
    vim.keymap.set('n', '<leader>cs', task 'Task set_module_param cmake target', { desc = 'CMake: select target' })
    vim.keymap.set('n', '<leader>cB', task 'Task set_module_param cmake build_type', { desc = 'CMake: select build type' })
    vim.keymap.set('n', '<leader>ck', task 'Task set_module_param cmake build_kit', { desc = 'CMake: select kit' })

    -- convenience: open ccmake in a bottom split
    vim.keymap.set('n', '<leader>cC', function()
      cd_to_cmake_root()
      local build_dir = tostring(require('tasks.cmake_utils.cmake_utils').getBuildDir())
      vim.cmd('botright split | terminal ccmake ' .. vim.fn.fnameescape(build_dir))
    end, { desc = 'CMake: ccmake (terminal)' })

    vim.keymap.set('n', '<C-c>', task 'Task cancel', { desc = 'Task: cancel' })
  end,
}
