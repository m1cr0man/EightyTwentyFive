shell.run("big-commonlib")
shell.run("big-interfaces")

-- 2016 m1cr0man
local update_interval = 3
local rednet_side = "back"
local monitor_side = "left"

local function main()
	rednet.open(rednet_side)

	-- Main loop
	local update_timer = os.startTimer(update_interval)
	while true do
		local evt, p1, p2, p3, p4 = os.pullEvent()

		-- Restart timer
		if evt == "timer" and p1 == update_timer then
			updateDisplay()
			update_timer = os.startTimer(update_interval)

		-- Kill switch (end key)
		elseif evt == "key" and p1 == keys['end'] then
			print("Program closed")
			return 0

		-- Handle logging for supported protocols
		elseif evt == "rednet_message" and p3 then
			print(p1)
			protocol_handlers[p3](p1, p2)
		end
	end
end

main()
