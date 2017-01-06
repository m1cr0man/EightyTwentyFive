-- 2016 m1cr0man

local steam_required = 1160
local rpm_min = 1780
local rpm_max = 1820
local power_max = 90
local update_interval = 2
local rednet_side = "left"
local rednet_protocol = "statusTurbine"

local turbine = peripheral.wrap("back")

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
	readings.coil_on = turbine.getInductorEngaged()
	readings.steam_on = turbine.getFluidFlowRateMax() > 0
	readings.steam_buffered = turbine.getInputAmount()
	readings.power_buffered_percent = turbine.getEnergyStored() / 10000
	readings.rpm = turbine.getRotorSpeed()
end

-- Disables coils when steam runs out
-- Disables coils if RPM passes a lower threshold
-- Disables steam when RPM passes an upper threshold
local function controlRPM()

	-- Coil management
	if readings.coil_on then

		-- Disable coils if buffer is empty
		if readings.steam_buffered == 0 then
			print("Steam depleted, disabling coil")
			turbine.setInductorEngaged(false)

		-- Disable coils if RPM is too low
		-- Allows them to spool back up
		elseif readings.rpm < rpm_min then
			print("RPM below minimum, disabling coil")
			turbine.setInductorEngaged(false)

		-- Disable coil if power full
		elseif readings.power_buffered_percent >= power_max then
			print("Power above maximum, disabling coil")
			turbine.setInductorEngaged(false)
		end

	elseif

		-- Enable coil if buffer is more than a tick full
		readings.steam_buffered > steam_required and

		-- and RPM is above threshold
		-- DISABLED Offset to stop flickering  + (rpm_min - rpm_max) * 0.25
		readings.rpm > rpm_min and

		-- and power isn't maxed
		readings.power_buffered_percent < power_max
	then
		print("Targets met, enabling coil")
		turbine.setInductorEngaged(true)
	end

	-- Steam management
	if readings.steam_on then

		-- Disable steam if power full
		if readings.power_buffered_percent > power_max then
			print("Max power reached, disabling steam")
			turbine.setFluidFlowRateMax(0)

		-- Disable steam if overloaded
		elseif readings.rpm > rpm_max then
			print("Turbine overloaded, disabling steam")
			turbine.setFluidFlowRateMax(0)

		end

	elseif

	-- Enable steam if power low enough
		readings.power_buffered_percent < power_max and

	-- and coil is below max speed
		readings.rpm < rpm_max
	then
		print("Power and RPM targets met, enabling steam")
		turbine.setFluidFlowRateMax(steam_required)
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
			controlRPM()
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
