-- 2017 m1cr0man
os.loadAPI("commonlib")
os.loadAPI("interfaces")

-- Configurable options
local update_interval = 3
local rednet_side = "back"
local monitor_side = "left"
local log_max_length = 1000
local supported_protocols = {
	["statusReactor"] = true,
	["statusTurbine"] = true,
	["statusStorage"] = true
}
-- END configurable options

-- Setup windows on the monitor
local monitor = peripheral.wrap(monitor_side)
local monitor_szx, monitor_szy = monitor.getSize()
local monitor_statuses = window.create(monitor, monitor_szx / 2, monitor_szy, 1, 1, true)
local monitor_log = window.create(monitor, monitor_szx / 2, monitor_szy, 1 + (monitor_szx / 2), 1, true)
local boxes_per_row = math.floor(monitor_szx / 6)

-- Clear the monitor log now, and never again
monitor_log.setBackgroundColour(colours.black)
monitor_log.clear()

local devices = setmetatable({}, {
	__index = function(self, name)
		self[name] = interfaces[name:match("^%a+")](name, log_max_length)
		return self[name]
	end
})

local events = commonlib.Queue(log_max_length)

local function printSummaryBox(summary, index)

	-- Align the cursor up
	local x_pos = 1 + 6 * ((index - 1) % boxes_per_row)
	local y_pos = 1 + 4 * math.floor((index - 1) / boxes_per_row)
	monitor_statuses.setCursorPos(x_pos, y_pos)
	monitor_statuses.setBackgroundColour(colours[summary[1] and "green" or "red"])
	table.remove(summary, 1)

	-- Pad the values in summary
	for i, data in ipairs(summary) do
		data = tostring(data)
		for _ = 1, 2 - math.floor((#data - 1) / 2) do
			data = " " .. data
		end

		-- Trailing spaces, if necessary, so that colouring is right
		for _ = 1, 5 - #data do
			data = data .. " "
		end
		monitor_statuses.write(data)
		monitor_statuses.setCursorPos(x_pos, y_pos + i)
	end
end

local function printEventLog()
	term.redirect(monitor_log)
	while not events:isEmpty() do
		print(events:pop())
	end
	term.restore()
end

local function printStatusLog()
	monitor_statuses.setBackgroundColour(colours.black)
	monitor_statuses.clear()
	i = 1
	for _, device in pairs(devices) do
		printSummaryBox(device:getSummary(), i)
		i = i + 1
	end
end

local function updateDisplay()
	printStatusLog()
	printEventLog()
end

local function updateEvents(name, log_data)
	if not log_data.event then return end

	local log_msg = "[%s:%s] %s"

	events:push(log_msg:format(
		name,
		commonlib.prettyDay(p2.timestamp),
		log_data.event
	))
end

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
			rednet.close(rednet_side)
			return 0

		-- Handle logging for supported protocols
		elseif evt == "rednet_message" and supported_protocols[p3] then
			local name = p2.name
			print(name)
			p2.timestamp = commonlib.timestamp()
			p2.name = nil
			updateEvents(name, devices[name]:update(p2))
		end
	end
end

main()
