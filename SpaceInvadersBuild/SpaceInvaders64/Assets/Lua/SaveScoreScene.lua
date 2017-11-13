-- HighScoreScene.lua
require('Scene')
require('String')
require('HighScoreReadWrite')
saveScoreScene = {}

-- sets up saveScoreScene
function saveScoreScene:Create()
	local result = scene:Create("high scores")
	result.isLoaded = false
	result.name = "high scores"
	result.index = 1
	result.currentCharacter = 'a'
	result.savedCharacters = {}
	result.savedScoreFile = "Assets\\Highscores\\newSavedScore.txt"
	
	result.fileWrite = highScoreReadWrite:Create()

	result.menuSize = 500
	result.windowWidth = 900
	result.alphabet = 'abcdefghijklmnopqrstuvwxyz' 

	-- spawns saveScoreScene actor
	local spawnPosition = {x = (result.windowWidth - result.menuSize)/2, y = 100}
	result.actor = SpawnActor(Logic.this, "Assets\\XML\\SaveScoreScene.xml")
	result.transform = result.actor.TransformComponent
	result.transform.Move(result.transform.this, spawnPosition.x, spawnPosition.y)

	result.newHighScorePos = {x = 200, y = 200}
	result.newHighScore = string:Create(result.newHighScorePos, "new high score")
	
	-- sets up table for player initials/name in high score
	result.charTextCount = 1
	result.startPosX = 300
	result.startPosY = 300
	result.charText = {}
	result.charText[result.charTextCount] = string:Create({x = result.startPosX, y = result.startPosY}, result.currentCharacter)
	local scoreToPrint = result.fileWrite:GetTempScore()
	result.newScore = string:Create({x = result.startPosX +(40*4), y = result.startPosY}, tostring(scoreToPrint))
	
	setmetatable(result, self)
	self.__index = self
	result.isLoaded = true
	return result
end

-- updates the current character that is showing on screen
-- for the players initials
function saveScoreScene:UpdateChar()
	self.currentCharacter = self.alphabet:sub(self.index, self.index)
	self.charText[self.charTextCount]:ChangeText(self.currentCharacter)
end

-- cleans up everything
function saveScoreScene:Destroy()
	if self.newScore ~= nil then
		self.newScore:Destroy()
	end
	if self.actor ~= nil then
		DestroyActor(Logic.this, self.actor.this)
	end
	self.newHighScore:Destroy()
	
	for i = self.charTextCount,1,-1 do
		self.charText[i]:Destroy()
	end
	
end

-- takes player input and uses it to save characters,
-- cylce through the alphabet according to player input
-- also creates and stores player text
function saveScoreScene:Update(deltatime)
	local input = GetCommand(InputSystem.this)
	if input == "m" then
		ChangeScene(1)
	elseif input == "w" then
		self.index = self.index + 1
		if self.index > #self.alphabet then
			self.index = 1
		end
	elseif input == "s" then
		self.index = self.index - 1
		if self.index < 1 then
			self.index = #self.alphabet
		end
	elseif input == "return" then
		if self.charTextCount <= 3 then
			self.charTextCount = self.charTextCount+1
			self:StoreAndCreateText()
		end
	end
	self:UpdateChar()
	
	if #self.savedCharacters > 2 then
		self:SaveScoreToFile()
		ChangeScene(3)
	end
end

-- stores the character in a table and creates a new charText to show on screen
function saveScoreScene:StoreAndCreateText()
	table.insert(self.savedCharacters, self.currentCharacter)
	self.startPosX = self.startPosX + 40
	self.charText[self.charTextCount] = string:Create({x = self.startPosX, y = 300}, self.currentCharacter)
end

-- saves score
function saveScoreScene:SaveScoreToFile()
	self.fileWrite:SaveScore(self.savedCharacters)
end
