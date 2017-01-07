-- REQUIRES big-commonlib

-- Reactor class
local Reactor = class()

function Reactor.new(name, log_size)
	local self = setmetatable(log_data, Reactor)
	self.name = name
	self.logs = Stack(log_size)

	-- Initialize the statistics
	self.uptime = 0
	self.steam_delta = 0
	self.fuel_delta = 0
	self.temp_delta = 0

	return self
end

function Reactor:update(log_data)

	-- Update the statistics
	-- Only if there is >= 1 log
	if not self.logs:isEmpty() then
		if log_data.is_on then
			self.uptime = self.uptime + log_data.timestamp - (self.timestamp or os.time())
		end

		self.steam_delta = log_data.steam_buffered - self.steam_buffered
		self.fuel_delta = log_data.fuel_percent - self.fuel_percent
		self.temp_delta = log_data.core_temp - self.core_temp
	end

	-- Update the current status
	for k, v in pairs(log_data) do
		self[k] = v
	end

	-- Store the log
	self.logs:push(log_data)
end

function Reactor:getSummary()
	-- Return sth that fits in a 5x3 box
	-- [is_on, Name, Uptime, Steam]
	return {
		self.is_on,
		self.shortname:gsub("Reactor", " R"),
		self.uptime,
		self.steam_delta
	}
end

function Reactor:getPage()

end

-- Turbine clas
local Turbine = class()

function Turbine.new(name, log_size)
	local self = setmetatable(log_data, Turbine)
	self.name = name
	self.logs = Stack(log_size)

	-- Initialize the statistics
	self.uptime = 0
	self.steam_delta = 0
	self.fuel_delta = 0
	self.temp_delta = 0

	return self
end

function Turbine:update(log_data)

	-- Update the statistics
	-- Only if there is >= 1 log
	if not self.logs:isEmpty() then
		if log_data.is_on then
			self.uptime = self.uptime + log_data.timestamp - (self.timestamp or os.time())
		end

		self.steam_delta = log_data.steam_buffered - self.steam_buffered
		self.fuel_delta = log_data.fuel_percent - self.fuel_percent
		self.temp_delta = log_data.core_temp - self.core_temp
	end

	-- Update the current status
	for k, v in pairs(log_data) do
		self[k] = v
	end

	-- Store the log
	self.logs:push(log_data)
end

function Turbine:getSummary()
	-- Return sth that fits in a 5x3 box
	-- [is_on, Name, Uptime, Steam]
	return {
		self.is_on,
		self.shortname:gsub("Turbine", " T"),
		self.uptime,
		self.steam_delta
	}
end

function Turbine:getPage()

end
