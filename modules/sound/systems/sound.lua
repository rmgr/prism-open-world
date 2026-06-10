---@class SoundSystem : System
local SoundSystem = prism.System:extend("SoundSystem")

local WALK_BIT = nil
local FLY_BIT = nil
local SWIM_BIT = nil

local function initBitmasks()
	if not WALK_BIT then
		WALK_BIT = prism.Collision.createBitmaskFromMovetypes({ "walk" })
		FLY_BIT = prism.Collision.createBitmaskFromMovetypes({ "fly" })
		SWIM_BIT = prism.Collision.createBitmaskFromMovetypes({ "swim" })
	end
end
local levelWidth = 120 --Game.level_width

--- @param level Level
--- @param x integer
--- @param y integer
--- @return boolean
local function canTransmitSound(level, x, y)
	if not level:inBounds(x, y) then
		return false
	end

	local cell = level:getCell(x, y)
	if not cell then
		return false
	end

	local collider = cell:get(prism.components.Collider)
	if not collider then
		return false
	end

	local mask = collider:getMask()
	if not mask then
		return false
	end

	return bit.band(mask, WALK_BIT) == WALK_BIT
		or bit.band(mask, FLY_BIT) == FLY_BIT
		or bit.band(mask, SWIM_BIT) == SWIM_BIT
end
local function soundLOS(level, x0, y0, x1, y1, cache)
	local _, passable = prism.bresenham(x0, y0, x1, y1, function(x, y)
		local k = y * 120 + x
		local p = cache[k]
		if p == nil then
			p = canTransmitSound(level, x, y)
			cache[k] = p
		end
		return p
	end)
	return passable
end
--- @param level Level
function SoundSystem:propagateSound(level)
	local start = os.clock()
	local transmitCache = self._transmitCache or {}

	-- Collect active emitters this turn
	local emitters = {}
	local emitterCount = 0
	for emitter in level:query(prism.components.Sound):iter() do
		local sound = emitter:get(prism.components.Sound)
		if sound then
			emitter:remove(prism.components.Sound)
			local pos = emitter:getPosition()
			if pos then
				emitterCount = emitterCount + 1
				local ex, ey = pos:decompose()
				emitters[emitterCount] = { actor = emitter, x = ex, y = ey, vol = sound:getVolume() }
			end
		end
	end

	if emitterCount == 0 then
		return
	end

	-- For each listener, check each emitter directly
	for listener in level:query(prism.components.Hearing):iter() do
		local lpos = listener:getPosition()
		if lpos then
			local lx, ly = lpos:decompose()
			for i = 1, emitterCount do
				local e = emitters[i]
				if e.actor ~= listener then
					local dx = math.abs(e.x - lx)
					local dy = math.abs(e.y - ly)
					if dx <= e.vol and dy <= e.vol then
						if soundLOS(level, e.x, e.y, lx, ly, transmitCache) then
							listener:addRelation(prism.relations.HearsRelation, e.actor)
						end
					end
				end
			end
		end
	end
	local elapsed = os.clock() - start
	--print(elapsed)
end

--- @param level Level
--- @param actor Actor
function SoundSystem:onSenses(level, actor)
	if not actor:get(prism.components.Hearing) then
		return
	end

	local isPlayer = actor:has(prism.components.PlayerController)
	local heardRelations = actor:getRelations(prism.relations.HearsRelation)
	if not heardRelations then
		return
	end

	for emitter, _ in pairs(heardRelations) do
		---@cast emitter Actor
		if isPlayer and not actor:hasRelation(prism.relations.SeesRelation, emitter) then
			local x, y = emitter:getPosition():decompose()
			level:yield(prism.messages.AnimationMessage({
				animation = spectrum.animations.DistantSound(),
				x = x,
				y = y,
			}))
			local soundIcon = prism.actors.Sound()
			level:addActor(soundIcon, x, y)
			actor:addRelation(prism.relations.SensesRelation, soundIcon)
		else
			actor:addRelation(prism.relations.SensesRelation, emitter)
		end
	end
end

--- @param level Level
--- @param actor Actor
function SoundSystem:onTurn(level, actor)
	actor:removeAllRelations(prism.relations.HearsRelation)

	if actor:has(prism.components.PlayerController) then
		for icon in level:query(prism.components.SoundIcon):iter() do
			level:removeActor(icon)
		end
		initBitmasks()
		self:propagateSound(level)
	end
end

return SoundSystem
