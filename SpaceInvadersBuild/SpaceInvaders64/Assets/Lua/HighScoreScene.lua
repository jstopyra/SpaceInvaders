-- HighScoreScene.lua
require('Scene')
require('HighScoreReadWrite')
highScoreScene = {}

function highScoreScene:Create()
	local result = scene:Create("high scores")
	result.isLoaded = false

	result.name = "high scores"
	result.fileWrite = highScoreReadWrite:Create()
	result.sizeOfText = 40 * #result.name
	result.windowWidth = 900

	-- sets up high score message printed on top
	local spawnPosition = {x = (result.windowWidth - result.sizeOfText)/2, y = 100}
	result.highScoreMessage = string:Create({x = spawnPosition.x, y = spawnPosition.y-50}, "high score")
	
	-- sets up table of high scores and puts them on screen
	result.scoreText = {}
	result.scores = result.fileWrite:GetTopScores()
	result.scoreStartY = spawnPosition.y
	for i=1, #result.scores,1 do
		local scoreItem = result.scores[i].name
		result.scoreText[i] = string:Create({x = 300, y = result.scoreStartY}, result.scores[i].name.." "..tostring(result.scores[i].score))
		result.scoreStartY = result.scoreStartY + 50
	end

	setmetatable(result, self)
	self.__index = self
	result.isLoaded = true
	return result
end

-- cleans up everything
function highScoreScene:Destroy()
	self.highScoreMessage:Destroy();
	if self.actor ~= nil then
		DestroyActor(Logic.this, self.actor.this)
	end
	for i=#self.scoreText,1,-1 do
		self.scoreText[i]:Destroy()
	end
	
end

-- checks if we want to switch to the menu
function highScoreScene:Update(deltatime)
	local input = GetCommand(InputSystem.this)
	if input == "m" or  input == "q" then
		ChangeScene(1)
	end
end
