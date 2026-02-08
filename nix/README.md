# Nix Configuration

This repository manages the configuration for my macOS and NixOS infrastructure using [Nix Flakes](https://nixos.wiki/wiki/Flakes), [Home Manager](https://github.com/nix-community/home-manager), and [Colmena](https://github.com/zhaofengli/colmena).

## 📂 Project Structure

- **`flake.nix`**: The entry point defining inputs (dependencies) and outputs (systems).
- **`hosts/`**: System-specific configurations for macOS (`mac`) and NixOS servers (`ca-media`, etc.).
- **`modules/`**: Shared system configuration modules and raw dotfiles (like `zshrc`).
- **`users/`**: Home Manager configurations.
    - **`steven/`**: User configuration including shell, git, and packages.

## 🚀 Deployment

### macOS
To apply changes to the local Mac:
```bash
darwin-rebuild switch --flake .#mac
```

### Linux Servers (NixOS)
This project uses **Colmena** for remote deployment.

**Apply to all servers:**
```bash
colmena apply --reboot
```

**Apply to a specific server:**
```bash
colmena apply --reboot --on ca-media
```

**Apply only local Home Manager changes (if running locally on Linux):**
```bash
home-manager switch --flake .#steven@<hostname>
```

## 🛠 Integrations

### Neovim
Neovim configuration is pulled directly from an external Git repository defined as a flake input (`my-nvim-config`).

**To update Neovim config to the latest commit:**
```bash
nix flake update my-nvim-config
darwin-rebuild switch --flake .#mac  # or colmena apply
```

### Zsh & Shell
- **Zsh**: Managed by Home Manager (`users/steven/zsh.nix`).
- **Config**: Sources the legacy `modules/files/zshrc` file. This allows maintaining a single `zshrc` that can be copied to non-Nix systems if needed.
- **Powerlevel10k**: Configured via `modules/files/p10k.zsh`.
- **Atuin**: Configured via `modules/files/atuin.toml` and linked by Home Manager.

### Adding a New Package
1.  **System-wide (Root)**: Add to `modules/shared.nix` (for all machines) or the specific host file in `hosts/<hostname>/default.nix`.
2.  **User-specific (Home - All Systems)**: Add to `home.packages` in `users/steven/default.nix`.
3.  **User-specific (Home - System-specific)**:
    *   **Via Conditionals**: In `users/steven/default.nix`, use `lib.mkIf pkgs.stdenv.isDarwin [ ... ]` or `pkgs.stdenv.isLinux`.
    *   **Via Host Override**: In `hosts/<hostname>/default.nix`, you can add:
        ```nix
        home-manager.users.steven.home.packages = with pkgs; [ some-package ];
        ```

## 🆕 Adding a New Host

1.  **Boot the NixOS Installer**: Partition and mount your disks to `/mnt`.
2.  **Generate Hardware Config**: 
    ```bash
    nixos-generate-config --root /mnt
    ```
3.  **Create Host Directory**:
    *   Create `hosts/<hostname>/`.
    *   Move the generated `hardware-configuration.nix` there.
    *   Create a `default.nix` importing shared modules and setting `networking.hostName`.
4.  **Register in `flake.nix`**:
    *   Add the host to `colmenaHive`.
    *   Include `home-manager.nixosModules.home-manager` and `hmConfig` if you want user config.
    *   Set `deployment.targetHost` to the target's IP.
5.  **Initial Bootstrap (Manual nixos-install)**:
    1.  Boot the installer on the target machine.
    2.  Mount partitions to `/mnt` (and `/mnt/boot`).
    3.  Copy this config to the installer (e.g., `scp -r . root@<target-ip>:/mnt/etc/nixos/config`).
    4.  Run the installation:
        ```bash
        nixos-install --flake /mnt/etc/nixos/config#<hostname>
        ```
    5.  Reboot.
6.  **Deploy**:
    ```bash
    colmena apply --on <hostname>
    ```
