-- Character.lua
require('Bullet')
character = {}

function character:Create(bulletPath)
	local result = {}
	result.bulletFilePath = bulletPath
	result.name = "noName"

	setmetatable(result, self)
	self.__index = self
	return result
end

function character:Shoot(xPos, yPos, xVel, yVel, bulletFilePath, functionCallback)
	return bullet:Create(xPos, yPos, xVel, yVel, bulletFilePath, functionCallback)
end