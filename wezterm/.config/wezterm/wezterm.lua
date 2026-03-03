local wezterm = require 'wezterm'
local config = {}

-- 폰트
config.font = wezterm.font_with_fallback({
  'JetBrainsMono Nerd Font',
  'Sarasa Term K',
})
config.font_size = 14

-- 색상
config.color_scheme = 'Tokyo Night'

-- 윈도우
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- 탭바 숨김
config.enable_tab_bar = false

-- 기타
-- 오타 등 시스템 비프음, 'SystemBeep', 'Disalbed'
config.audible_bell = 'SystemBeep'

return config
