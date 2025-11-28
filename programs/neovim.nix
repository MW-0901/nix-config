{ config, pkgs, ... }:

{
  programs.nvf = {
    enable = true;
    
    settings = {
      vim.theme.enable = true;

      vim.treesitter.enable = true;

      vim.lsp.enable = true;
      
      vim.languages.nix.enable = true;
      
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
