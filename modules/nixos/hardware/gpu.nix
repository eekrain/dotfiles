{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.hardware;
in
{
  imports = [
    inputs.hardware.nixosModules.common-gpu-amd
  ];

  config = mkMerge [
    # If it's only using amd, implement spesific configuration
    (mkIf (cfg.gpu == "amd") {
      services.xserver.videoDrivers = mkDefault [ "amdgpu" ];

      hardware = {
        amdgpu.loadInInitrd = true;
        opengl.extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
        ];
      };

      # Adding libva driver env vars for amdgpu only
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "radeonsi";
        VDPAU_DRIVER = "radeonsi";
      };
    })

    # If it's only using amd, implementing disable nvidia for better battery life
    (mkIf (cfg.gpu == "amd") {
      # This runs only intel/amdgpu igpus and nvidia dgpus do not drain power.
      ##### disable nvidia, very nice battery life.
      boot.extraModprobeConfig = ''
        blacklist nouveau
        options nouveau modeset=0
      '';

      services.udev.extraRules = ''
        # Remove NVIDIA USB xHCI Host Controller devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

        # Remove NVIDIA USB Type-C UCSI devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

        # Remove NVIDIA Audio devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

        # Remove NVIDIA VGA/3D controller devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';
      boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
    })

    # With NVIDIA driver
    (mkIf (cfg.gpu == "nvidia") {
      boot.blacklistedKernelModules = [ "nouveau" ];
      services.xserver.videoDrivers = mkDefault [ "amdgpu" "nvidia" ];

      hardware = {
        amdgpu.loadInInitrd = true;
        opengl.extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
          nvidia-vaapi-driver
        ];

        nvidia = {
          # Using beta driver
          package = config.boot.kernelPackages.nvidiaPackages.beta;
          # Open drivers (NVreg_OpenRmEnableUnsupportedGpus=1)
          open = false;
          # Install nvidia settings app
          nvidiaSettings = true;
          # nvidia-drm.modeset=1
          modesetting.enable = true;
          # Power management setting, vivobook pro 15 is using nvidia rtx 3050
          # My device dont have problem setting powermanagement to true
          # if ur device isnt running well, set powerManagement value below to be false
          powerManagement.enable = true;
          powerManagement.finegrained = true;

          # Nvidia PRIME settings
          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
            amdgpuBusId = "PCI:4:0:0";
            nvidiaBusId = "PCI:1:0:0";
          };
        };
      };

      # If it's using nvidia, implement spesific sessionVariables
      environment.sessionVariables = {
        GBM_BACKEND = "nvidia-drm"; #on my laptop, wayland crashed using this env
        LIBVA_DRIVER_NAME = "nvidia"; # hardware acceleration
        # WLR_RENDERER = "vulkan";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __GL_VRR_ALLOWED = "0";
        WLR_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1";
        WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
      };
    })
  ];
}
