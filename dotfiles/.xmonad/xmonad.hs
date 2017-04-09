import Graphics.X11.ExtraTypes.XF86
import System.IO
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)

myManageHook = composeAll
    [ className =? "Vncviewer" --> doShift "5"
    , className =? "Gimp" --> doShift "6"
    , className =? "Google-chrome" --> doShift "7"
    , className =? "Firefox" --> doShift "8"
    , className =? "Firefox-esr" --> doShift "8"
    , className =? "trayer" --> doShift "9"
    , className =? "Skype" --> doShift "9"
    ]

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar $HOME/.xmobarrc"
    xmonad $ defaultConfig
        { manageHook = manageDocks  <+> myManageHook <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , terminal           = "xterm"
        } `additionalKeys`
        [ ((mod1Mask .|. shiftMask, xK_o), spawn "xscreensaver-command -lock")
        , ((mod1Mask .|. shiftMask, xK_s), spawn "sudo pm-suspend")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        , ((0, xF86XK_AudioMute), spawn "$HOME/.local/bin/pa-control mute")
        , ((0, xF86XK_AudioLowerVolume), spawn "$HOME/.local/bin/pa-control down")
        , ((0, xF86XK_AudioRaiseVolume), spawn "$HOME/.local/bin/pa-control up")
        , ((0, xF86XK_MonBrightnessDown), spawn "$HOME/.local/bin/brightness-control down")
        , ((0, xF86XK_MonBrightnessUp), spawn "$HOME/.local/bin/brightness-control up")
        ]
