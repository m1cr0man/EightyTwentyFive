-- 2016 m1cr0man

local steam_required = 1160
local rpm_min = 1780
local rpm_max = 1820
local power_max = 90
local update_interval = 2

local turbine = peripheral.wrap("back")

local tick_funcs = {}

-- Disables coils when steam runs out
-- Disables coils if RPM passes a lower threshold
-- Disables steam when RPM passes an upper threshold
function tick_funcs.controlRPM()
	while true do
		local evt, p1, p2 = coroutine.yield()

		local coil_on = turbine.getInductorEngaged()
		local steam_on = turbine.getFluidFlowRateMax() > 0
		local steam_buffered = turbine.getInputAmount()
		local power_buffered_percent = turbine.getEnergyStored() / 10000
		local rpm = turbine.getRotorSpeed()

		-- Coil management
		if coil_on then

			-- Disable coils if buffer is empty
			if steam_buffered == 0 then
				print("Steam depleted, disabling coil")
				turbine.setInductorEngaged(false)

			-- Disable coils if RPM is too low
			-- Allows them to spool back up
			elseif rpm < rpm_min then
				print("RPM below minimum, disabling coil")
				turbine.setInductorEngaged(false)

			-- Disable coil if power full
			elseif power_buffered_percent >= power_max then
				print("Power above maximum, disabling coil")
				turbine.setInductorEngaged(false)
			end

		elseif

			-- Enable coil if buffer is more than a tick full
			steam_buffered > steam_required and

			-- and RPM is above threshold
			-- DISABLED Offset to stop flickering  + (rpm_min - rpm_max) * 0.25
			rpm > rpm_min and

			-- and power isn't maxed
			power_buffered_percent < power_max
		then
			print("Targets met, enabling coil")
			turbine.setInductorEngaged(true)
		end

		-- Steam management
		if steam_on then

			-- Disable steam if power full
			if power_buffered_percent > power_max then
				print("Max power reached, disabling steam")
				turbine.setFluidFlowRateMax(0)

			-- Disable steam if overloaded
			elseif rpm > rpm_max then
				print("Turbine overloaded, disabling steam")
				turbine.setFluidFlowRateMax(0)

			end

		elseif

		-- Enable steam if power low enough
			power_buffered_percent < power_max and

		-- and coil is below max speed
			rpm < rpm_max
		then
			print("Power and RPM targets met, enabling steam")
			turbine.setFluidFlowRateMax(steam_required)
		end

	end
end

local function main()

	-- Initialize all the coroutines
	local tick_func_coroutines = {}
	for _, func in pairs(tick_funcs) do
		table.insert(tick_func_coroutines, coroutine.create(func))
	end

	-- Main loop
	local update_timer = os.startTimer(update_interval)
	while true do
		local evt, p1, p2, p3, p4 = os.pullEventRaw()

		for _, func in pairs(tick_func_coroutines) do
			coroutine.resume(func, evt, p1, p2, p3, p4)
		end

		-- Restart timer
		if evt == "timer" then
			update_timer = os.startTimer(update_interval)

		-- Kill switch (end key)
		elseif evt == "key" and p1 == keys['end'] then
			print("Program closed")
			return 0
		end
	end
end

main()
