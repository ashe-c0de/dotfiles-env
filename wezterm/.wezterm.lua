local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono")
config.font_size = 13.0
config.window_background_opacity = 1.0

-- tab
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- cursor & rendering
config.default_cursor_style = "BlinkingBlock"
config.front_end = "WebGpu"

config.colors = {
  background = "#2d333b",
  foreground = "#c9d1d9",
}

config.keys = {
  {
    key = "v",
    mods = "ALT",
    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
  },
  {
    key = "h",
    mods = "ALT",
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    key = "x",
    mods = "ALT",
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
}

return config
