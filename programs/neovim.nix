{ config, pkgs, ... }:

{
  programs.nvf = {
    enable = true;
    
    settings = {
      vim.theme.enable = true;

      vim.treesitter.enable = true;

      vim.lsp.enable = true;
      
      vim.languages.nix.enable = true;
      
      vim.keymaps.telescope-find-files = {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
      };

    };
  };
}
