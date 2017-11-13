-- Scene.lua
scene = {}

function scene:Create(name)
	local result = {}

	result.name = name

	setmetatable(result, self)
	self.__index = self
	return result
end
