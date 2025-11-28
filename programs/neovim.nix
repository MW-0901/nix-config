{ config, pkgs, ... }:

{
  programs.nvf = {
    enable = true;

    settings = {
      vim.theme.enable = true;
      vim.autocomplete.blink-cmp.enable = true;
      vim.treesitter.enable = true;
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


      vim.viAlias = true;
      vim.vimAlias = true;
      vim.lsp.enable = true;

      # Keymaps should be a list, not an attribute set
      vim.keymaps = [
        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<cr>";
        }
      ];

    };
  };
}
