function love.graphics.ellipse(mode, x, y, a, b, phi, points)
	phi = phi or 0
	points = points or 10
	if points <= 0 then points = 1 end

	local two_pi = math.pi*2
	local angle_shift = two_pi/points
	local theta = 0
	local sin_phi = math.sin(phi)
	local cos_phi = math.cos(phi)

	local coords = {}
	for i = 1, points do
	theta = theta + angle_shift
	coords[2*i-1] = x + a * math.cos(theta) * cos_phi 
					  - b * math.sin(theta) * sin_phi
	coords[2*i] = y + a * math.cos(theta) * sin_phi 
					+ b * math.sin(theta) * cos_phi
	end

	coords[2*points+1] = coords[1]
	coords[2*points+2] = coords[2]

	love.graphics.polygon(mode, coords)
end

function love.graphics.newgradient(colors)
	local direction = colors.direction or "horizontal"
	if direction == "horizontal" then
		direction = true
	elseif direction == "vertical" then
		direction = false
	else
		error("Invalid direction '" .. tostring(direction) "' for gradient.  Horizontal or vertical expected.")
	end
	local result = love.image.newImageData(direction and 1 or #colors, direction and #colors or 1)
	for i, color in ipairs(colors) do
		local x, y
		if direction then
			x, y = 0, i - 1
		else
			x, y = i - 1, 0
		end
		result:setPixel(x, y, color[1], color[2], color[3], color[4] or 255)
	end
	result = love.graphics.newImage(result)
	result:setFilter('linear', 'linear')
	return result
end

function love.graphics.drawinrect(img, x, y, w, h, r, ox, oy, kx, ky)
	return -- tail call for a little extra bit of efficiency
	love.graphics.draw(img, x, y, r, w / img:getWidth(), h / img:getHeight(), ox, oy, kx, ky)
end

function love.graphics.drawArc(x, y, r, angle1, angle2, segments)
	segments = segments or 10
	local i = angle1
	local step = (math.pi * 2) / segments

	while i < angle2 do
		j = angle2 - i < step and angle2 or i + step
		love.graphics.line(x + (math.cos(i) * r), y - (math.sin(i) * r), x + (math.cos(j) * r), y - (math.sin(j) * r))
		i = j
	end
end