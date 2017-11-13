-- PlayerScript.lua
require('Character')
player = {}


function player:Create(scene)
	local result = character:Create(g_bulletFilePath)
	--save out the scene we're in
	result.scene = scene
	result.name = "Player"
	--spawn the player actor
    result.actor = SpawnActor(Logic.this, "Assets\\XML\\Player.xml")
	--transform component of the player actor
	result.transform = result.actor.TransformComponent

	--this table holds our hear visuals
    result.hearts = {}
	--initial health of the player
	result.health = 3
	
	--player sprite, just so we know where to shoot and where the edge of the screen is
	result.spriteWidth = 64
	result.spriteHeight = 39

	--how far towards the edge of the screen can we get
	result.movementBorder = 50
	result.movementLimit = {min = result.movementBorder - result.spriteWidth/2, max = (result.scene.map.mapWidth * result.scene.map.tileSize)-result.movementBorder - result.spriteWidth/2}

	--movement speed of the player
	result.moveSpeed = 500

	--our bullet
	result.bullet = nil
	result.bulletSpeed = 900

	setmetatable(result, self)
	self.__index = self
	--creates the heart images.
	result:CreateHearts()
	return result
end

--spawns player hearts on the screen
function player:CreateHearts()
	--offset between the hearts
	local offset = 70
	for i=1,self.health do
		--spawn the heart
		local heart = SpawnActor(Logic.this, "Assets\\XML\\Heart.xml")
		table.insert(self.hearts, heart)
		--move the heart image by an offset
		heart.TransformComponent.Move(heart.TransformComponent.this, (i-1)*offset, self.scene.map.mapHeight*self.scene.map.tileSize-60)
	end
end

--lose a heart will destroy the heart and remove it from the table.
function player:LoseHeart()
	--decrease health
	self.health = self.health -1
	DestroyActor(Logic.this, self.hearts[#self.hearts].this)
	table.remove(self.hearts, #self.hearts)
end

--handle player's movement and bullet 
function player:Update(deltatime)
	self:HandleMovement(deltatime)
	self:HandleBullet(deltatime)
end


--handle player's bullet movement
function player:HandleBullet(deltatime)
	if self.bullet ~= nil then
		self.bullet:Update(deltatime)
		--if our bullet is at the top of the screen the nill it. --position 20 on y is 20 pixels past the screen border
		if GetPosition(self.bullet.transform.this).y < 20 then
			DestroyActor(Logic.this, self.bullet.actor.this)
			self.bullet = nil
		end
	end
end

function player:HandleMovement(deltatime)
	--read out input from c++ engine
	local input = GetCommand(InputSystem.this)
	local movementDirX = 0
	local movementDirY = 0
	
	--we want to move west
	if input == "a" then
	--check if player's position x is still within our min limit
		local playerPos = GetPosition(self.transform.this)
		if playerPos.x > self.movementLimit.min then
		--we can move west
			movementDirX = -1
		end
	--we want to move east
	elseif input == "d" then
	--check if player's position x is still within our max limit
		local playerPos = GetPosition(self.transform.this)
		if playerPos.x < self.movementLimit.max then
		--we can move east
			movementDirX = 1
		end
	elseif input == "space" then
	--?? why can I not call self:Shoot()
	--only create a bullet if one does not already exist
		if self.bullet == nil then
			local playerPos = GetPosition(self.transform.this)
			local xPos = playerPos.x+(self.spriteWidth/2)-4
			local yPos = playerPos.y---self.spriteHeight
		
			self.bullet = character:Shoot(xPos, yPos, 0, -self.bulletSpeed, g_bulletFilePath)
			--add callback functions to the bullets
			AddReaction(self.bullet.actor.BoxColliderComponent.this, "Enemy", "GlobalBulletEnemyHit")
			AddReaction(self.bullet.actor.BoxColliderComponent.this, "Wall", "GlobalBulletWallHit")
			AddReaction(self.bullet.actor.BoxColliderComponent.this, "Boss", "GlobalBulletBossHit")
		end
	end
	--at last, move the player by the chosen direction and the speed.
	self.transform.Move(self.transform.this, self.moveSpeed * movementDirX * deltatime, self.moveSpeed * movementDirY * deltatime)
end

--when the players gets hit, remove a health, and lose a heart
function player:OnHit()
	--decrements health and gets rid of heart visuals
	self:LoseHeart()
	--finish the game if we're dead
	if self.health <= 0 then
		self.scene:FinishGame()
	end
end

--destroy the player and the bullet.
function player:Destroy()
	
	--keep destroying hearts when there is more than 0
	while self.health > 0 do
		self:LoseHeart()
	end

	if self.bullet ~= nil then
		self.bullet:Destroy()
	end
	--destroys the player
	DestroyActor(Logic.this, self.actor.this)
end

--global callback for hitting an enemy
function GlobalBulletEnemyHit(actor, other)
	g_currentScene.player:LocalBulletEnemyHit(actor, other)
end

--local callback for hitting an enemy
function player:LocalBulletEnemyHit(actor, other)
	DestroyActor(Logic.this, actor.this)
	self.bullet = nil
	self.scene.enemyManager:KillEnemy(other)
end

--global callback for hitting a wall
function GlobalBulletWallHit(actor)
	g_currentScene.player:LocalBulletWallHit(actor)
end

--local callback for hitting a wall
function player:LocalBulletWallHit(actor)
--destroy the bullet and destory tiles around the position of that bullet
	local position = GetPosition(actor.TransformComponent.this)
	self.scene.map:DestroyTilesAroundPosition(position, 5)
	DestroyActor(Logic.this, actor.this)
	self.bullet = nil
end

--global callback for hitting a saucer
function GlobalBulletBossHit(actor, other)
	g_currentScene.player:LocalBulletBossHit(actor, other)
end

--local callback for hitting a saucer
function player:LocalBulletBossHit(actor, other)
	--kills the boss
	self.scene.enemyManager:KillBoss()
	
	--destroys the bullet
	DestroyActor(Logic.this, actor.this)
	self.bullet = nil
end