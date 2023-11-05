{ config, pkgs, ... }:
{
  home.packages = [ pkgs.ferdium ];

  xdg.desktopEntries = {
    ferdium = {
      name = "Ferdium";
      genericName = "Web Browser";
      exec = "ferdium  --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations %U";
      type = "Application";
      icon = "ferdium";
      comment = ''Ferdium is your messaging app / former heir to the throne of Austria-Hungary and combines chat & messaging services into one application. Ferdium currently supports Slack, WhatsApp, Gmail, Facebook Messenger, Telegram, Google Hangouts, GroupMe, Skype and many more. You can download Ferdium for free for Mac, Windows, and Linux. For enabling webcam access you need to connect " camera " plug to snap, and for microphone with PulseAudio - " audio-record " plug. This can be done in Snap GUI or via command: `snap connect ferdium:camera; snap connect ferdium:audio-record`.'';
      settings = {
        StartupWMClass = "Ferdium";
        MimeType = "x-scheme-handler/ferdium;";
        Categories = "Network;InstantMessaging;";
      };
    };
  };
}
