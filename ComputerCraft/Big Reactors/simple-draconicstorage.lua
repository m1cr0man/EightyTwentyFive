-- 2017 m1cr0man
local update_interval = 2
local rednet_side = "bottom"
local rednet_protocol = "statusStorage"

local storage = peripheral.wrap("top")

local readings = {
	name = os.getComputerLabel()
}

local function broadcastStatus()
	rednet.open(rednet_side)
	rednet.broadcast(
		readings,
		rednet_protocol
	)
	rednet.close(rednet_side)
end

local function updateReadings()
	readings.energy = storage.getEnergyStored()
	readings.energy_max = storage.getMaxEnergyStored()
end

local function main()

	-- Main loop
	local update_timer = os.startTimer(update_interval)
	while true do
		local evt, p1, p2, p3, p4 = os.pullEvent()

		-- Restart timer, run functions
		if evt == "timer" and p1 == update_timer then
			updateReadings()
			broadcastStatus()
			update_timer = os.startTimer(update_interval)

		-- Kill switch (end key)
		elseif evt == "key" and p1 == keys['end'] then
			print("Program closed")
			return 0
		end
	end
end

main()
