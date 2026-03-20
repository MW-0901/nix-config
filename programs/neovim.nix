{ config, pkgs, ... }:
{
  programs.nvf = {
    enable = true;
    settings = {
      vim.theme.enable = true;
      vim.autocomplete.blink-cmp.enable = true;
      vim.treesitter.enable = true;
      vim.telescope.enable = true;
      vim.filetree.neo-tree.enable = true;
      vim.tabline.nvimBufferline.enable = true;
      vim.terminal.toggleterm.enable = true;
      vim.undoFile.enable = true;
      vim.clipboard.registers = "unnamedplus";
      vim.dashboard.dashboard-nvim.enable = true;
      vim.languages.nix = {
        lsp = {
          enable = true;
        };
        enable = true;
      };
      vim.languages.rust = {
        lsp = {
          enable = true;
        };
        enable = true;
      };
      vim.languages.clang = {
        lsp = {
          enable = true;
        };
        enable = true;
      };
      vim.languages.python = {
        lsp = {
          enable = true;
        };
        enable = true;
      };
      vim.viAlias = true;
      vim.vimAlias = true;
      vim.lsp.enable = true;
      vim.keymaps = [
        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<cr>";
        }
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Neotree toggle<cr>";
        }
        {
          mode = "n";
          key = "<C-s>";
          action = ":w<CR>";
        }
        {
          mode = "i";
          key = "<C-s>";
          action = "<Esc>:w<CR>a";
        }
        {
          mode = "v";
          key = "<C-s>";
          action = ":w<CR>";
        }
        {
          mode = "n";
          key = "<C-q>";
          action = ":qa<CR>";
        }
        {
          mode = "i";
          key = "<C-q>";
          action = "<Esc>:qa<CR>";
        }
        {
          mode = "v";
          key = "<C-q>";
          action = "<Esc>:qa<CR>";
        }
        {
          mode = "n";
          key = "<C-\\>";
          action = "<cmd>lua ToggleTerminalRight()<cr>";
        }
        {
          mode = "t";
          key = "<C-\\>";
          action = "<C-\\><C-n><cmd>lua ToggleTerminalRight()<cr>";
        }
      ];
      vim.luaConfigPre = ''
        vim.deprecate = function() end
      '';
      vim.luaConfigPost = ''
        require("neo-tree").setup({
          window = {
            position = "left",
            width = 30,
          },
        })

        require("bufferline").setup({
          options = {
            offsets = {
              {
                filetype = "neo-tree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "center",
                separator = true
              }
            },
            custom_filter = function(buf_number)
              if vim.bo[buf_number].buftype == "terminal" then
                return false
              end
              return true
            end,
          },
        })

        vim.api.nvim_create_autocmd("BufReadPost", {
          callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end,
        })

        local term_buf = nil
        local term_win = nil

        function ToggleTerminalRight()
          if term_win and vim.api.nvim_win_is_valid(term_win) then
            vim.api.nvim_win_close(term_win, false)
            term_win = nil
          else
            local main_win = nil
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.bo[buf].filetype
              if ft ~= 'neo-tree' and vim.bo[buf].buftype ~= 'terminal' then
                main_win = win
                break
              end
            end
            
            if main_win then
              vim.api.nvim_set_current_win(main_win)
              
              vim.cmd('belowright 15split')
              
              if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
                vim.api.nvim_win_set_buf(0, term_buf)
              else
                vim.cmd('terminal')
                term_buf = vim.api.nvim_get_current_buf()
              end
              
              term_win = vim.api.nvim_get_current_win()
              vim.cmd('startinsert')
            end
          end
        end

        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            local win = vim.api.nvim_get_current_win()
            
            require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
            
            vim.api.nvim_set_current_win(win)
            
            ToggleTerminalRight()
            
            vim.api.nvim_set_current_win(win)
            vim.cmd('stopinsert')
          end,
        })
      '';
    };
  };
}
