pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string filePath: Directories.shellConfigPath
    property alias options: configOptionsJsonAdapter
    property bool ready: true

    JsonAdapter {
        id: configOptionsJsonAdapter
        
        property JsonObject policies: JsonObject {
            property int ai: 1
            property int weeb: 1
        }

        property JsonObject ai: JsonObject {
            property string systemPrompt: "## Style\n- Use casual tone, don't be formal! Make sure you answer precisely without hallucination and prefer bullet points over walls of text. You can have a friendly greeting at the beginning of the conversation, but don't repeat the user's question\n\n## Context (ignore when irrelevant)\n- You are a helpful and inspiring sidebar assistant on a NixOS Linux system\n- Desktop environment: Hyprland + dots-hyprland\n- Current date & time: {DATETIME}\n- Focused app: {WINDOWCLASS}\n\n## Presentation\n- Use Markdown features in your response"
            property string tool: "functions"
            property list<var> extraModels: []
        }

        property JsonObject appearance: JsonObject {
            property bool extraBackgroundTint: true
            property int fakeScreenRounding: 2
            property bool transparency: true
            property JsonObject wallpaperTheming: JsonObject {
                property bool enableAppsAndShell: true
                property bool enableQtApps: true
                property bool enableTerminal: true
            }
            property JsonObject palette: JsonObject {
                property string type: "auto"
            }
        }

        property JsonObject audio: JsonObject {
            property JsonObject protection: JsonObject {
                property bool enable: true
                property real maxAllowedIncrease: 10
                property real maxAllowed: 90
            }
        }

        property JsonObject apps: JsonObject {
            property string bluetooth: "kcmshell6 kcm_bluetooth"
            property string network: "plasmawindowed org.kde.plasma.networkmanagement"
            property string networkEthernet: "kcmshell6 kcm_networkmanagement"
            property string taskManager: "plasma-systemmonitor --page-name Processes"
            property string terminal: "foot"
        }

        property JsonObject background: JsonObject {
            property bool fixedClockPosition: false
            property real clockX: -500
            property real clockY: -500
            property string wallpaperPath: ""
            property string thumbnailPath: ""
            property JsonObject parallax: JsonObject {
                property bool enableWorkspace: true
                property real workspaceZoom: 1.07
                property bool enableSidebar: true
            }
        }
        
        property JsonObject bar: JsonObject {
            property bool bottom: false
            property int cornerStyle: 1
            property bool borderless: false
            property string topLeftIcon: "spark"
            property bool showBackground: true
            property bool verbose: true
            property JsonObject resources: JsonObject {
                property bool alwaysShowSwap: true
                property bool alwaysShowCpu: false
            }
            property list<string> screenList: []
            property JsonObject utilButtons: JsonObject {
                property bool showScreenSnip: true
                property bool showColorPicker: true
                property bool showMicToggle: true
                property bool showKeyboardToggle: true
                property bool showDarkModeToggle: true
                property bool showPerformanceProfileToggle: false
            }
            property JsonObject tray: JsonObject {
                property bool monochromeIcons: true
            }
            property JsonObject workspaces: JsonObject {
                property bool monochromeIcons: true
                property int shown: 10
                property bool showAppIcons: true
                property bool alwaysShowNumbers: true
                property int showNumberDelay: 100
            }
            property JsonObject weather: JsonObject {
                property bool enable: false
                property bool enableGPS: true
                property string city: ""
                property bool useUSCS: false
                property int fetchInterval: 10
            }
        }
        
        property JsonObject battery: JsonObject {
            property int low: 25
            property int critical: 10
            property bool automaticSuspend: true
            property int suspend: 5
        }

        property JsonObject dock: JsonObject {
            property bool enable: false
            property bool monochromeIcons: true
            property real height: 60
            property real hoverRegionHeight: 2
            property bool pinnedOnStartup: false
            property bool hoverToReveal: true
            property list<string> pinnedApps: ["org.kde.dolphin", "foot"]
            property list<string> ignoredAppRegexes: []
        }

        property JsonObject language: JsonObject {
            property JsonObject translator: JsonObject {
                property string engine: "auto"
                property string targetLanguage: "auto"
                property string sourceLanguage: "auto"
            }
        }

        property JsonObject light: JsonObject {
            property JsonObject night: JsonObject {
                property bool automatic: true
                property string from: "19:00"
                property string to: "06:30"
                property int colorTemperature: 5000
            }
        }

        property JsonObject networking: JsonObject {
            property string userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
        }

        property JsonObject osd: JsonObject {
            property int timeout: 1000
        }

        property JsonObject osk: JsonObject {
            property string layout: "qwerty_full"
            property bool pinnedOnStartup: false
        }

        property JsonObject overview: JsonObject {
            property bool enable: true
            property real scale: 0.18
            property real rows: 2
            property real columns: 5
        }

        property JsonObject resources: JsonObject {
            property int updateInterval: 3000
        }

        property JsonObject search: JsonObject {
            property int nonAppResultDelay: 30
            property string engineBaseUrl: "https://www.google.com/search?q="
            property list<string> excludedSites: ["quora.com"]
            property bool sloppy: false
            property JsonObject prefix: JsonObject {
                property string action: "/"
                property string clipboard: ";"
                property string emojis: ":"
            }
        }

        property JsonObject sidebar: JsonObject {
            property bool keepRightSidebarLoaded: true
            property JsonObject translator: JsonObject {
                property int delay: 300
            }
            property JsonObject booru: JsonObject {
                property bool allowNsfw: false
                property string defaultProvider: "yandere"
                property int limit: 20
                property JsonObject zerochan: JsonObject {
                    property string username: "[unset]"
                }
            }
        }
        
        property JsonObject time: JsonObject {
            property string format: "HH:mm:ss"
            property string dateFormat: "dddd, MMMM dd, yyyy"
        }

        property JsonObject windows: JsonObject {
            property bool showTitlebar: true
            property bool centerTitle: true
        }

        property JsonObject hacks: JsonObject {
            property int arbitraryRaceConditionDelay: 20
        }

        property JsonObject screenshotTool: JsonObject {
            property bool showContentRegions: true
        }
    }
}