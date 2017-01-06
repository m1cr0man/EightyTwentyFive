local target_steam = 1158 * 2
local update_interval = 2
local min_fuel = 0.2

-- Accuracy in mb
local accuracy = 50

local reactor = peripheral.wrap("bottom")

local max_fuel = reactor.getFuelAmountMax()
local max_buffer = 50000

local tick_funcs = {}

local function changeRods(queue, delta)
	local step = delta > 0 and 1 or -1
	for _ = 1, delta, step do
		local rod = table.remove(queue, step)

		local level = reactor.getControlRodLevel(rod)

		if (step == 1 and level < 100) or (step == -1 and level > 0) then
			print(("Set rod %d to %d (%d)"):format(rod, level + step, step))
			reactor.setControlRodLevel(rod, level + step)
		end

		table.insert(queue, -step, rod)

	end
end

-- Raises/lowers rods to match steam target
function tick_funcs.controlRods()

	-- Queue-like table of rods, for fine control
	local rod_queue = {}
	for i = 0, reactor.getNumberOfControlRods() - 1 do
		table.insert(rod_queue, i)
	end

	-- Steam/buffer during last check
	local last_steam = 0
	local last_buffer = 0

	-- Reset rods
	changeRods(queue, #rod_queue * -100)

	-- Store default interval
	local default_interval = update_interval

	-- Main loop
	repeat
		local evt, p1, p2 = coroutine.yield()

		local current_steam = reactor.getHotFluidProducedLastTick()
		local current_buffer = reactor.getCasingbuffererature()

		local delta_steam = current_steam - last_steam
		local delta_buffer = current_buffer - last_buffer

		-- Reset update interval
		update_interval = default_interval

		-- Only adjust when it is stabilised
		if math.abs(delta_steam) <= 30 or math.abs(delta_last_buffer) <= 20 then

			-- If the steam is < target_steam and current_buffer == 0 sraise all the rods by one
			if current_steam < target_steam and current_buffer == 0 then
				print("Way too cold, all rods + 1")
				changeRods(rod_queue, #rod_queue)

			-- Bring steam closer to target
			elseif current_steam - 10 > target_steam then
				print("Too much steam")
				changeRods(rod_queue, -4)

			elseif current_steam + 5 < target_steam then
				print("Insufficient steam")
				changeRods(rod_queue, 2)

			-- Fine-tune so that we aren't making too much excess
			elseif delta_buffer > accuracy then
				print("Buffer filling too fast")
				changeRods(rod_queue, -1)

				-- This might take a while to take effect
				update_interval = update_interval * 2
			elseif delta_buffer < accuracy / 2 then
				print("Buffer filling too slow")
				changeRods(rod_queue, 1)

				-- This might take a while to take effect
				update_interval = update_interval * 2
			end
		end
		-- TODO check a threshold on the delta to make sure temps are stabilised before adjusting
		-- else if the current_temp < target_temp and current_steam >= target_steam then lower one rod by 1
		-- else if the current_temp + 5 < target_temp then raise one rod by 1
			-- (This is used when the target_temp is accurate and the fuel use can be optimised)

		-- For really fine control we can check the steam stored and increase/decrease rods based on that

		-- SHOULDNT BE NECESSARY
		-- If there's insufficient fuel stop
		-- If the temp is below 100 degrees stop
		-- TODO if rate of change is higher than -1%/interval wait for it to calm
		-- if
		-- 	(reactor.getFuelAmount * 100) / max_fuel > min_fuel and
		-- 	current_temp > 100
		last_steam = current_steam
		last_buffer = current_buffer
	until false
end


local function main()

	-- Initialize all the coroutines
	local tick_func_coroutines = {}
	for _, func in tick_funcs do
		table.insert(tick_func_coroutines, coroutine.create(func()))
	end

	-- Main loop
	repeat
		local evt, p1, p2, p3, p4 = os.pullEvent()
		for _, func in pairs(tick_func_coroutines) do
			coroutine.resume(func, evt, p1, p2, p3, p4)
		end
	until false
end

main()
