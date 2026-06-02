spectrum.registerAnimation("Burn", function()
	local on = { index = "%", color = prism.Color4.ORANGE, background = prism.Color4.RED }
	local off = { index = " ", color = prism.Color4.BLACK }
	return spectrum.Animation({ on, off, on }, 0.2, "pauseAtEnd")
end)
