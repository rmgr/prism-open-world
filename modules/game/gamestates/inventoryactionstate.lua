local controls = require("controls")
local Name = prism.components.Name

--- @class InventoryActionState : GameState
--- @field decision ActionDecision
--- @field previousState GameState
--- @overload fun(display: Display, decision: ActionDecision, level: Level, item: Actor)
local InventoryActionState = spectrum.GameState:extend("InventoryActionState")

local hud = love.graphics.newImage("display/actions.png")

--- @param display Display
--- @param decision ActionDecision
--- @param level Level
--- @param item Actor
function InventoryActionState:__new(display, decision, level, item)
	self.display = display
	self.decision = decision
	self.level = level
	self.item = item

	local actionPriorities = {
		["Zap"] = 1,
		["Eat"] = 2,
		["Equip"] = 3,
	}

	self.actions = {}
	local actions = self.decision.actor:getActions()
	table.sort(actions, function(a, b)
		local nameA = string.gsub(a:getName(), "Action", "")
		local nameB = string.gsub(b:getName(), "Action", "")
		local priorityA = actionPriorities[nameA] or 999
		local priorityB = actionPriorities[nameB] or 999
		if priorityA ~= priorityB then
			return priorityA < priorityB
		else
			return nameA < nameB
		end
	end)

	for _, Action in ipairs(actions) do
		if Action:validateTarget(1, level, self.decision.actor, item) and not Action:isAbstract() then
			table.insert(self.actions, Action)
		end
	end

	self.selectedIndex = 1
end

function InventoryActionState:load(previous)
	--- @cast previous InventoryState
	self.previousState = previous
end

function InventoryActionState:draw()
	self.previousState:draw()
	self.display:clear()

	love.graphics.push()
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 540, 150, 320, 200)
	love.graphics.setColor(0.2, 0.18, 0.3)
	love.graphics.rectangle("line", 540, 150, 320, 200)
	love.graphics.pop()

	self.display:print(35, 11, Name.get(self.item), nil, nil, 2, "left")

	for i, action in ipairs(self.actions) do
		local name = string.gsub(action:getName(), "Action", "")

		if i == self.selectedIndex then
			self.display:print(36, 12 + i, "> " .. name, nil, nil, nil, "left")
		else
			self.display:print(36, 12 + i, "  " .. name, nil, nil, nil, "left")
		end
	end

	self.display:draw()
end

function InventoryActionState:update(dt)
	controls:update()

	if controls.move.pressed then
		local moveVec = controls.move.vector
		if moveVec and moveVec.y ~= 0 then
			self.selectedIndex = self.selectedIndex + moveVec.y
			-- Wrap around
			if self.selectedIndex < 1 then
				self.selectedIndex = #self.actions
			elseif self.selectedIndex > #self.actions then
				self.selectedIndex = 1
			end
		end
	end

	if controls.select.pressed then
		self:confirmSelection()
		return
	end

	-- Keep letter shortcuts as a fallback
	for i, action in ipairs(self.actions) do
		if spectrum.Input.key[string.char(i + 96)].pressed then
			self.selectedIndex = i
			self:confirmSelection()
			return
		end
	end

	if controls.inventory.pressed or controls.back.pressed then
		self.manager:pop()
	end
end

function InventoryActionState:confirmSelection()
	local action = self.actions[self.selectedIndex]
	if not action then
		return
	end

	if self.decision:setAction(action(self.decision.actor, self.item), self.level) then
		self.manager:pop()
		return
	end

	self.selectedAction = action
	self.targets = { self.item }

	for j = action:getNumTargets(), 2, -1 do
		print(j)
		self.manager:push(
			spectrum.gamestates.GeneralTargetHandler(
				self.display,
				self.previousState.previousState,
				self.targets,
				action:getTarget(j),
				self.targets
			)
		)
	end
end

function InventoryActionState:resume()
	if self.targets then
		local action = self.selectedAction(self.decision.actor, unpack(self.targets))
		local success, err = self.level:canPerform(action)
		if success then
			self.decision:setAction(action, self.level)
		else
			prism.components.Log.addMessage(self.decision.actor, err)
		end
		self.manager:pop()
	end
end

return InventoryActionState
