{ pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
  ];
  system.stateVersion = "22.11";
  nixpkgs.config.allowUnfree = true;
  services.minecraft-server = {
    enable = true;
    eula = true;
  };

  users = {
    users.minecraft.uid = 3818;
    groups.minecraft.gid = 3818;
  };
  environment.systemPackages = with pkgs; [
    neovim
    python3
    tmux
    git
  ];
}
