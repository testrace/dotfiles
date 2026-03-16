local repo_root = (... and debug.getinfo(1, "S").source:sub(2):match("^(.*)/tests/")) or "."
package.path = repo_root .. "/hammerspoon/.hammerspoon/?.lua;" .. package.path

local hotkeys = {}
local printed = {}
local current_source = "com.apple.inputmethod.Korean.2SetKorean"
local key_strokes = {}

package.loaded["foundation_remapping"] = {
	new = function()
		return {
			remap = function(self)
				return self
			end,
			register = function(self)
				return self
			end,
		}
	end,
}

hs = {
	hotkey = {
		new = function(mods, key, callback)
			local binding = {
				mods = mods,
				key = key,
				callback = callback,
				enable = function(self)
					return self
				end,
				disable = function(self)
					return self
				end,
			}
			table.insert(hotkeys, binding)
			return binding
		end,
	},
	eventtap = {
		keyStroke = function(mods, key)
			table.insert(key_strokes, { mods = mods, key = key })
		end,
	},
	keycodes = {
		currentSourceID = function(source)
			if source ~= nil then
				current_source = source
			end
			return current_source
		end,
	},
}

print = function(...)
	local parts = {}
	for i = 1, select("#", ...) do
		parts[i] = tostring(select(i, ...))
	end
	table.insert(printed, table.concat(parts, "\t"))
end

dofile(repo_root .. "/hammerspoon/.hammerspoon/init.lua")

assert(type(print_input_source) == "function", "expected print_input_source helper")
assert(type(back_to_kor) == "function", "expected back_to_kor helper")

local source = print_input_source()

assert(source == "com.apple.inputmethod.Korean.2SetKorean", "expected helper to return current source id")
assert(#printed == 1, "expected helper to print once")
assert(printed[1] == "Current input source: com.apple.inputmethod.Korean.2SetKorean", "expected helper to print source id")

current_source = "com.apple.keylayout.ABC"
back_to_kor()
assert(current_source == "com.apple.inputmethod.Korean.2SetKorean", "expected back_to_kor to switch to Korean input")

local shift_escape_binding = nil
for _, binding in ipairs(hotkeys) do
	if #binding.mods == 1 and binding.mods[1] == "shift" and binding.key == "escape" then
		shift_escape_binding = binding
		break
	end
end

assert(shift_escape_binding ~= nil, "expected Shift+Escape binding to exist")

current_source = "com.apple.keylayout.ABC"
shift_escape_binding.callback()
assert(current_source == "com.apple.inputmethod.Korean.2SetKorean", "expected Shift+Escape to switch to Korean input")
assert(#key_strokes == 0, "expected Shift+Escape not to emit synthetic key events")
