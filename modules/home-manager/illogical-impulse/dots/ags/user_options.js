// For every option, see ~/.config/ags/modules/.configuration/user_options.js
// (vscode users ctrl+click this: file://./modules/.configuration/user_options.js)
// (vim users: `:vsp` to split window, move cursor to this path, press `gf`. `Ctrl-w` twice to switch between)
//   options listed in this file will override the default ones in the above file

const userConfigOptions = {
    'brightness': {
        'controllers': {
            // can be "light" | "brighnessctl" | "ddcutil"
            // for no multi monitor use i recommend light, cus the other is not saving brightness value
            // when we turning on display after calling "hyprctl dispatch dpms off"
            'default': "light", 
        },
    },
}

export default userConfigOptions;
