-- String.lua

string = {}

--start position(x, y) of the text
--text we initialize the class string with
function string:Create(startPos, text)
	local result = {}
	result.characters = {}
	--table of all the characters
	result.characters['a'] = "Assets\\XML\\Alphabet\\AlphabetA.xml"
	result.characters['b'] = "Assets\\XML\\Alphabet\\AlphabetB.xml"
	result.characters['c'] = "Assets\\XML\\Alphabet\\AlphabetC.xml"
	result.characters['d'] = "Assets\\XML\\Alphabet\\AlphabetD.xml"
	result.characters['e'] = "Assets\\XML\\Alphabet\\AlphabetE.xml"
	result.characters['f'] = "Assets\\XML\\Alphabet\\AlphabetF.xml"
	result.characters['g'] = "Assets\\XML\\Alphabet\\AlphabetG.xml"
	result.characters['h'] = "Assets\\XML\\Alphabet\\AlphabetH.xml"
	result.characters['i'] = "Assets\\XML\\Alphabet\\AlphabetI.xml"
	result.characters['j'] = "Assets\\XML\\Alphabet\\AlphabetJ.xml"
	result.characters['k'] = "Assets\\XML\\Alphabet\\AlphabetK.xml"
	result.characters['l'] = "Assets\\XML\\Alphabet\\AlphabetL.xml"
	result.characters['m'] = "Assets\\XML\\Alphabet\\AlphabetM.xml"
	result.characters['n'] = "Assets\\XML\\Alphabet\\AlphabetN.xml"
	result.characters['o'] = "Assets\\XML\\Alphabet\\AlphabetO.xml"
	result.characters['p'] = "Assets\\XML\\Alphabet\\AlphabetP.xml"
	result.characters['q'] = "Assets\\XML\\Alphabet\\AlphabetQ.xml"
	result.characters['r'] = "Assets\\XML\\Alphabet\\AlphabetR.xml"
	result.characters['s'] = "Assets\\XML\\Alphabet\\AlphabetS.xml"
	result.characters['t'] = "Assets\\XML\\Alphabet\\AlphabetT.xml"
	result.characters['u'] = "Assets\\XML\\Alphabet\\AlphabetU.xml"
	result.characters['v'] = "Assets\\XML\\Alphabet\\AlphabetV.xml"
	result.characters['w'] = "Assets\\XML\\Alphabet\\AlphabetW.xml"
	result.characters['x'] = "Assets\\XML\\Alphabet\\AlphabetX.xml"
	result.characters['y'] = "Assets\\XML\\Alphabet\\AlphabetY.xml"
	result.characters['z'] = "Assets\\XML\\Alphabet\\AlphabetZ.xml"
	result.characters[' '] = "Assets\\XML\\Alphabet\\AlphabetSpace.xml"
	result.characters['0'] = "Assets\\XML\\Number0.xml"
	result.characters['1'] = "Assets\\XML\\Number1.xml"
	result.characters['2'] = "Assets\\XML\\Number2.xml"
	result.characters['3'] = "Assets\\XML\\Number3.xml"
	result.characters['4'] = "Assets\\XML\\Number4.xml"
	result.characters['5'] = "Assets\\XML\\Number5.xml"
	result.characters['6'] = "Assets\\XML\\Number6.xml"
	result.characters['7'] = "Assets\\XML\\Number7.xml"
	result.characters['8'] = "Assets\\XML\\Number8.xml"
	result.characters['9'] = "Assets\\XML\\Number9.xml"

	--table for all the spawned images
	result.spawnedImages = {}

	--our initial text
	result.text = text:lower()

	--pixels of offset from one image start to another.
	result.imagesOffset = 40
	--where does our text start spawning
	result.startPos = startPos
	
	setmetatable(result, self)
	self.__index = self
	--spawn the initial text
	result:SpawnString()
	return result
end

--changes the text of the self.text and respawns the string
function string:ChangeText(newText)
--we need to convert the text to lower because our character indexes are all lower case
	self.text = newText:lower()
	self:SpawnString()
end

--spawns entire text of the text assign to self.text
function string:SpawnString()
	--clean up the old text
	self:CleanString()
	local currIndex = 0
	--loop through all the characters and spawn them on screen with an offset.
	for i = 1, #self.text do
		local char = self.text:sub(i,i)
		local pos = {x = self.startPos.x + (self.imagesOffset * currIndex), y = self.startPos.y}
		self:SpawnCharacter(char, pos)
		currIndex = currIndex+1
	end
end

--spawns a single character actor into the scene with a given character and position
function string:SpawnCharacter(character, pos)
	local image = SpawnActor(Logic.this, self.characters[character])
	image.TransformComponent.Move(image.TransformComponent.this, pos.x, pos.y)
	table.insert(self.spawnedImages, image)
end

--cleans the current string
function string:CleanString()
	for i=#self.spawnedImages, 1, -1 do
		DestroyActor(Logic.this, self.spawnedImages[i].this)
		table.remove(self.spawnedImages, i)
	end
end

--destroy self.
function string:Destroy()
	self:CleanString()
end