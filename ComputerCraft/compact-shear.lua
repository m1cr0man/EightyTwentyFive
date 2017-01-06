shell.run('stateful')

local interval = 360
local box_size = 11
local pen_size = 2
local l, r = turtle.turnLeft, turtle.turnRight

local function f()
	turtle.attackDown()
	turtle.forward()

	-- Check if the chest is above
	-- Deposit wool if so
	if turtle.detectUp() then
		for slot = 1, 16 do
			turtle.select(slot)
			turtle.dropUp()
		end
		turtle.select(1)
	end
end

local function main()
	-- Figure out where we're starting
	l()
	local turn = turtle.detect() and r or l
	r()

	local row = 1
	while row <= box_size do
		repeat f() until turtle.detect()
		turn()
		f()

		-- Jump the fence
		if (row + 1) % (pen_size + 1) == 0 then
			f()
			row = row + 1
		end

		turn()

		-- Turn the other way next
		turn = turn == r and l or r
		row = row + 1
	end
end

main()
turtle.finish()
print(("Done! Next shear in %d seconds..."):format(interval))
os.sleep(interval)
os.reboot()
