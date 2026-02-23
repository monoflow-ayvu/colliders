{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [
    git 
  ];

  languages = {
    elixir.enable = true;
  };
}
