-- Simple Keyboard-controlled turtle program

local function digAll()
	turtle.dig()
	turtle.digUp()
	turtle.digDown()
end

local function printBlockName(dir)
	local func_dir = dir or ""
	local _, data = turtle["inspect" .. func_dir]()
	local block_name = type(data) == "table" and data.name or "None"
	term.clearLine()
	print(("%s: %s"):format((dir or "front"), block_name))
end

local none_tbl = {
	name = "None"
}

local cmd_map = {
	[200] = turtle.forward,
	[203] = turtle.turnLeft,
	[205] = turtle.turnRight,
	[208] = turtle.back,
	[57] = turtle.up,
	[29] = turtle.down,
	[19] = turtle.digUp,
	[33] = turtle.dig,
	[47] = turtle.digDown,
	[34] = digAll
}

-- Empty function that does nothing for if we
--  try indexing something that isn't there
setmetatable(cmd_map, {
	__index = function(self)
		return function() end
	end
})

local function main()

	-- Print the control map
	print("Controls:")
	print("\tArrows: Movement")
	print("\tSpace: Up")
	print("\tCtrl: Down")
	print("\tR/F/V/G: Dig Up/Front/Down/All")
	print("\tEnd: Exit")
	print()

	repeat

		-- Print name of surrounding blocks
		-- Keep cursor where it should be
		local x, y = term.getCursorPos()
		printBlockName("Up")
		printBlockName()
		printBlockName("Down")
		term.setCursorPos(x, y)

		local _, key = os.pullEvent("key")
		cmd_map[key]()
	until key == 207

	term.clear()
	print("Bye")
end

main()
