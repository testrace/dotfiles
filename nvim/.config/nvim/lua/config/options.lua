-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 행번호 설정
vim.opt.number = true -- 절대 행번호 표시
vim.opt.relativenumber = true -- 상대 행번호 표시

-- 시스템 클립보드
vim.opt.clipboard = "unnamedplus"

-- 복사는 OSC 52로 터미널에 보낸다. 원격(herdr 머신, SSH)에서 열어도 지금 보고 있는 기기의 클립보드에 들어간다.
-- 붙여넣기는 nvim 내부 레지스터를 쓴다. OSC 52로 클립보드를 읽으면 터미널이 매번 허용을 묻기 때문이다.
-- 다른 곳에서 복사한 글은 터미널 붙여넣기(⌘V)로 넣는다.
local osc52 = require("vim.ui.clipboard.osc52")
local function paste()
  return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end
vim.g.clipboard = {
  name = "OSC 52",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = paste, ["*"] = paste },
}
