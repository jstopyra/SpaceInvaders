-- Timer.lua
timer = {}

--timer class that has a start time, end time, time left, and time passed
--wait time is the time we want the timer to run for
function timer:Create(waitTime)
	local result = {}

	--take the current time of the running game.
	result.startTime = os.clock()
	result.finishTime = result.startTime + waitTime
	result.timeLeft = waitTime
	result.timePassed = 0

	setmetatable(result, self)
	self.__index = self
	return result
end

--has to be run every frame to work properly.
--calculates time left and time passed.
function timer:Update(deltatime)
	self.timeLeft = self.timeLeft-deltatime
	self.timePassed = (self.finishTime - self.startTime)- self.timeLeft
end