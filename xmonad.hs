import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import Graphics.X11.ExtraTypes.XF86
import Data.IORef

main = do
    xmproc <- spawnPipe "xmobar"
    capture <- newIORef False
    let 
	mic True = spawn "amixer set Capture 0"
	mic False = spawn "amixer set Capture 40"
	toggleMic = do
		t <- not <$> readIORef capture
		writeIORef capture t
		mic t
    xmonad $ def
        { manageHook = manageDocks <+> manageHook def
        , layoutHook = avoidStruts  $  layoutHook def
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock; xset dpms force off")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
	, ((0, xF86XK_AudioLowerVolume   ), spawn "amixer set Master 2-")
	, ((0, xF86XK_AudioRaiseVolume   ), spawn "amixer set Master 2+")
	, ((0, xF86XK_AudioMute          ), spawn "amixer set Master toggle; amixer set Speaker toggle")
	, ((0, xF86XK_AudioMicMute          ),spawn "amixer set Capture toggle") 
        ]

