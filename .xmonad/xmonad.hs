--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import qualified Data.Map as M
import Data.Maybe (fromJust)
import Data.Monoid
import System.Exit
import System.IO (hPutStrLn)
import XMonad
import XMonad.Hooks.DynamicLog (PP (..), dynamicLogWithPP, shorten, wrap, xmobarColor, xmobarPP)
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Spacing
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeys, additionalKeysP)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce

colorScheme = "nord"

colorBack = "#2E3440"

colorFore = "#D8DEE9"

color01 = "#343d46"

color02 = "#EC5f67"

color03 = "#99C794"

color04 = "#FAC863"

color05 = "#6699cc"

color06 = "#b874fc"

color07 = "#5fb3b3"

color08 = "#d8dee9"

color09 = "#666666"

color10 = "#EC5f67"

color11 = "#99C794"

color12 = "#FAC863"

color13 = "#6699cc"

color14 = "#c594c5"

color15 = "#5fb3b3"

color16 = "#d8dee9"

colorTrayer :: String
colorTrayer = "--tint 0x2E3440"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
      -- launch dmenu
      ((modm, xK_p), spawn "rofi -show drun"),
      -- launch gmrun
      ((modm .|. shiftMask, xK_p), spawn "gmrun"),
      -- close focused window
      ((modm .|. shiftMask, xK_c), kill),
      -- Rotate through the available layout algorithms
      ((modm, xK_space), sendMessage NextLayout),
      --  Reset the layouts on the current workspace to default
      ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),
      -- Resize viewed windows to the correct size
      ((modm, xK_n), refresh),
      -- Move focus to the next window
      ((modm, xK_Tab), windows W.focusDown),
      -- Move focus to the next window
      ((modm, xK_j), windows W.focusDown),
      -- Move focus to the previous window
      ((modm, xK_k), windows W.focusUp),
      -- Move focus to the master window
      ((modm, xK_m), windows W.focusMaster),
      -- Swap the focused window and the master window
      ((modm, xK_Return), windows W.swapMaster),
      -- Swap the focused window with the next window
      ((modm .|. shiftMask, xK_j), windows W.swapDown),
      -- Swap the focused window with the previous window
      ((modm .|. shiftMask, xK_k), windows W.swapUp),
      -- Shrink the master area
      ((modm, xK_h), sendMessage Shrink),
      -- Expand the master area
      ((modm, xK_l), sendMessage Expand),
      -- Push window back into tiling
      ((modm, xK_t), withFocused $ windows . W.sink),
      -- Increment the number of windows in the master area
      ((modm, xK_comma), sendMessage (IncMasterN 1)),
      -- Deincrement the number of windows in the master area
      ((modm, xK_period), sendMessage (IncMasterN (-1))),
      -- Toggle the status bar gap
      -- Use this binding with avoidStruts from Hooks.ManageDocks.
      -- See also the statusBar function from Hooks.DynamicLog.
      --
      -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

      -- Quit xmonad
      ((modm .|. shiftMask, xK_q), io exitSuccess),
      -- Restart xmonad
      ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")
    ]
      ++
      --
      -- mod-[1..9], Switch to workspace N
      -- mod-shift-[1..9], Move client to workspace N
      --
      [ ((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      ++
      --
      -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
      -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
      --
      [ ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0 ..],
          (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
      ]

myExtraKeys =
  [ ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +1.5%"),
    ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@  -1.5%"),
    ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle"),
    ("<XF86AudioPlay>", spawn "playerctl play-pause"),
    ("<XF86AudioPrev>", spawn "playerctl previous"),
    ("<XF86AudioNext>", spawn "playerctl next"),
    ("<XF86MonBrightnessUp>", spawn "light -A 5"),
    ("<XF86MonBrightnessDown>", spawn "light -U 5")
  ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1),
        \w ->
          focus w >> mouseMoveWindow w
            >> windows W.shiftMaster
      ),
      -- mod-button2, Raise the window to the top of the stack
      ((modm, button2), \w -> focus w >> windows W.shiftMaster),
      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm, button3),
        \w ->
          focus w >> mouseResizeWindow w
            >> windows W.shiftMaster
      )
      -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
gap = 4

myLayout =
  spacingRaw True (Border 0 0 0 0) True (Border gap gap gap gap) True $
    avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2

    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myWorkspaceIndices = M.fromList $ zip myWorkspaces [1 ..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
-- myStartupHook =

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  xmproc <- spawnPipe "xmobar $HOME/.config/xmobar/xmobar.conf"
  xmonad $
    docks
      def
        { terminal = "alacritty",
          modMask = mod4Mask,
          workspaces = myWorkspaces,
          -- normalBorderColor  = myNormalBorderColor,
          focusedBorderColor = color06,
          -- key bindings
          keys = myKeys,
          mouseBindings = myMouseBindings,
          -- hooks, layouts
          ----------------------
          layoutHook = myLayout,
          ----------------------
          -- Execute arbitrary actions and WindowSet manipulations when managing
          -- a new window. You can use this to, for example, always float a
          -- particular program, or have a client always appear on a particular
          -- workspace.
          --
          -- To find the property name associated with a program, use
          -- > xprop | grep WM_CLASS
          -- and click on the client you're interested in.
          --
          -- To match on the WM_NAME, you can use 'title' in the same way that
          -- 'className' and 'resource' are used below.
          manageHook =
            composeAll
              [ className =? "MPlayer" --> doFloat,
                className =? "Gimp" --> doFloat,
                className =? "pinentry-qt" --> doFloat,
                resource =? "desktop_window" --> doIgnore,
                resource =? "kdesktop" --> doIgnore
              ],
          ----------------------
          handleEventHook = mempty,
          ----------------------
          logHook =
            dynamicLogWithPP $
              xmobarPP
                { ppOutput = hPutStrLn xmproc, -- xmobar on monitor 1
                -- >> hPutStrLn xmproc1 x   -- xmobar on monitor 2
                -- >> hPutStrLn xmproc2 x   -- xmobar on monitor 3
                -- Current workspace
                  ppCurrent =
                    xmobarColor color06 ""
                      . wrap
                        ("<box type=Bottom width=2 mb=2 color=" ++ color06 ++ ">")
                        "</box>",
                  -- Visible but not current workspace
                  ppVisible = xmobarColor color06 "" . clickable,
                  -- Hidden workspace
                  ppHidden =
                    xmobarColor color05 ""
                      . wrap
                        ("<box type=Top width=2 mt=2 color=" ++ color05 ++ ">")
                        "</box>"
                      . clickable,
                  -- Hidden workspaces (no windows)
                  ppHiddenNoWindows = xmobarColor color05 "" . clickable,
                  -- Title of active window
                  ppTitle = xmobarColor color16 "" . shorten 60,
                  -- Separator character
                  ppSep = "<fc=" ++ color09 ++ "> | </fc>",
                  -- Urgent workspace
                  ppUrgent = xmobarColor color02 "" . wrap "!" "!",
                  -- Adding # of windows on current workspace to the bar
                  ppExtras = [windowCount],
                  -- order of things in xmobar
                  ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t]
                },
          ------------------
          startupHook = do
            spawnOnce "nitrogen --restore &"
            spawnOnce "picon &"
        }
      `additionalKeysP` myExtraKeys
