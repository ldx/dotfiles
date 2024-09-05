import Graphics.X11.ExtraTypes.XF86
import System.IO
import XMonad
import Data.Ratio -- this makes the '%' operator available (optional)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.Grid
import XMonad.Layout.MultiColumns
import XMonad.Layout.Spiral
import XMonad.Layout.Spacing

myLayouts = spacing 5 $
            layoutTall ||| layoutMultiColumns ||| layoutSpiral ||| layoutGrid ||| layoutMirror ||| layoutFull
    where
      layoutTall = Tall 1 (3/100) (1/2)
      layoutMultiColumns = multiCol [1] 1 0.01 (-0.5)
      layoutSpiral = spiral (125 % 146)
      layoutGrid = Grid
      layoutMirror = Mirror (Tall 1 (3/100) (3/5))
      layoutFull = Full

myManageHook = composeAll
    [ className =? "Vncviewer" --> doShift "5"
    , className =? "Gimp" --> doShift "6"
    , className =? "Slack" --> doShift "7"
    , className =? "Google-chrome" --> doShift "8"
    , className =? "firefox" --> doShift "8"
    , className =? "trayer" --> doShift "9"
    ]

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar $HOME/.xmobarrc"
    xmonad $ defaultConfig
        { manageHook = manageDocks  <+> myManageHook <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  myLayouts
        , handleEventHook = handleEventHook defaultConfig <+> docksEventHook
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , terminal           = "xterm"
        } `additionalKeys`
        [ ((mod1Mask .|. shiftMask, xK_o), spawn "light-locker-command -l")
        , ((mod1Mask .|. shiftMask, xK_s), spawn "sudo pm-suspend")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        , ((0, xF86XK_AudioMute), spawn "$HOME/bin/pa-control mute")
        , ((0, xF86XK_AudioLowerVolume), spawn "$HOME/bin/pa-control down")
        , ((0, xF86XK_AudioRaiseVolume), spawn "$HOME/bin/pa-control up")
        , ((0, xF86XK_MonBrightnessDown), spawn "$HOME/bin/brightness-control down")
        , ((0, xF86XK_MonBrightnessUp), spawn "$HOME/bin/brightness-control up")
        ]
