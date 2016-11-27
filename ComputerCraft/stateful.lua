local state_file = "state.log"
local oem_turtle = turtle
local results = {}
local fast_forwarding = 0

turtle = {}

-- Proxy all the functions
for name, func in pairs(oem_turtle) do
	if type(func) == "function" then
		turtle[name] = function(...)

			-- Just booted - load ff data
			if fast_forwarding == 0 and fs.exists(state_file) then
				local file = io.open(state_file, "r")
				results = textutils.unserialize(file:read("*a"))
				file:close()
				fast_forwarding = 1
			end

			fast_forwarding = fast_forwarding + 1

			-- Fast-forward
			if fast_forwarding <= #results then
				return results[fast_forwarding - 1]
			end

			-- Running
			local result = func(...)
			table.insert(results, result)

			local file = io.open(state_file, "w")
			file:write(textutils.serialize(results))
			file:close()

			return result
		end
	end
end

function turtle.finish()
	if fs.exists(state_file) then
		fs.delete(state_file)
	end
end

print("Turtle now in stateful mode")