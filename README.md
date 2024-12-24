# My Hyprland Dotfiles using NixOS with Flakes
 
https://github.com/eekrain/dotfiles/assets/65037854/0ab88ce9-61cf-4ff5-a93c-8f528015451f

<p align="center">Rice <a href="https://end-4.github.io/dots-hyprland-wiki/en/" target="_blank">illogical-impulse</a> by <a href="https://github.com/end-4" target="_blank">end-4</a></p>

I am currently rocking end-4's illogical-impulse rice. So this is my attempt at porting it to NixOS.
This is my personal nix flake configuration. If you want to use it, you may need to make some adjustments.


## Installation

#### 1. Generate your hardware-configuration.nix

You need to get your auto generated hardware-configuration.nix. You can get detailed guide [here](https://nixos.wiki/wiki/NixOS_Installation_Guide).

#### 2. Adding your machine to nixos folder

You can clone / fork / use this repo. Then you need to make new entry on nixos folder. You can look at my machine configuration in nixos/vivobook-15.

#### 3. Adding user to nixos folder

You can use my file://nixos/eekrain.nix, rename and edit it to your user configuration.

#### 4. Adding user to home-manager folder

Here you can add user spesific home-manager configuration. You can use my file://./home-manager/eekrain.nix as a reference and edit it according to your needs. Especially comments with FIXME in it.<br/>
Here you can select or remove any program or configuration you want. Make sure your user file in nixos folder (e.g. nixos/eekrain.nix) imports this file. This will make it easy everytime you update system, home-manager also updating.

#### 5. Update flake.nix

After you add your own system configuration and user spesific configuration. Make sure to import it correctly in flake.nix. You can follow FIXME comments.

#### 6. Edit wallpaper initialization

I am using a simple script to set wallpaper with swww. I am only using this script as a workaround because I wanted to use a .gif wallpaper. To adjust how you want to apply wallpaper, you can head over to file://./modules/home-manager/illogical-impulse/default.nix then find comments with TODO.

#### 7. Edit hyprland configuration

To edit hyprland configuration, you can head over to modules/home-manager/illogical-impulse/dots/hyprland. Here you can edit keybinds, app startup, window rules, etc. 

#### 8. Install to your system

After all configuration above you can try to install your modified flake to your system. Make sure you have followed the guide [here](https://nixos.wiki/wiki/NixOS_Installation_Guide) and have been mounting target disk installation. Then run:
```bash
sudo nixos-install --flake ./path/to/flake/dotfiles#your-machine-hostname
```

#### 9. Init illogical-impulse dotfiles

After the installation complete, when you boot up and on SDDM login screen, attempt to login via CLI instead (Ctrl+Alt+F4). Because the rice of illogical-impulse is not manageable with home-manager (especially the ags config), you need to initialize dots config manually. I have added a script to copy the dots configuration, you need to run it every update to modules/home-manager/illogical-impulse/dots to synchronize it. You can run:

```bash
init-illogical-impulse
```

And then if everything is working, Hyprland instance will ran.