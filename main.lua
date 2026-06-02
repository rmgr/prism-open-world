require("debugger")
require("prism")

prism.loadModule("prism/spectrum")
prism.loadModule("prism/geometer")
prism.loadModule("prism/extra/sight")
prism.loadModule("prism/extra/log")
prism.loadModule("modules/faction")
prism.loadModule("modules/scent")
prism.loadModule("modules/sound")
prism.loadModule("modules/fireandsmoke")
prism.loadModule("prism/extra/condition")
prism.loadModule("prism/extra/inventory")
prism.loadModule("prism/extra/equipment")
prism.loadModule("prism/extra/droptable")

prism.loadModule("modules/base")
prism.loadModule("modules/game")
prism.loadModule("modules/levelgen")

require("util.constants")

require("game")

-- Used by Geometer for new maps
prism.defaultCell = prism.cells.Pit

-- Load a sprite atlas and configure the terminal-style display,
love.graphics.setDefaultFilter("nearest", "nearest")
love.setDeprecationOutput(false)
local spriteAtlas = spectrum.SpriteAtlas.fromASCIIGrid("display/wanderlust_16x16.png", 16, 16)
local display = spectrum.Display(81, 41, spriteAtlas, prism.Vector2(16, 16))

-- Automatically size the window to match the terminal dimensions
display:fitWindowToTerminal()

-- spin up our state machine
--- @type GameStateManager
local manager = spectrum.StateManager()

love.keyboard.setKeyRepeat(true)
-- we put out levelstate on top here, but you could create a main menu
--- @diagnostic disable-next-line
function love.load(args)
	manager:push(spectrum.gamestates.GameMenuState(display))

	manager:hook()
	spectrum.Input:hook()
end

function love.quit()
	if Game.lost then
		love.filesystem.remove("save.lz4")
		return
	end
	local save = Game:serialize()
	local mp = prism.messagepack.pack(save)
	local lz = love.data.compress("string", "lz4", mp)
	love.filesystem.write("save.lz4", lz)
end
