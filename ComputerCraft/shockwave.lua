local argv = {...}

-- Blocks to drop when inventory is full
local blacklist = {
	"chisel",
	"cobblestone",
	"dirt"
}
local torch_gap = 15

local num_rings = tonumber(argv[1]) or 5
local center_width = tonumber(argv[2]) or 4
local gap = tonumber(argv[3]) or 2
local start_ring = tonumber(argv[4]) or 1
local torch_distance = 0
local findings = {}
if (fs.exists("findings.txt")) then
	local file = io.open("findings.txt", "r")
	findings = textutils.unserialize(file:read("*a"))
	file:close()
end

local function refuel(quant)
	local old_slot = turtle.getSelectedSlot()
	for slot = 1, 15 do
		turtle.select(slot)
		if turtle.refuel(quant) then break end
	end
	turtle.select(old_slot)
end

local function restack()
	local old_slot = turtle.getSelectedSlot()
	local inv_map = {}
	for slot = 1, 15 do
		local detail = turtle.getItemDetail(slot) or {}
		if detail.name then
			local full_name = detail.name .. '#' .. detail.damage or 0
			if inv_map[full_name] then
				turtle.select(slot)
				turtle.transferTo(inv_map[full_name])
				print("Restacked " .. full_name)

				-- If the stack is full, move new stuff to the current slot
				if turtle.getItemSpace(inv_map[full_name]) == 0 then
					inv_map[full_name] = slot
				end
			else
				inv_map[full_name] = slot
			end
		end
	end
	turtle.select(old_slot)
end

local function getEmptySlot()

	-- Attempt to free a slot just by moving things around
	restack()

	for slot = 1, 15 do
		if turtle.getItemCount(slot) == 0 then
			return slot
		end
	end
	return 0
end

local function dropBlacklist()
	local dropped_stuff = false
	local old_slot = turtle.getSelectedSlot()
	for slot = 1, 15 do
		local detail = turtle.getItemDetail(slot) or {}
		for _, word in pairs(blacklist) do
			if detail.name:find(word) then
				turtle.select(slot)
				turtle.drop()
				dropped_stuff = true
				print("Dropped " .. word)
				break
			end
		end
	end
	turtle.select(old_slot)
	return dropped_stuff
end

local function placeTorch()
	if torch_gap ~= torch_distance then
		torch_distance = torch_distance + 1
		return
	end
	turtle.select(16)
	turtle.placeDown()
	turtle.select(1)
	torch_distance = 0
	print("Placed torch")
end

local function checkInventory()

	-- Check if we need fuel and refuel if so
	local quant = 1
	while turtle.getFuelLevel() < 2 do
		refuel(quant)
		if turtle.getFuelLevel() >= 2 then break end
		print("Add fuel and (enter refuel quantity or) press enter")
		quant = tonumber(read()) or quant
	end

	-- Check if inventory is full
	-- Try to free space
	if getEmptySlot() == 0 and not dropBlacklist() then
		print("Clear inventory space and press enter")
		read()
	end
end

local function inspectBlocks()
	for _, dir in pairs({"", "Up", "Down"}) do
		local scan = (select(2, turtle["inspect" .. dir]()) or {})
		if scan.name then
			local full_name = scan.name .. '#' .. tonumber(scan.metadata)
			findings[full_name] = (findings[full_name] or 0) + 1
		end
	end
	local file = io.open("findings.txt", "w")
	file:write(textutils.serialize(findings))
	file:close()
end

local function digDistance(distance)
	for column = 1, distance do

		-- Record what we're digging
		inspectBlocks()

		-- Check there is enough fuel and space
		checkInventory()

		repeat until not turtle.digUp()
		turtle.digDown()

		-- Place a torch if necessary
		placeTorch()

		repeat turtle.dig() until turtle.forward()
	end
end

local function shockwave(num_rings, center_width)

	for ring = start_ring, num_rings do
		for side = 1, 4 do
			print(("Ring #%d Side #%d"):format(ring, side))
			digDistance((center_width - 1) + (gap + 1) * 2 * (ring - 1))

			-- Move to next side (if not looped around already)
			-- If statement to save an unnecessary turn at the end
			if side ~= 4 then
				turtle.turnRight()
			end
		end

		-- Move to next ring
		if ring ~= num_rings then
			digDistance(gap + 1)
			turtle.turnLeft()
			digDistance(gap + 1)
			for _ = 1, 2 do turtle.turnLeft() end
		end
	end
end

local function main()
	if #argv < 3 then
		print("Insufficient arguments, proceed? [y/n]")
		if read() ~= "y" then
			return
		end
	end
	print("Make sure torches are in slot 16 and press enter")
	read()
	print("Starting")
	shockwave(num_rings, center_width)
	print("Done!")
end

main()
