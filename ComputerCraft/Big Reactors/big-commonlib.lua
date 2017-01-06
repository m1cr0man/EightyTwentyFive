local function forkClass(parent, new_obj)
	new_obj = new_obj or {}
	setmetatable(new_obj, parent)
	parent.__index = parent
	return new_obj
end

-- Stack class
local Stack = {max_size = math.maxinteger}

function Stack:new(max_size)
	local new_obj = forkClass(self)
	self.storage = {}
	self.size = 0

	if max_size then
		self.max_size = max_size

		for i = 1, max_size do
			self.storage[i] = nil
		end
	end

	return new_obj
end

function Stack:push(value)

	-- Stack full?
	if self.size == self.max_size then

		-- Rebuild the stack, shifting the keys up one and popping the first item off
		for i = 2, self.size do
			self.storage[i - 1] = self.storage[i]
		end
		self.size = self.size - 1
	end

	self.size = self.size + 1
	self.storage[self.size] = value
end

function Stack:pop()
	if self.size == 0 then return end
	local value = self.storage[self.size]
	sself.storage[self.size] = nil
	self.size = self.size - 1
	return value
end

function Stack:isEmpty()
	return self.size == 0
end

function Stack:peek()
	return self.storage[self.size]
end

function Stack:length()
	return self.size
end

-- Queue class
local Queue = {max_size = math.maxinteger}

function Queue:new(max_size)
	local new_obj = forkClass(self)
	self.max_size = max_size or self.max_size
	self.enq_stack = Stack:new(max_size)
	self.deq_stack = Stack:new(max_size)
	return new_obj
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

-- O(n) if the deq_stack is empty unfortunately
function Queue:peek()
	self:_swapStacks()
	return self.deq_stack:peek()
end

function Queue:length()
	return self.enq_stack:length() + self.deq_stack:length()
end

local function test()
	
end

test()
