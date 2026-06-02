local utf8 = require("utf8")
local controls = require("controls")

--- @class InventoryState : GameState
--- @overload fun(display: Display, display: Display, decision: ActionDecision, level: Level, inventory: Inventory, equipper: Equipper)
local InventoryState = spectrum.GameState:extend("InventoryState")

local hud = love.graphics.newImage("display/hud.png")
local selected = love.graphics.newImage("display/selected_inventory.png")
--- @param display Display
--- @param decision ActionDecision
--- @param level Level
--- @param inventory Inventory
--- @param equipper Equipper
function InventoryState:__new(display, decision, level, inventory, equipper)
	self.display = display
	self.decision = decision
	self.level = level
	self.inventory = inventory
	self.equipper = equipper
	self.items = inventory.inventory:getAllActors()

	self.equipment = {}

	for i, slot in ipairs(equipper.slots or {}) do
		self.equipment[i] = {
			slot = slot.name,
			actor = equipper:get(slot.name),
		}
	end

	-- Calculate HUD dimensions in grid cells (accounting for scale of 2)
	local hudWidthInCells = hud:getWidth() / (display.cellSize.x / 1)
	local hudHeightInCells = hud:getHeight() / (display.cellSize.y / 1)

	-- Center in the display grid
	local centerGridX = (display.width - hudWidthInCells) / 2
	local centerGridY = (display.height - hudHeightInCells) / 2

	-- Convert back to pixels for drawing
	self.hudPosition = prism.Vector2(centerGridX * (display.cellSize.x / 2), centerGridY * (display.cellSize.y / 2))

	self.hudPositions = {}

	self.equipPositions = {
		hand = prism.Vector2(54, 5),
		armour = prism.Vector2(58, 5),
	}
	self.selectedPosition = 1
	local idx = 1
	for y = 0, 4 do
		for x = 0, 4 do
			self.hudPositions[idx] = prism.Vector2(4 + (4 * x), 5 + (4 * y))
			idx = idx + 1
		end
	end
	self.hudPositions[26] = self.equipPositions.hand
	self.hudPositions[27] = self.equipPositions.armour
	self.letters = {}
	for i = 1, #self.items do
		self.letters[i] = utf8.char(96 + i) -- a, b, c, ...
	end
end

function InventoryState:pixelToGrid(px, py)
	local dx = px / (self.display.cellSize.x / 1)
	local dy = py / (self.display.cellSize.y / 1)
	return math.floor(dx + 1), math.floor(dy + 1)
end

function InventoryState:gridToPixel(x, y)
	local dx = x - 1
	local dy = y - 1
	return dx * (self.display.cellSize.x / 1), dy * (self.display.cellSize.y / 1)
end

function InventoryState:load(previous)
	self.previousState = previous
end
function InventoryState:draw()
	self.previousState:draw()
	self.display:clear()

	self:drawHudBackground()
	self:drawCursorSelection()
	self:drawInventoryTitle()
	self:drawPlayerStats()
	self:drawSelectedItemInfo()
	self:drawInventoryItems()
	self:drawEquippedItems()

	self.display:draw()
end

function InventoryState:drawHudBackground()
	love.graphics.push()
	love.graphics.draw(hud, self.hudPosition.x, self.hudPosition.y)
	love.graphics.pop()
end

function InventoryState:drawCursorSelection()
	love.graphics.push()
	local pos = self.hudPositions[self.selectedPosition]
	local px, py = self:gridToPixel(pos.x, pos.y)
	love.graphics.draw(selected, self.hudPosition.x + px - 14, self.hudPosition.y + py - 9)
	love.graphics.pop()
end

function InventoryState:drawInventoryTitle()
	local ox, oy = self:pixelToGrid(self.hudPosition.x, self.hudPosition.y)
	self.display:print(ox + 2, oy + 2, "Inventory", nil, nil, 2, "left")
end

function InventoryState:drawPlayerStats()
	local ox, oy = self:pixelToGrid(self.hudPosition.x, self.hudPosition.y)
	local damageMod = self:calculatePlayerDamageModifier()
	local knockbackMod = self:calculatePlayerKnockbackModifier()

	self.display:print(ox + 52, oy + 8, "DMG: " .. damageMod)
	self.display:print(ox + 52, oy + 9, " KB: " .. knockbackMod)
end

function InventoryState:calculatePlayerDamageModifier()
	local conditionHolder = prism.components.ConditionHolder
	local damageMod = 0
	local modifiers = conditionHolder.getActorModifiers(Game.player, prism.modifiers.DamageModifier)
	for _, modifier in ipairs(modifiers) do
		damageMod = damageMod + modifier.delta
	end
	return damageMod
end

function InventoryState:calculatePlayerKnockbackModifier()
	local conditionHolder = prism.components.ConditionHolder
	local knockbackMod = 0
	local modifiers = conditionHolder.getActorModifiers(Game.player, prism.modifiers.KnockbackModifier)
	for _, modifier in ipairs(modifiers) do
		knockbackMod = knockbackMod + modifier.delta
	end
	return knockbackMod
end

