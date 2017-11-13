-- Bullet.lua
bullet = {}

function bullet:Create(xPos, yPos, xVel, yVel, imagePath)
	local result = {}

	--visual image
	result.bulletFilePath = imagePath

	--position
	result.position = {}
	result.position.x = xPos
	result.position.y = yPos

	--velocity
	result.velocity = {}
	result.velocity.x = xVel
	result.velocity.y = yVel

	--spawn the bullet and save out the c++ glue actor
	result.actor = SpawnActor(Logic.this, result.bulletFilePath)
	--get the transform component
	result.transform = result.actor.TransformComponent
	--move the bullet in the spawn position
	result.transform.Move(result.transform.this, xPos, yPos)


	setmetatable(result, self)
	self.__index = self
	return result
end

function bullet:Update(deltatime)
--keep moving the bullet in its direction as long as its alive.
	if self.actor ~= nil then 
		self.transform.Move(self.transform.this, self.velocity.x * deltatime , self.velocity.y * deltatime)
	end
end

--destroy self.

function bullet:Destroy()
	DestroyActor(Logic.this, self.actor.this)
end