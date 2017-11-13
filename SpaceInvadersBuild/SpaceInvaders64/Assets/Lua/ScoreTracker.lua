-- ScoreTracker.lua
require('String')
require('HighScoreReadWrite')
scoreTracker = {}

function scoreTracker:Create(scene)
	local result = {}
	result.score = 0
	
	--offset from the "score" label to the actual score
	result.scoreNumberOffset = 240
	result.startPos = {x = result.scoreNumberOffset, y = (scene.map.mapHeight *scene.map.tileSize)-60}
	result.scoreLabel = string:Create(result.startPos, "score")
	result.highScoreLabel = string:Create({x = result.startPos.x, y = result.startPos.y + 60}, "high score")
	result.highScoreText  = string:Create({x = result.startPos.x+ 440, y = result.startPos.y + 60}, "100")
	result.scoreText = string:Create({x = result.startPos.x + result.scoreNumberOffset, y = result.startPos.y}, "score")
	
	-- creates highScoreReadWrite and assigns high score and low score
	result.fileWrite = highScoreReadWrite:Create()
	local scoresTable = result.fileWrite:GetTopScores()
	result.lowScore = scoresTable[#scoresTable].score
	result.highscore = scoresTable[1].score

	setmetatable(result, self)
	self.__index = self
	result:LoadScore()
	result:UpdateScore()
	return result
end

-- adds score to the current score
function scoreTracker:AddScore(addScore)
	self.score = self.score+addScore
	self:UpdateScore()
end

-- loads the highest score and puts in on screen
function scoreTracker:LoadScore()
	local tempTable = {}
	tempTable = self.fileWrite:GetTopScores()
	self.highScoreText:ChangeText(tostring(tempTable[1].score))
end

--updates the visual of the score.
function scoreTracker:UpdateScore()
	self.scoreText:ChangeText(tostring(self.score))
end


function scoreTracker:SpawnNumber(number, posX, posY)
	local image = SpawnActor(Logic.this, self.images[number])
	image.TransformComponent.Move(image.TransformComponent.this, posX, posY)
	table.insert(self.scoreImages, image)
end

-- destroy
function scoreTracker:Destroy()
	self.highScoreLabel:Destroy()
	self.highScoreText:Destroy() 
	self.scoreLabel:Destroy()
	self.scoreText:Destroy()	
end

-- if the score is higher than the lowest score then save to temp
function scoreTracker:SaveScore()
	if self.lowScore < self.score then
		self.fileWrite:SaveTempScore(self.score)
	end
end