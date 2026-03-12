local FRemap = require("foundation_remapping")
local remapper = FRemap.new()
remapper:remap("rcmd", "f18")
remapper:register()

local inputEnglish = "com.apple.keylayout.ABC"
local esc_bind

function back_to_eng()
	local inputSource = hs.keycodes.currentSourceID()
	if not (inputSource == inputEnglish) then
		hs.eventtap.keyStroke({}, "right")
		hs.keycodes.currentSourceID(inputEnglish)
	end
	esc_bind:disable()
	hs.eventtap.keyStroke({}, "escape")
	esc_bind:enable()
end

esc_bind = hs.hotkey.new({}, "escape", back_to_eng):enable()
