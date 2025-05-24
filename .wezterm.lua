local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_size = 16
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.automatically_reload_config = true
config.enable_tab_bar = false
--config.window_decorations = "RESIZE"
config.adjust_window_size_when_changing_font_size = false
config.harfbuzz_features = { "calt=0" }
config.max_fps = 144
config.animation_fps  = 144
config.front_end = "OpenGL"
config.prefer_egl = true
config.enable_kitty_graphics = true
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 12
config.audible_bell = "Disabled"


config.window_padding = {
	left = 18,
	right = 15,
	top = 20,
	bottom = 5,
}

-- Key bindings delete word
config.keys = {
	{
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action({ SendString = "\x1bb" }),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action({ SendString = "\x1bf" }),
	},
}

-- Configs
-- Add Custom Color Scheme
--config.color_scheme = "Rosé Pine"

-- Rosé Pine Config
config.colors = {
  foreground = "#e0def4",
  background = "#191724",
  cursor_bg = "#e0def4",
  cursor_border = "#e0def4",
  cursor_fg = "#191724",
  selection_bg = "#403d52",
  selection_fg = "#e0def4",

  ansi = {
    "#26233a", -- black
    "#eb6f92", -- red
    "#31748f", -- green
    "#f6c177", -- yellow
    "#9ccfd8", -- blue
    "#c4a7e7", -- magenta
    "#ebbcba", -- cyan
    "#e0def4", -- white
  },
  brights = {
    "#6e6a86", -- bright black
    "#eb6f92", -- bright red
    "#31748f", -- bright green
    "#f6c177", -- bright yellow
    "#9ccfd8", -- bright blue
    "#c4a7e7", -- bright magenta
    "#ebbcba", -- bright cyan
    "#e0def4", -- bright white
  },
}


--config.colors = {
--	foreground = "#CBE0F0",
--		background = "#011423",
--		cursor_bg = "#47FF9C",
--		cursor_border = "#47FF9C",
--		cursor_fg = "#011423",
--		selection_bg = "#033259",
--		selection_fg = "#CBE0F0",
--		ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
--		brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
--}

return config
