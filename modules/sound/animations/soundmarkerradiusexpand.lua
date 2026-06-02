spectrum.registerAnimation("SoundRadiusMarkersExpand", function(radius, actor)
	-- Pre-calculate marker positions once
	local directions = {
		{ 1, 0 }, -- East
		{ -1, 0 }, -- West
		{ 0, 1 }, -- South
		{ 0, -1 }, -- North
		{ 0.7071, 0.7071 }, -- SE (1/sqrt(2))
		{ -0.7071, 0.7071 }, -- SW
		{ 0.7071, -0.7071 }, -- NE
		{ -0.7071, -0.7071 }, -- NW
	}

	local color = prism.Color4.fromHex(0x202020)
	local animationDuration = 0.4
	local skipAnimation = radius <= 1

	local anim = spectrum.Animation(function(t, display)
		local centerX, centerY = actor:getPosition():decompose()
		local progress = t / animationDuration
		if progress >= 1 then
			progress = 1
		end
		if skipAnimation then
			-- Just draw once at full radius
			for _, dir in ipairs(directions) do
				local x = math.floor(radius * dir[1] + 0.5)
				local y = math.floor(radius * dir[2] + 0.5)
				display:putBG(centerX + x, centerY + y, color)
			end
		else
			local currentRadius = progress * radius

			for _, dir in ipairs(directions) do
				local x = math.floor(currentRadius * dir[1] + 0.5)
				local y = math.floor(currentRadius * dir[2] + 0.5)
				display:putBG(centerX + x, centerY + y, color)
			end
		end
		return progress == 1
	end)
	return anim
end)
