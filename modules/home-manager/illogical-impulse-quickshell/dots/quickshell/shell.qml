//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import "./ii/modules/common/"
import "./ii/modules/background/"
import "./ii/modules/bar/"
import "./ii/modules/cheatsheet/"
import "./ii/modules/crosshair/"
import "./ii/modules/dock/"
import "./ii/modules/lock/"
import "./ii/modules/mediaControls/"
import "./ii/modules/notificationPopup/"
import "./ii/modules/onScreenDisplay/"
import "./ii/modules/onScreenKeyboard/"
import "./ii/modules/overview/"
import "./ii/modules/screenCorners/"
import "./ii/modules/sessionScreen/"
import "./ii/modules/sidebarLeft/"
import "./ii/modules/sidebarRight/"
import "./ii/modules/verticalBar/"
import "./ii/modules/wallpaperSelector/"

import QtQuick
import QtQuick.Window
import Quickshell
import "./ii/services/"

ShellRoot {
    // Enable/disable modules here. False = not loaded at all, so rest assured
    // no unnecessary stuff will take up memory if you decide to only use, say, the overview.
    property bool enableBar: true
    property bool enableBackground: true
    property bool enableCheatsheet: true
    property bool enableCrosshair: true
    property bool enableDock: true
    property bool enableLock: true
    property bool enableMediaControls: true
    property bool enableNotificationPopup: true
    property bool enableOnScreenDisplayBrightness: true
    property bool enableOnScreenDisplayVolume: true
    property bool enableOnScreenKeyboard: true
    property bool enableOverview: true
    property bool enableReloadPopup: true
    property bool enableScreenCorners: true
    property bool enableSessionScreen: true
    property bool enableSidebarLeft: true
    property bool enableSidebarRight: true
    property bool enableVerticalBar: true
    property bool enableWallpaperSelector: true

    // Force initialization of some singletons
    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Hyprsunset.load()
        FirstRunExperience.load()
        ConflictKiller.load()
        Cliphist.refresh()
        Wallpapers.load()
    }

    LazyLoader { active: enableBar && Config.ready && !Config.options.bar.vertical; component: Bar {} }
    LazyLoader { active: enableBackground; component: Background {} }
    LazyLoader { active: enableCheatsheet; component: Cheatsheet {} }
    LazyLoader { active: enableCrosshair; component: Crosshair {} }
    LazyLoader { active: enableDock && Config.options.dock.enable; component: Dock {} }
    LazyLoader { active: enableLock; component: Lock {} }
    LazyLoader { active: enableMediaControls; component: MediaControls {} }
    LazyLoader { active: enableNotificationPopup; component: NotificationPopup {} }
    LazyLoader { active: enableOnScreenDisplayBrightness; component: OnScreenDisplayBrightness {} }
    LazyLoader { active: enableOnScreenDisplayVolume; component: OnScreenDisplayVolume {} }
    LazyLoader { active: enableOnScreenKeyboard; component: OnScreenKeyboard {} }
    LazyLoader { active: enableOverview; component: Overview {} }
    LazyLoader { active: enableReloadPopup; component: ReloadPopup {} }
    LazyLoader { active: enableScreenCorners; component: ScreenCorners {} }
    LazyLoader { active: enableSessionScreen; component: SessionScreen {} }
    LazyLoader { active: enableSidebarLeft; component: SidebarLeft {} }
    LazyLoader { active: enableSidebarRight; component: SidebarRight {} }
    LazyLoader { active: enableVerticalBar && Config.ready && Config.options.bar.vertical; component: VerticalBar {} }
    LazyLoader { active: enableWallpaperSelector; component: WallpaperSelector {} }
}