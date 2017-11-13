-- PlayerScript.lua
require('Character')
require('Timer')
require('BossShip')
enemyManager = {}

function enemyManager:Create(scene)
	local result = character:Create(g_bulletFilePath)
	result.scene = scene
	result.name = "enemyManager"

	result.enemyWidth = 45

	--create a table that holds columns of enemies
	result.enemyColumns = {}
	--create a table that holds texture paths
	result.rowImages = {}
	--create a table that holds indexes per row for textures
	result.rowImageIndexes = {}

	--how far from the bottom of the screen will enemies end the game?
	--this is the offset
	result.enemyDeathBorderSize = 300
	--this is the actual position on the screen
	result.enemyDeathLimitPosition = result.scene.map.mapHeight*result.scene.map.tileSize - result.enemyDeathBorderSize
	
	--x minimum and maximum positions on the screen
	result.screenBorders = {min = 0, max = result.scene.map.mapWidth*result.scene.map.tileSize}

	--set up some positional values
	result.numColumns = 11
	result.numRows = 5
	--offset between each enemy(from left edge, to left edge)
	result.xPositionOffset = 60
	--offset between each enemy(from top edge, to top edge)
	result.yPositionOffset = 50

	--calculate the starting position of the enemies dependant on:
	--how many columns there are, whats the offset between the columns, and how wide is the map
	result.xPositionStart = ((result.scene.map.mapWidth*result.scene.map.tileSize) - (result.numColumns * result.xPositionOffset))/2 --200
	result.yPositionStart = 100
	--speed of the enemy bullets
	result.bulletSpeed = 300

	--a table which holds all the active bullets
	result.spawnedBullets = {}

	--set up textures and row textures
	result.rowImages[0] = "Assets\\XML\\Enemy1.xml"
	result.rowImages[1] = "Assets\\XML\\Enemy2.xml"
	result.rowImages[2] = "Assets\\XML\\Enemy3.xml"
	--this table sets which row of enemies uses which texture
	result.rowImageIndexes[0] = 0
	result.rowImageIndexes[1] = 1
	result.rowImageIndexes[2] = 1
	result.rowImageIndexes[3] = 2
	result.rowImageIndexes[4] = 2
	--are we alive
	result.isAlive = true

	--this is class that manages the boss
	result.boss = bossShip:Create()

	--create a minimum and maximum time for bullet spawn
	result.timeSpawnBullet = {min = 1, max = 2}
	--create a timer for bullet spawns and assign a random wait value
	result.bulletTimer = timer:Create(math.random(result.timeSpawnBullet.min, result.timeSpawnBullet.max))

	--how many units will enemies move per turn
	result.enemyMoveSpeed = 10

	--time between enemy moves
	result.moveDeltaTime = 0.75
	--how much does the speed increase when enemies go down a level
	result.enemyMoveSpeedIncrease = 0.8

	--timer for keeping track of enemy movement.
	result.movementTimer = timer:Create(result.moveDeltaTime)

	setmetatable(result, self)
	self.__index = self
	result:SpawnEnemies()
	return result
end

--update the enemy manager
function enemyManager:Update(deltatime)
	if self.isAlive == true then
		--move the enemies
		self:MoveEnemies(deltatime)
		
		--update the bullets of enemies
		self:UpdateBullets(deltatime)

		--update the boss manager
		self.boss:Update(deltatime)
	end
end

--loop through all our bullets, update them, and remove if they reach bottom of the screen
function enemyManager:UpdateBullets(deltatime)
	--get out if we are dead
	if self.isAlive == false then
		return nil
	end

	--update the timer for the bullet spawning
	self.bulletTimer:Update(deltatime)

	--check if we want to spawn a new bullets
	self:CheckSpawnBullet(deltatime)

	--Destroy each bullet thats out of bounds
	for i=#self.spawnedBullets,1,-1 do
		self.spawnedBullets[i]:Update(deltatime)
		if GetPosition(self.spawnedBullets[i].transform.this).y > (self.scene.map.tileSize*self.scene.map.mapHeight)-50 then
			self.spawnedBullets[i]:Destroy()
			table.remove(self.spawnedBullets, i)
		end
    end
end

--check if we need to spawn bullets dependant on a timer
function enemyManager:CheckSpawnBullet(deltatime)
	if self.bulletTimer.timeLeft <= 0 then
		--reset the timer for bullet spawns
		self.bulletTimer = timer:Create(math.random(self.timeSpawnBullet.min, self.timeSpawnBullet.max))
		self:SpawnBullet()
	end
end

--spawn a bullet
function enemyManager:SpawnBullet()
	if self.isAlive == false then
		--player is not alive, this should never happen.
		print("boo hoo not alive")
		return nil
	end
	--find which enemy should shoot this time
	local shootPosition = self:ChooseShootPosition()
	if shootPosition == nil then
		--this will happen if there are no enemies on the scene, this should never happen.
		print("boo hoo")
		return nil
	end

	--shoot the bullet
	local bullet = character:Shoot(shootPosition.x, shootPosition.y, 0, self.bulletSpeed, g_bulletFilePath)
	
	--add reaction to the bullet
	AddReaction(bullet.actor.BoxColliderComponent.this, "Player", "EnemyBulletPlayerReaction") --reaction for the player
	AddReaction(bullet.actor.BoxColliderComponent.this, "Wall", "EnemyBulletWallReaction") --reaction for the wall

	--add that bullet to the list of bullets to keep track of it.
	table.insert(self.spawnedBullets, bullet)
