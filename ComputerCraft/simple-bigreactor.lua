-- 2016 m1cr0man

local fuel_min = 97.3
local buffer_min = 3000
local buffer_max = 7000
local update_interval = 2

local reactor = peripheral.wrap("bottom")

local fuel_max = reactor.getFuelAmountMax()

local tick_funcs = {}

-- Raises/lowers rods to match steam target
function tick_funcs.controlActivity()
	while true do
		local evt, p1, p2 = coroutine.yield()

		local is_on = reactor.getActive()
		local steam_buffered = reactor.getHotFluidAmount()
		local fuel_percent = (reactor.getFuelAmount() * 100) / fuel_max

		if is_on then

			-- Shutdown if out of fuel
			if fuel_percent <= fuel_min then
				print("Fuel below minimum, shutting down")
				reactor.setActive(false)

			-- Shutdown if buffer is above max
			-- elseif steam_buffered >= buffer_max then
			-- 	print("Steam buffer above maximum, shutting down")
			-- 	reactor.setActive(false)
			end

		elseif

		-- Start if buffer is below min
			fuel_percent >= fuel_min and

		-- and fuel is sufficient
			steam_buffered < buffer_min
		then
			print("Steam buffer and fuel at thresholds, starting up")
			reactor.setActive(true)
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
