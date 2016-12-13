local max_energy = 9 * 10 ^ 6

local reactor = peripheral.wrap("bottom")

local function main()
	repeat
		local energy = reactor.getEnergyStored()

		local timestamp = ("[%.2f] "):format(os.time())

		if energy >= max_energy and reactor.getActive() then
			print(timestamp .. "Max energy reached, shutting down")
			reactor.setActive(false)
		elseif energy == 0 and not reactor.getActive() then
			print(timestamp .. "Energy depleted, starting up")
			reactor.setActive(true)
		end

		os.sleep(5)
	until false
end

main()
