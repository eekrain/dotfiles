{ config, lib, pkgs, ... }:
{
  android-sdk.enable = true;

  android-sdk.packages = sdk: with sdk; [
    # Useful packages for building and testing.
    build-tools-29-0-2
    build-tools-30-0-3
    cmdline-tools-latest
    emulator
    platform-tools
    platforms-android-29

    # Other useful packages for a development environment.
    sources-android-29
    system-images-android-29-google-apis-x86-64
    patcher-v4
    tools
  ];

  home = {
    packages = [
      pkgs.jdk11
      pkgs.androidStudioPackages.stable
    ];

    sessionVariables = {
      JAVA_HOME = "${pkgs.jdk11.home}";
      ANDROID_JAVA_HOME = "${pkgs.jdk11.home}";
      USE_CCACHE = "1";
    };
  };
}
