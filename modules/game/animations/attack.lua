-- Register an attack animation that lunges toward target and returns
spectrum.registerAnimation("Attack", function(owner, targetPosition)
	--- @cast owner Actor
	--- @cast targetPosition Vector2

	-- Get the actor's starting position
	local startPos = owner:expectPosition()
	local startX, startY = startPos:decompose()
	local targetX, targetY = targetPosition.x, targetPosition.y

	-- Calculate direction vector (normalized to 1 tile step)
	local dx = targetX - startX
	local dy = targetY - startY
	local distance = math.sqrt(dx * dx + dy * dy)

	-- Calculate lunge position (one tile toward target)
	local lungeX = startX + math.floor((dx / distance) + 0.5)
	local lungeY = startY + math.floor((dy / distance) + 0.5)

	-- Get actor's drawable component
	local drawable = owner:get(prism.components.Drawable):clone()
	assert(drawable, "Actor must have a Drawable component for attack animation")
	---@cast drawable Drawable
	drawable.layer = math.huge
	-- Animation phases with timing
	local lungeTime = 0.1 -- Time to lunge forward
	local pauseTime = 0.05 -- Brief pause at lunge
	local returnTime = 0.15 -- Time to return
	local totalTime = lungeTime + pauseTime + returnTime

	return spectrum.Animation(function(t, display)
		-- Hide the actor at its original position
		display:overrideActor(owner)

		local currentX, currentY
		local progress

		if t < lungeTime then
			-- Phase 1: Lunge forward
			progress = t / lungeTime
			currentX = startX + (lungeX - startX) * progress
			currentY = startY + (lungeY - startY) * progress
		elseif t < lungeTime + pauseTime then
			-- Phase 2: Hold at lunge position
			currentX = lungeX
			currentY = lungeY
		elseif t < totalTime then
			-- Phase 3: Return to start
			progress = (t - lungeTime - pauseTime) / returnTime
			currentX = lungeX + (startX - lungeX) * progress
			currentY = lungeY + (startY - lungeY) * progress
		else
			-- Animation complete - restore actor
			display:unoverrideActor(owner)
			return true
		end

		-- Convert to pixel coordinates with camera offset
		local pixelX = (currentX + display.camera.x - 1) * display.cellSize.x
		local pixelY = (currentY + display.camera.y - 1) * display.cellSize.y

		-- Draw the actor at the current position
		display:drawDrawable(pixelX, pixelY, drawable)

		return false
	end)
end)
