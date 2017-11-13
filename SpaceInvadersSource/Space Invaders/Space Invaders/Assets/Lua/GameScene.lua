-- GameScene.lua
require('Scene')
require('PlayerScript')
require('EnemyManager')
require('Map')
require('ScoreTracker')
gameScene = {}

--"static" size of the map for ease of access to easily change.
tileSize = 8
mapWidth = 113
mapHeight = 113

--[Jakub] to be honest, the only reason this is here is because right now everyone uses the same
--file for bullet, when that changes(if that changes) this will be moved to separate classes.
g_bulletFilePath = "Assets\\XML\\Bullet.xml"

function gameScene:Create()
	local result = scene:Create("game")
	result.isLoaded = false
	
	--all the objects we will be updating.
	result.updatableObjects = {}
	result.name = "game"
	RefreshMap(Logic.this)
	--create the map data
	result.map = map:Create(tileSize, mapWidth, mapHeight, result)
	result.scoreTracker = scoreTracker:Create(result)

	--create the player
	result.player = player:Create(result)
	table.insert(result.updatableObjects, result.player)

	--create enemy manager
	result.enemyManager = enemyManager:Create(result)
	table.insert(result.updatableObjects, result.enemyManager)

	setmetatable(result, self)
	self.__index = self
	result.isLoaded = true
	return result
end

function gameScene:Update(deltatime)
	
	local input = GetCommand(InputSystem.this)
	if input == "q" then
		--main menu
		ChangeScene(1)
	end
	--update major systems of the lua layer
	for i=1,#self.updatableObjects do
		self.updatableObjects[i]:Update(deltatime)
	end
end

--check if we want to save the score and go to high score scene or save scene score accordingly.
function gameScene:FinishGame()
	if self.scoreTracker.score > self.scoreTracker.lowScore then
		--goes to save score scene
		ChangeScene(4)
	else
		--goes to high score scene
		ChangeScene(3)
	end
end

--destroys the scene
function gameScene:Destroy()
	--saves players score as a temp value
	self.scoreTracker:SaveScore()
	--destroy the player
	self.player:Destroy()
	--destroys the enemy manager
	self.enemyManager:Destroy()
	--destroys the map
	self.map:Destroy()
	--destroys the score tracker
	self.scoreTracker:Destroy()
end
