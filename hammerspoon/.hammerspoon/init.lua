local FRemap = require("foundation_remapping")
local remapper = FRemap.new()
remapper:remap("rcmd", "f18")
remapper:register()

local inputEnglish = "com.apple.keylayout.ABC"
local inputKorean = "com.apple.inputmethod.Korean.2SetKorean"
local esc_bind
local shift_esc_bind

function print_input_source()
	local inputSource = hs.keycodes.currentSourceID()
	print("Current input source: " .. tostring(inputSource))
	return inputSource
end

function back_to_kor()
	hs.keycodes.currentSourceID(inputKorean)
end

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
shift_esc_bind = hs.hotkey.new({ "shift" }, "escape", back_to_kor):enable()