end

--a global reaction function for a player hit collision. This will call a local reaction function.
function EnemyBulletPlayerReaction(actor, other)
	g_currentScene.enemyManager:EnemyBulletPlayerReaction(actor, other)
end

--destroys the bullet that hit the player, and tells the player to take a hit.
function enemyManager:EnemyBulletPlayerReaction(actor, other)
	self:DestroyBulletByActor(actor)
	self.scene.player:OnHit()
end

--loops through all the spawned bullets and finds the one we have collided with. Destroys it when its found.
function enemyManager:DestroyBulletByActor(actor)
	--destroy the cpp actor of this actor
	DestroyActor(Logic.This, actor.this)
	for i = #self.spawnedBullets, 1, -1 do
		if actor == self.spawnedBullets[i].actor then
			--remove it from the spawned bullets table.
			table.remove(self.spawnedBullets, i)
		end
	end
end

--global reaction function for wall hit. will call the local reaction function
function EnemyBulletWallReaction(actor)
	g_currentScene.enemyManager:EnemyBulletWallReaction(actor)
end

--local reaction function for wall hit of a bullet. will tell the scene to destroy the tiles around the position of the bullet and destroy the bullet.
function enemyManager:EnemyBulletWallReaction(actor)
	self.scene.map:DestroyTilesAroundPosition(GetPosition(actor.TransformComponent.this), 5)
	self:DestroyBulletByActor(actor)
end

