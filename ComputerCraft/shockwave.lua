local argv = {...}

-- Blocks to drop when inventory is full
local blacklist = {
	"chisel",
	"cobblestone",
	"dirt"
}

-- Min and max gaps between torch placement
local min_torch_gap = 10
local max_torch_gap = 14

-- Slot to store torches
local torch_slot = 16

-- Slot to store ender chest
local chest_slot = 15

-- Last slot to use for items
local item_slot_max = 14

-- Sort out arguments
local num_rings = tonumber(argv[1]) or 5
local center_width = tonumber(argv[2]) or 4
local gap = tonumber(argv[3]) or 2
local start_ring = tonumber(argv[4]) or 1

-- Keep a record of what is found
local findings = {}
if (fs.exists("findings.txt")) then
	local file = io.open("findings.txt", "r")
	findings = textutils.unserialize(file:read("*a"))
	file:close()
end

-- Restacks items in the inventory
local function restack()
	local old_slot = turtle.getSelectedSlot()
	local inv_map = {}

	-- Restack all slots
	for slot = 1, item_slot_max do
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
			elseif turtle.getItemSpace(slot) > 0 then
				inv_map[full_name] = slot
			end
		end
	end
	turtle.select(old_slot)
end

-- Drops item on the blacklist
local function dropBlacklist()
	local dropped_stuff = false
	local old_slot = turtle.getSelectedSlot()
	for slot = 1, item_slot_max do
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
end

-- Deposit ores, refuel, and restock torches from ender chest
local function enderChestDeposit()
	local old_slot = turtle.getSelectedSlot()
	local has_refuelled = false

	-- Place the chest
	print("Depositing items")
	turtle.digDown()
	turtle.select(chest_slot)
	turtle.placeDown()

	-- Grab some torches
	-- Should be in first slot of the chest
	local num_torches = turtle.getItemSpace(torch_slot)
	turtle.select(torch_slot)
	turtle.suckDown(num_torches)

	-- Deposit resources
	for slot = 1, item_slot_max do
		turtle.select(slot)

		-- Grab some fuel from what's in our inventory
		-- before depositing it
		if not has_refuelled then
			has_refuelled = turtle.refuel(5)
		end

		turtle.dropDown()
	end

	-- Pick up the chest again
	turtle.select(chest_slot)
	turtle.digDown()
	turtle.select(old_slot)
	print("Done")
end

-- Gets the slot number of a free slot
-- Returns 0 if there are no free slots
local function getEmptySlot()
	for slot = 1, item_slot_max do
		if turtle.getItemCount(slot) == 0 then
			return slot
		end
	end
	return 0
end

local function makeEmptySlot()
	local options = {
		restack,
		dropBlacklist,
		enderChestDeposit
	}

	-- Try all the above options to free a slot
	-- enderChestDeopsit will always succeed
	local slot = getEmptySlot();
	for _, func in ipairs(options) do
		if slot ~= 0 then return slot end
		func()
		slot = getEmptySlot()
	end

	return true
end

local function placeTorchInternal()
	if turtle.detectDown() then return end
	local old_slot = turtle.getSelectedSlot()
	turtle.select(torch_slot)
	turtle.placeDown()
	turtle.select(old_slot)
	print("Placed torch")
end

local function placeTorch(column, distance)

	-- Don't place them too far apart
	local gap;
	for count = 2, distance do
		gap = distance / count
		if gap < max_torch_gap then break end
	end

	-- Place a torch at the right intervals
	if column == 1 or column % math.ceil(gap) == 0 then placeTorchInternal() end
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
	if not makeEmptySlot() then
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

local function digDistance(distance, skip_torches)
	for column = 1, distance do

		-- Record what we're digging
		inspectBlocks()

		-- Check there is enough fuel and space
		checkInventory()

		repeat until not turtle.digUp()

		-- Check item below isn't a torch and dig it
		local success, detail = turtle.inspectDown()
		if success and not detail.name:match("torch") then turtle.digDown() end

		-- Place a torch if necessary
		if not skip_torches then placeTorch(column, distance) end

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
			digDistance(gap + 1, true)
			turtle.turnLeft()
			digDistance(gap + 1, true)
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
	print(("Torches slot: %d\nEnder Chest slot: %d"):format(torch_slot, chest_slot))
	print("Press enter when ready")
	read()
	print("Starting")
	shockwave(num_rings, center_width)
	print("Done!")
end

main()
