-- 2017 m1cr0man
os.loadAPI("commonlib")

-- Reactor class
Reactor = commonlib.class()

function Reactor.new(name, log_size)
	local self = setmetatable({}, Reactor)
	self.name = name
	self.logs = commonlib.Stack(log_size)

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
			self.uptime = self.uptime + log_data.timestamp - (self.timestamp or commonlib.timestamp())
		else
			self.uptime = 0
		end

		self.steam_delta = log_data.steam_buffered - self.steam_buffered
		self.fuel_delta = log_data.fuel_percent - self.fuel_percent
		self.temp_delta = log_data.core_temp - self.core_temp
	end

	-- Store the log
	self.logs:push(log_data)
end

function Reactor:getSummary()

	-- Return sth that fits in a 5x3 box
	-- [is_on, Name, Uptime, Steam]
	return {
		self.is_on,
		self.name:gsub("Reactor", "R"),
		commonlib.prettyDay(self.uptime),
		commonlib.prettyInt(self.steam_delta, 0, true)
	}
end

function Reactor:getPage()

end

-- Turbine class
Turbine = commonlib.class()

function Turbine.new(name, log_size)
	local self = setmetatable({}, Turbine)
	self.name = name
	self.logs = commonlib.Stack(log_size)

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
		self.rpm_delta = log_data.rpm - self.rpm

		if log_data.steam_on then
			self.steam_delta = log_data.steam_buffered - self.steam_buffered
		end
		if log_data.coil_on then
			self.uptime = self.uptime + log_data.timestamp - (self.timestamp or commonlib.timestamp())
			self.power_percent_delta = log_data.power_buffered_percent - self.power_buffered_percent
		else
			self.uptime = 0
		end
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
		self.coil_on,
		self.name:gsub("Turbine", "T"),
		commonlib.prettyDay(self.uptime),
		commonlib.prettyInt(self.power_production, 0)
	}
end

function Turbine:getPage()

end

-- Storage class
Storage = commonlib.class()

function Storage.new(name, log_size)
	local self = setmetatable({}, Storage)
	self.name = name
	self.logs = commonlib.Stack(log_size)

	-- Initialize the statistics
	self.top_energy = 0
	self.time_last_empty = commonlib.timestamp()
	self.energy_delta = 0

	return self
end

function Storage:update(log_data)

	-- Update the statistics
	-- Only if there is >= 1 log
	if not self.logs:isEmpty() then
		if self.top_energy < log_data.energy then
			self.top_energy = log_data.energy
		end

		if log_data.energy == 0 then
			self.time_last_empty = 0
		end

		self.energy_delta = log_data.energy - self.energy
	end

	-- Update the current status
	for k, v in pairs(log_data) do
		self[k] = v
	end

	-- Store the log
	self.logs:push(log_data)
end

function Storage:getSummary()

	-- Return sth that fits in a 5x3 box
	-- [is_on, Name, Uptime, Steam]
	-- TODO Round numbers, pretty print
	return {
		self.energy > 0,
		self.name:gsub("Storage", "S"),
		commonlib.prettyInt(self.energy, 0),
		commonlib.prettyInt(self.energy_delta, 0, true)
	}
end

function Storage:getPage()

end
