shell.run("stateful")

local argv = {...}

local minval = 2

local y, swap = 1, false

local function autorestart(path, args)
	local file = io.open("startup", "w")
	file:write("shell.run('" .. path .. "'")
	for _, arg in pairs(args) do
		file:write((", '%s'"):format(arg))
	end
	file:write(")")
	file:close()
end

local function digDistance(distance, down, x)
	local diff = down - y

	for z = 1, distance do
		print(("X: %d  Y: %d  Z: %d"):format(x, y, z))

		if diff > 0 then turtle.digDown() end

		if down > 2 then repeat until not turtle.digUp() end

		repeat turtle.dig() until turtle.forward()
	end
end

local function goDown(distance)
	print(("Y: %d  New Y: %d"):format(y, y + distance))
	for _ = 1, distance do
		repeat turtle.digDown() until turtle.down()
		y = y + 1
	end
end

local function checkFuel(north, side, down)
	local downDist = (down - (down % 3)) / 3
	if down % 3 > 0 then downDist = downDist + 1 end

	local fuelNeeded = north * side * downDist - turtle.getFuelLevel()

	if fuelNeeded > 0 then
		print(("Requires %d extra fuel"):format(fuelNeeded))
		print("Place fuel in slot 1 and press enter")
		turtle.refuel(64)
		read()
	end
end

local function areacut(north, side, down)
	local divThree = down % 3 == 0
	while y <= down do
		for x = 1, side do
			digDistance(north - 1, down, x)

			if x ~= side then
				if swap then turtle.turnRight() else turtle.turnLeft() end
				digDistance(1, down, x)
				if swap then turtle.turnRight() else turtle.turnLeft() end
				swap = not swap
			end
		end

		-- Dig block above, it might have been missed
		if down > 2 then repeat until not turtle.digUp() end

		-- Move to next applicable position
		-- If theres' more than 3 blocks to do move down 3
		-- If we're on the last row terminate
		-- otherwise move down (total - current)
		if y + 1 >= down then break
		elseif y + 3 > down then goDown(down - y)
		else goDown(3) end

		-- Turn around
		for _ = 1,2 do turtle.turnLeft() end
	end
end

local function main()
	if #argv < 3 then
		print("Usage: areacut <front> <left> <down>")
		return
	end

	local north, side, down = tonumber(argv[1]), tonumber(argv[2]), tonumber(argv[3])

	-- Flip side if negative
	if side < 0 then
		swap = not swap
		side = side * -1
	end

	if north < minval then
		print(("North < %d, stopping"):format(minval))
		return
	end
	if side < minval then
		print(("Side < %d, stopping"):format(minval))
		return
	end
	if down < minval then
		print(("Down < %d, stopping"):format(minval))
		return
	end

	-- Make sure program can survive restarts
	local origPath = shell.getRunningProgram()
	autorestart(origPath, argv)

	-- Check fuel levels
	checkFuel(north, side, down)

	-- Move down one block if down >= 3
	if down >= 3 then
		goDown(1)
	end

	areacut(north, side, down, dir)

	-- Clean up
	fs.delete("/startup")

	-- Let stateful know we're done
	turtle.finish()
end

main()
