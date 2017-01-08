-- 2017 m1cr0man

local fuel_min = 97.3
local buffer_min = 3000
local core_temp_max = 1500
local update_interval = 2
local rednet_side = "right"
local rednet_protocol = "statusReactor"

local reactor = peripheral.wrap("bottom")

local fuel_max = reactor.getFuelAmountMax()

local readings = {
	name = os.getComputerLabel()
}

local function broadcastStatus()
	rednet.open(rednet_side)
	rednet.broadcast(
		readings,
		rednet_protocol
	)
	readings.event = nil
	rednet.close(rednet_side)
end

local function logEvent(event)
	readings.event = event
	print(event)
end

local function updateReadings()
	readings.is_on = reactor.getActive()
	readings.steam_buffered = reactor.getHotFluidAmount()
	readings.fuel_percent = (reactor.getFuelAmount() * 100) / fuel_max
	readings.fuel_burn_rate = reactor.getFuelConsumedLastTick()
	readings.core_temp = reactor.getFuelTemperature()
end

-- Raises/lowers rods to match steam target
local function controlActivity()
	if readings.is_on then

		-- Shutdown if out of fuel
		if readings.fuel_percent <= fuel_min then
			logEvent("Fuel below minimum, shutting down")
			reactor.setActive(false)

		-- Shutdown if overheating
		elseif readings.core_temp > core_temp_max then
			logEvent("Temperature above maximum, shutting down")
			reactor.setActive(false)
		end

	elseif

	-- Start if fuel is sufficient
		readings.fuel_percent >= fuel_min and

	-- and buffer is below min
		readings.steam_buffered < buffer_min

	-- We don't need a case to cover the temperature because if
	-- the reactor overheats the steam buffer is guaranteed to be full
	then
		logEvent("Targets met, starting up")
		reactor.setActive(true)
	end
end

local function main()

	-- Get initial readings
	updateReadings()

	-- Main loop
	local update_timer = os.startTimer(update_interval)
	while true do
		local evt, p1, p2, p3, p4 = os.pullEvent()

		-- Restart timer, run functions
		if evt == "timer" and p1 == update_timer then
			controlActivity()
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
