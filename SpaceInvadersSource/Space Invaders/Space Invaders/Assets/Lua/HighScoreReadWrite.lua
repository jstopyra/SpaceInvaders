--HighScoreReadWrite
require('String')
highScoreReadWrite = {}

-- sets up highScoreReadWrite
function highScoreReadWrite:Create()
	local result = {}
	
	result.filePath = "Assets\\Highscores\\highscores.txt"
	result.tempScore = "Assets\\Highscores\\temp.txt"
	result.maxScoreCount = 5
	
	setmetatable(result, self)
	self.__index = self
	
	result:CheckHighScoreFile()
	return result
end

-- makes sure there is a high score file
-- adds the first high score if there isn't one
function highScoreReadWrite:CheckHighScoreFile()
		-- open file to make sure its there else create the file
	local filetest = io.open(self.filePath, "a+")
	io.close(filetest)
	
	-- if the file is empty then create a new score 
	local tempTable = {}
	for line in io.lines(self.filePath) do
		table.insert(tempTable, line)
	end
	
	-- if the table has no lines then insert a new highscore
	if #tempTable == 0 then
	local file = io.open(self.filePath, "a+")
	io.output(file)
	file:write("new10");
	io.close(file)
	end
end

-- gets score from temp.txt
function highScoreReadWrite:GetTempScore()
	CheckTempFile()
	-- probably better just to call getline or whatever it is in lua
	-- and I could probably just use a variable instead of this table
	-- self.tempScore didn't work here
	local tempTable = {}
		for line in io.lines("Assets\\Highscores\\temp.txt") do
			table.insert(tempTable, tonumber(line))
		end
	-- this should always be 1
	if #tempTable ~= 0 then
		return tempTable[#tempTable]
	end
	
	return 0
end

-- saves the the score to temp.txt
function highScoreReadWrite:SaveTempScore(score)
	local file = io.open(self.tempScore, "w+")
	io.output(file)
	file:write(score);
	io.close(file)
end

-- opens file in append+ mode which opens them in read 
-- mode if they exist or creates them if they don't
function CheckTempFile()
	local file = io.open("Assets\\Highscores\\temp.txt", "a+")
	io.close(file)
end

-- loads the temp score and saves the player initials 
--with the temp score in highscores.txt
function highScoreReadWrite:SaveScore(chars)
	-- load the score
	-- this should only get one line
	local score
	for line in io.lines(self.tempScore) do
		score = line
	end
	
	-- check if highscores.txt exists or else create one
	-- then inserts a new line
	local checkFileExists = io.open(self.filePath, "a+")
	io.output(checkFileExists)
	checkFileExists:write("\n")
	io.close(checkFileExists)

	-- write player initials to highscores.txt
	local writeCharsToFile = io.open(self.filePath, "a+")
	io.output(writeCharsToFile)
	for key,value in pairs(chars) do
		writeCharsToFile:write(chars[key])
	end 
	io.close(writeCharsToFile)
	 
	-- writes high score on the same line as the players initials
	local writeScoreToFile = io.open(self.filePath, "a+")
	io.output(writeScoreToFile)
	writeScoreToFile:write(score)
	io.close(writeScoreToFile)
end

-- reads the file and lots the scores and names and sorts them
function highScoreReadWrite:LoadHighScores()
	local highScores = {}
	local counter = 1
	-- for some reason I cant use self.filePath here
	for line in io.lines("Assets\\Highscores\\highscores.txt") do
	-- first 3 are initials
		local name = line:sub(1,3)
		-- the rest is the score
		local score = line:sub(4,#line)
		-- save the name and scores
		highScores[counter] = {}
		highScores[counter].score = tonumber(score)
		highScores[counter].name = name			
		counter = counter+1
	end
	-- sort the table then return
	table.sort(highScores, sortTable)
	
	return highScores
end

-- gets the sorted score table and returns the top 5 scores
function highScoreReadWrite:GetTopScores()
	tempTable = {}
	scoresTable = {}
	scoresTable = self.LoadHighScores()
	for i=#scoresTable,#scoresTable-self.maxScoreCount+1,-1 do
		if scoresTable[i] ~= nil then
		table.insert(tempTable, scoresTable[i])
		end
	end
	
	return tempTable

end

--table sort function
function sortTable(a, b)
	return a.score < b.score
 end