function InventoryState:drawSelectedItemInfo()
	local selectedItem = self.items[self.selectedPosition]
		or (self.selectedPosition > 25 and self.equipment[self.selectedPosition - 25].actor)

	if not selectedItem then
		return
	end

	local ox, oy = self:pixelToGrid(self.hudPosition.x, self.hudPosition.y)

	self:drawItemNameAndStack(ox, oy, selectedItem)
	local lineOffset = self:drawItemDescription(ox, oy, selectedItem)
	self:drawEquipmentStats(ox, oy, selectedItem, lineOffset, true)
end

function InventoryState:drawItemNameAndStack(ox, oy, selectedItem)
	local item = selectedItem:expect(prism.components.Item)
	local text = selectedItem:getName()

	if item.stackCount > 1 then
		text = text .. " x" .. item.stackCount
	end

	self.display:print(ox + 24, oy + 2, text)
end

function InventoryState:drawItemDescription(ox, oy, selectedItem)
	local desc = selectedItem:get(prism.components.Description)
	if not desc then
		return 0
	end

	local lineOffset = 0

	if #desc.text > 20 then
		lineOffset = self:drawWrappedDescription(ox, oy, desc.text)
	else
		self.display:print(ox + 24, oy + 4, desc.text)
	end

	return lineOffset
end

function InventoryState:drawWrappedDescription(ox, oy, text)
	local lineOffset = 0
	local max = #text
	local i = 1

	while i <= max do
		local endPos = math.min(i + 19, max)

		if endPos < max then
			local breakPos = nil
			for j = i + 14, endPos do
				local char = text:sub(j, j)
				if char == " " or char == "-" then
					breakPos = j
				end
			end
			if breakPos then
				endPos = breakPos
			end
		end

		local chunk = text:sub(i, endPos)
		self.display:print(ox + 24, oy + 4 + lineOffset, chunk)
		i = endPos + 1
		lineOffset = lineOffset + 1
	end

	return lineOffset
end

function InventoryState:calculateEquipmentDamageModifier(equipment)
	local damageMod = 0
	local modifiers = equipment.condition:getModifiers(prism.modifiers.DamageModifier)
	for _, modifier in ipairs(modifiers) do
		damageMod = damageMod + modifier.delta
	end
	return damageMod
end

function InventoryState:calculateEquipmentKnockbackModifier(equipment)
	local knockbackMod = 0
	local modifiers = equipment.condition:getModifiers(prism.modifiers.KnockbackModifier)
	for _, modifier in ipairs(modifiers) do
		knockbackMod = knockbackMod + modifier.delta
	end
	return knockbackMod
end

function InventoryState:drawEquipmentStats(ox, oy, selectedItem, lineOffset, modifier)
	modifier = modifier or false
	local equipment = selectedItem:get(prism.components.Equipment)
	if not equipment then
		return
	end

	local damageMod = self:calculateEquipmentDamageModifier(equipment)
	local knockbackMod = self:calculateEquipmentKnockbackModifier(equipment)

	local idx = 2
	if damageMod > 0 then
		self.display:print(ox + 24, oy + 4 + lineOffset + idx, "DMG: " .. (modifier and "+" or "") .. damageMod)
		idx = idx + 1
	end
	if knockbackMod > 0 then
		self.display:print(ox + 24, oy + 4 + lineOffset + idx, " KB: " .. (modifier and "+" or "") .. knockbackMod)
		idx = idx + 1
	end
end

function InventoryState:drawInventoryItems()
	local ox, oy = self:pixelToGrid(self.hudPosition.x, self.hudPosition.y)

	for i, actor in ipairs(self.items) do
		self.display:putActor(ox + self.hudPositions[i].x - 1, oy + self.hudPositions[i].y - 1, actor)
	end
end

function InventoryState:drawEquippedItems()
	local ox, oy = self:pixelToGrid(self.hudPosition.x, self.hudPosition.y)

	for i, slot in ipairs(self.equipment) do
		if slot.actor then
			self.display:putActor(
				ox + self.equipPositions[slot.slot].x - 1,
				oy + self.equipPositions[slot.slot].y - 1,
				slot.actor
			)
		end
	end
end
function InventoryState:update(dt)
	controls:update()

	if controls.move.pressed then
		local currentPos = self.hudPositions[self.selectedPosition]
		local moveVec = controls.move.vector

		if currentPos and moveVec then
			if moveVec.x == 1 and self.selectedPosition == 5 then
				self.selectedPosition = 26
			elseif moveVec.x == -1 and self.selectedPosition > 25 then
				self.selectedPosition = 5
			end
			-- Calculate new grid position
			local newX = currentPos.x + (4 * moveVec.x)
			local newY = currentPos.y + (4 * moveVec.y)

			-- Find the index that matches this position
			for idx, pos in ipairs(self.hudPositions) do
				if pos.x == newX and pos.y == newY then
					self.selectedPosition = idx
					break
				end
			end
		end
	end

	if controls.select.pressed then
		local item = nil
		if self.selectedPosition <= 25 then
			item = self.items[self.selectedPosition]
		else
			item = self.equipment[self.selectedPosition - 25].actor
		end
		if item then
			self.manager:push(spectrum.gamestates.InventoryActionState(self.display, self.decision, self.level, item))
		end
	end

	if controls.inventory.pressed or controls.back.pressed then
		self.manager:pop()
	end
end

function InventoryState:resume()
	if self.decision:validateResponse() then
		self.manager:pop()
	end
end
return InventoryState
