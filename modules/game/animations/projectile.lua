spectrum.registerAnimation("Projectile", function(owner, targetPosition)
	--- @cast owner Actor
	--- @cast targetPosition Vector2
	local x, y = owner:expectPosition():decompose()
	local path = prism.bresenham(x, y, targetPosition.x, targetPosition.y, function(_x, _y)
		return true
	end)

	local points = path:getPath()

	return spectrum.Animation(function(t, display)
		local index = math.min(math.floor(t / 0.05) + 1, #points)
		local point = points[index]
		display:put(point.x, point.y, "*", prism.Color4.ORANGE)

		if index >= #points then
			return true
		end

		return false
	end)
end)