--pick a random column, from that choose an enemy thats on the bottom row, and return his positions.
function enemyManager:ChooseShootPosition()
	if self.enemyColumns == nil then
		--if the columns for enemies were not created or destroyed. This should never happen
		print("columns are nil")
		return nil
	end
	if #self.enemyColumns == 0 then
		--if the columns exist but there the not a single one left. This should never happen
		print("no columns")
		return nil
	end

	--pick a random column
	local randomColumn = math.random(1, #self.enemyColumns)
	local numEnemies = #self.enemyColumns[randomColumn]
	--get the last enemy from that column
	local enemy = self.enemyColumns[randomColumn][numEnemies]
	--get the position of the chosen enemy.
	local returnPosition = GetPosition(enemy.TransformComponent.this)
	--adding 100 offset pixels to the y position so the position does not collide with the current enemy position.
	returnPosition.y = returnPosition.y+100
	return returnPosition
end

-- should check the bottom of each column
function enemyManager:CheckEnemiesYLocation()
	--loops through all columns of enemies
	for i=1,#self.enemyColumns,1
	do
		if self.enemyColumns ~= nil then
			--get the amount of enemies in that column
			local numEnemies = #self.enemyColumns[i]
			--if that column has more enemies, then check that enemy's position
			if numEnemies > 0 then
				local enemy = self.enemyColumns[i][numEnemies]
		
				local returnPosition = GetPosition(enemy.TransformComponent.this)
				if returnPosition.y > self.enemyDeathLimitPosition then
					--finishes the game if any of the enemies reaches the limit of the Y location.
					self.scene:FinishGame()
				end
			end
		end
	end
end

--spawns a single enemy column with given x, and y starting position, an a yDelta
--as well as which column it is and how many rows to spawn
function enemyManager:SpawnEnemyColumn(xPosition, yStartPos, yDelta, numRows, columnIndex)
--create a new table under the current column index
	self.enemyColumns[columnIndex] = {}
	--for each row we want to create, spawn an enemy and assign its callback reactions
	for i=0,numRows-1,1
	do
		local filePath =  self.rowImages[self.rowImageIndexes[i]]
		local spawnedEnemy = SpawnActor(Logic.this, filePath)

		--add that enemy to the list of enemies under that column.
		table.insert(self.enemyColumns[columnIndex], spawnedEnemy)
		local tempTransform = spawnedEnemy.TransformComponent
		--offset that enemy so it matches into its appropriate x and y position
		tempTransform.Move(tempTransform.this, xPosition, (i * yDelta) + yStartPos)
	end
end

--moves the enemies down by the given moveOffset
function enemyManager:MoveEnemiesDown(moveOffset)
	--check if the enemy columns exist yet.
	if self.enemyColumns == nil then
		--this sohuld never happen.
		return nil
	end
	--swap movement direction
	self.enemyMoveSpeed = self.enemyMoveSpeed * -1
	--loops though all the columns, then through the rows in those columns
	--moves all the enemies under that row/column down by the offset
	for rowIndex,row in pairs(self.enemyColumns) do
		for enemyIndex,enemy in pairs(row) do
			local tempTransform = enemy.TransformComponent
			tempTransform.Move(tempTransform.this, 0, moveOffset)
		end
	end
	--increase the enemy move speed by the speed increase
	self.moveDeltaTime = self.moveDeltaTime * self.enemyMoveSpeedIncrease
end

--checks if we need to change our enemies movement direction
--Checks the left or right furthermost column location on the screen and checks if any enemy in that column has reached the edge of the screen
function enemyManager:CheckEnemiesDirectionSwitch()
	--initially set the lookup column as the 0'th column
	--this only applies if we are moving left
	local currentLookatColum = 1
	
	if #self.enemyColumns <= 0 then
		return
	end

	--if we are moving right then assign the lookup column as the size of the columns array
	if(self.enemyMoveSpeed > 0) then
		currentLookatColum = #self.enemyColumns
	end

	--make sure that there is at least 1 enemy in that column
	if #self.enemyColumns[currentLookatColum] <= 0 then
		--this should never happen.
		return nil
	end

	--get the transform component of the first enemy in the chosen column
	local furtherTransform = self.enemyColumns[currentLookatColum][1].TransformComponent;

	--get the position of that chosen enemy's transform component
	local pos = GetPosition(furtherTransform.this)

	--check if we have reached either side of the screen
	-- this has to be offset because we check the offset by the left edge of the enemy
	if pos.x >= self.screenBorders.max - self.enemyWidth and self.enemyMoveSpeed > 0 then
		self:MoveEnemiesDown(self.yPositionOffset)
	elseif pos.x < self.screenBorders.min and self.enemyMoveSpeed <= 0 then
		self:MoveEnemiesDown(self.yPositionOffset)
	end
end

--kill the given enemy and clean up columns and rows.
function enemyManager:KillEnemy(enemy)
	for i=#self.enemyColumns,1,-1 do
		for j = #self.enemyColumns[i], 1, -1 do 
			if enemy == self.enemyColumns[i][j] then
				self:CalculateScore(j)
				--destroy the enemy right here
				DestroyActor(Logic.this, enemy.this)
				table.remove(self.enemyColumns[i], j)
				--check if the column is empty
				if #self.enemyColumns[i] <= 0 then
					--remove that column
					table.remove(self.enemyColumns, i)
					if #self.enemyColumns == 0 then
						--finish the game when the last enemy is killed.
						self.scene:FinishGame()
						return nil
					end
				end
			end
		end
	end
end

--kills the saucer boss
function enemyManager:KillBoss()
	--add points to the score tracker.
	self.scene.scoreTracker:AddScore(self.boss:GetScore())
	--kill the boss
	self.boss:Destroy()
end

--calculate how much score to give by the column index of the enemy.
function enemyManager:CalculateScore(enemyKilled)
	if enemyKilled == 1 then
		self.scene.scoreTracker:AddScore(30)
	elseif enemyKilled == 2 or enemyKilled == 3 then
		self.scene.scoreTracker:AddScore(20)
	elseif enemyKilled == 4 or enemyKilled == 5 then
		self.scene.scoreTracker:AddScore(10)
	end
end

--spawn all the needed enemies into the game
function enemyManager:SpawnEnemies()
	for i=0,self.numColumns-1,1
	do
		--spawn all the columns of enemies that we need.
		self:SpawnEnemyColumn(self.xPositionStart +(self.xPositionOffset * i), self.yPositionStart, self.yPositionOffset, self.numRows, i+1)
	end
end

-- moves enemies the direction they are moving
function enemyManager:MoveEnemies(deltatime)
	--updates the timer
	self.movementTimer:Update(deltatime)
	if self.movementTimer.timeLeft > 0 then
		--we get out if the timer is not done yet, we will move another frame.
		return nil
	end

	--creates a new timer for the enemy movement.
	self.movementTimer = timer:Create(self.moveDeltaTime)

	--for each column of enemies, move that enemy in direction of a global movement direction speed
	for rowIndex,row in pairs(self.enemyColumns) do
		for enemyIndex,enemy in pairs(row) do
			local tempTransform = enemy.TransformComponent
			tempTransform.Move(tempTransform.this, self.enemyMoveSpeed , 0)
		end
	end
	
	--check if we need to change our movement direction
	self:CheckEnemiesDirectionSwitch()

	--check if the enemies need to move down
	self:CheckEnemiesYLocation()
end

--destroy all enemies and the boss
function enemyManager:Destroy()
	
	self.isAlive = false
	--destory the boss ship
	self.boss:Destroy()
	
	--destroy enemies
	if self.enemyColumns ~= nil then
		for rowIndex,row in pairs(self.enemyColumns) do
			for enemyIndex,enemy in pairs(row) do
				DestroyActor(Logic.this, enemy.this)
				enemy.actor = nil
			end
		end
	end

	--destroy the bullets
	for i=#self.spawnedBullets,1,-1
	do
		DestroyActor(Logic.this, self.spawnedBullets[i].actor.this)
		table.remove(self.spawnedBullets, i)
	end
	self.enemyColumns = nil
end
