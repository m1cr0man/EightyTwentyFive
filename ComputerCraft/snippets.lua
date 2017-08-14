local function getInputs()
	local key;
	local north, left, down = minval, minval, minval

	repeat
		term.clear()
		term.setCursorPos(1, 1)
		print("All directions are relative to the turtle")
		print(("North: %d\nLeft:  %d\nDown:  %d"):format(north, left, down))
		print("W/S:   Inc/Decrement North")
		print("A/D:   Inc/Decrement Left")
		print("Q/E:   Inc/Decrement Down")
		print("Enter: Start")

		key = select(2, os.pullEvent("key"))

		-- W
		if key == 17 then north = north + 1

		-- S
		elseif key == 31 then north = north > 2 and north - 1 or minval

		-- A
		elseif key == 30 then left = left > 2 and left - 1 or minval

		-- D
		elseif key == 32 then left = left + 1

		-- Q
		elseif key == 16 then down = down > 2 and down - 1 or minval

		-- E
		elseif key == 18 then down = down + 1 end

	-- Enter
	until key == 28

	return north, left, down
end

local function loadSettings(path)
	local file = io.open(path, "r")
	local tbl = textutils.unserialize(file:read("*a"))
	file:close()
	return tbl
end

local function saveSettings(path, tbl)
	local file = io.open(path, "w")
	file:write(textutils.serialize(tbl))
	file:close()
end

	-- Loggable events...
	-- reactor shutdown
	-- reactor restarted
	-- Steam is 0 (out of fuel)
	if log_data.steam == 0 and self.steam ~= 0 then
		table.insert(events, "Out of steam")
	end

	-- Reactor overheated
	if
		self.steam_delta == 0 and
		log_data.core_temp > self.core_temp and
		not log_data.is_on
	then
		table.insert(events, ("Overheated! %d oC"):format(log_data.core_temp))
	end

	-- Reactor shutdown
	if self.is_on and not log_data.is_on then
		table.insert(events, ("Shutdown with %.1f%% fuel"):format(log_data.fuel_percent))

	-- Reactor restarted
	elseif log_data.is_on and not self.is_on then
		table.insert(events, "Restarted")
	end

	-- Update the current status
	for k, v in pairs(log_data) do
		self[k] = v
	end
