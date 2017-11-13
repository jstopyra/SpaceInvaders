-- BossShip.lua
require('Character')
require('Timer')
bossShip = {}

function bossShip:Create()
	local result = character:Create(g_bulletFilePath)

	result.bossFilePath = "Assets\\XML\\Ship.xml"
	--actor table that links with c++
	result.actor = nil
	--transform of the current ship
	result.transform = nil
	
	result.moveSpeed = 250
	result.leftStartPos = -100
	result.rightStartPos = 900
	result.leftSpawn = true

	--possible scores the player can get
	-- possible scores
	-- 50, 100, 150, 300
	result.possibleScores = {50, 100, 150, 300}
	
	--spawn a timer, assign a random timer value, and tick it from this class
	result.timeSpawnBoss = {min = 5, max = 10}
	result.bossTimer = timer:Create(math.random(result.timeSpawnBoss.min, result.timeSpawnBoss.max))

	setmetatable(result, self)
	self.__index = self
	return result
end

--gets a random score from a list of possible scores
function bossShip:GetScore()
	return self.possibleScores[math.random(1, #self.possibleScores)]
end

--updates all logic for boss ship
function bossShip:Update(deltatime)

	--tick a spawner timer
	self.bossTimer:Update(deltatime)
	
	--try moving currently spawned ship
	self:Move(deltatime)
	
	--check if the ship is out of bounds(will delete the actor)
	self:CheckBounds()
	
	--check if we want to spawn a new boss(only spawns it if there is no current boss)
	self:CheckBossSpawn(deltatime)
end

--move the current transform boss by its movement speed to the east.
function bossShip:Move(deltatime)
	--make sure we have a transform
	if self.actor ~= nil then
	--move the actor in the current direction
		self.transform.Move(self.transform.this, self.movementSpeed*deltatime, 0)
	end
end

--check if the timer has reached 0, if so, spawn a boss
function bossShip:CheckBossSpawn(deltatime)
	if self.bossTimer.timeLeft <= 0 and self.actor == nil then
		self:SpawnBoss()
		--reset the timer
		self.bossTimer = timer:Create(math.random(self.timeSpawnBoss.min, self.timeSpawnBoss.max))
	end
end

--spawns a new boss and assigns the transform as well as the c++ glue actor.
function bossShip:SpawnBoss()
	self.actor = SpawnActor(Logic.this, self.bossFilePath)
	self.transform = self.actor.TransformComponent
	
	-- swaps what side the boss spawns
	if self.leftSpawn == true then
		self.startPos = {x = self.leftStartPos, y = 20}
		self.movementSpeed = self.moveSpeed
		self.leftSpawn = false
	else
		self.startPos = {x = self.rightStartPos, y = 20}
		self.movementSpeed = -self.moveSpeed
		self.leftSpawn = true
	end
	
	--move the boss ship into place.
	self.transform.Move(self.transform.this, self.startPos.x, self.startPos.y)
end

-- checks if the boss has flown outside of the playable area and destroys it if it has
function bossShip:CheckBounds()	
	if self.actor ~= nil then
		local returnPosition = GetPosition(self.transform.this)
		if returnPosition.x < self.leftStartPos  or returnPosition.x > self.rightStartPos then
			--we're out of bounds, destroy the ship
			self:Destroy()
		end
	end
end

--destroy the ship boss
function bossShip:Destroy()
	if self.actor ~= nil then
		DestroyActor(Logic.this, self.actor.this)
		self.actor = nil
		self.transform = nil
	end
end