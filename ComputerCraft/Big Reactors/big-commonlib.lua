-- 2017 m1cr0man
local classMetatable = {
	__call = function(self, ...)
		return self.new(...)
	end
}

-- Returns a string representation of an int
local sizes, kilo = {'K', 'M', 'B', 'T'}, 1000
function prettyInt(value, decimals, show_sign)
	local zeroes = math.floor(math.log(math.abs(value)) / math.log(kilo))
	local out_string = ("%%%s.%df%%s"):format(show_sign and "+" or "", decimals or 1)

	-- In computercraft, %.0f prints 1 decimal place. We have to use %d manually
	if decimals == 0 then
		out_string = ("%%%sd%%s"):format(show_sign and "+" or "")
	end
	return out_string:format(value / math.pow(kilo, zeroes), sizes[zeroes] or '')
end

-- Returns a nicer representation of a timestamp
function prettyDay(stamp)
	local stamp = math.floor(stamp)
	local days = math.floor(stamp / 24)
	if days > 0 then
		return ("%dd"):format(days)
	else
		return ("%dh"):format(stamp)
	end
end

-- Simple function to get a timestamp
function timestamp()
	return os.time() + (os.day() * 24)
end

function class(tbl)
	new_class = setmetatable(tbl or {}, classMetatable)
	new_class.__index = new_class
	return new_class
end

-- Stack class
Stack = class({max_size = math.maxinteger})

-- Stores the data in self
-- Saves space, means that #Stack works in all lua versions
-- That said it runs in O(logn) and my :length method is O(1)
function Stack.new(max_size)
	local self = setmetatable({}, Stack)
	self.size = 0

	-- Allocate all the mem for the stack now
	-- if max_size was defined
	if max_size then
		self.max_size = max_size
		for i = 1, max_size do
			self[i] = nil
		end
	end

	return self
end

function Stack:push(value)

	-- Stack full?
	if self.size == self.max_size then

		-- Rebuild the stack, shifting the keys up one and popping the first item off
		for i = 2, self.size do
			self[i - 1] = self[i]
		end
		self.size = self.size - 1
	end

	self.size = self.size + 1
	self[self.size] = value
end

function Stack:pop()
	if self.size == 0 then return end
	local value = self[self.size]
	self[self.size] = nil
	self.size = self.size - 1
	return value
end

function Stack:isEmpty()
	return self.size == 0
end

function Stack:peek()
	return self[self.size]
end

function Stack:length()
	return self.size
end

-- Queue class
Queue = class({max_size = math.maxinteger})

function Queue.new(max_size)
	local self = setmetatable({}, Queue)
	self.max_size = max_size or self.max_size
	self.enq_stack = Stack(max_size)
	self.deq_stack = Stack(max_size)
	return self
end

-- Interal use only - transfers data from enq to deq stack
function Queue:_swapStacks()
	if self.deq_stack:isEmpty() then
		while not self.enq_stack:isEmpty() do
			self.deq_stack:push(self.enq_stack:pop())
		end
	end
end

function Queue:push(value)

	-- Queue full?
	if self.enq_stack:length() + self.deq_stack:length() == self.max_size then

		-- Pop next value off
		if not self.deq_stack:isEmpty() then
			self.deq_stack:pop()
		end

		-- No need to pop from enq_stack, it will do that itself if it is full
	end

	self.enq_stack:push(value)
end

function Queue:pop()

	-- Move values from enq stack into deq stack
	self:_swapStacks()

	-- Get top item in deq stack
	if not self.deq_stack:isEmpty() then
		return self.deq_stack:pop()
	end
end

function Queue:isEmpty()
	return self.enq_stack:isEmpty() and self.deq_stack:isEmpty()
end

-- O(n) if the deq_stack is empty unfortunately
function Queue:peek()
	self:_swapStacks()
	return self.deq_stack:peek()
end

function Queue:length()
	return self.enq_stack:length() + self.deq_stack:length()
end

local function test()
	local test_stack = Stack(6)
	local test_stack_2 = Stack()
	for i = 1, 10 do
		test_stack:push(i)
		test_stack_2:push(i)
	end

	assert(test_stack:length() == 6, "Stack 1 has wrong length")
	assert(test_stack:length() == #test_stack, "Stack 1 length operators don't match")
	assert(test_stack_2:length() == 10, "Stack 2 has wrong length")
	assert(test_stack_2:length() == #test_stack_2, "Stack 2 length operators don't match")
	print(#test_stack, test_stack:length(), #test_stack_2, test_stack_2:length())
	for i = 1, 10 do
		print("1:", test_stack:pop(), "2:", test_stack_2:pop())
	end
	assert(test_stack:length() == 0, "Stack 1 not empty")
	assert(test_stack_2:length() == 0, "Stack 2 not empty")
	print("All stack tests passed")

	local test_queue = Queue(6)
	local test_queue_2 = Queue()
	for i = 1, 10 do
		test_queue:push(i)
		test_queue_2:push(i)
	end
	assert(test_queue:length() == 6, "Queue 1 has wrong length")
	assert(test_queue_2:length() == 10, "Queue 2 has wrong length")
	print(test_queue:length(), test_queue_2:length())
	for i = 1, 10 do
		print("1:", test_queue:pop(), "2:", test_queue_2:pop())
	end
	assert(test_queue:length() == 0, "Queue 1 not empty")
	assert(test_queue_2:length() == 0, "Queue 2 not empty")
	print("All queue tests passed")

	assert(prettyInt(999, 0) == "999", "prettyInt wrong for value 999")
	assert(prettyInt(-990000, 1) == "-990.0K", "prettyInt wrong for value 990000")
	print("All prettyInt tests passed")

	assert(prettyDay(23) == "23h", "prettyDay wrong for value 23")
	assert(prettyDay(85) == "3d", "prettyDay wrong for value 990000")
	print("All prettyDay tests passed")
end

test()
