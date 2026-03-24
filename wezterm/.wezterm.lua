local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono")
config.font_size = 13.0
config.window_background_opacity = 1.0
config.enable_tab_bar = false
config.default_cursor_style = "BlinkingBlock"
config.front_end = "WebGpu"

config.colors = {
  background = "#2d333b",
  foreground = "#c9d1d9",
}

return config
