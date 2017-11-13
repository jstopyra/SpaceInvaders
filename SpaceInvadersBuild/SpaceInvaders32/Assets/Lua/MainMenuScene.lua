-- MainMenuScene.lua
require('Scene')
mainMenuScene = {}

function mainMenuScene:Create()
	local result = scene:Create("main menu")
	result.isLoaded = false

	--name of the scene
	result.name = "main menu"

	--size of the png thats showed on the screen
	result.menuSize = 500
	--width of the game window
	result.windowWidth = 900

	--this is where we're gonna spawn the png
	local spawnPosition = {x = (result.windowWidth - result.menuSize)/2, y = 100}

	--spawn the png
	result.actor = SpawnActor(Logic.this, "Assets\\XML\\MenuStart.xml")

	--save the transform of the png
	result.transform = result.actor.TransformComponent

	--move the png into a position
	result.transform.Move(result.transform.this, spawnPosition.x, spawnPosition.y)

	setmetatable(result, self)
	self.__index = self
	--we're loaded
	result.isLoaded = true
	return result
end

--destroy the scene
function mainMenuScene:Destroy()
	--destroys the png that greets the player
	if self.actor ~= nil then
		DestroyActor(Logic.this, self.actor.this)
	end
end

function mainMenuScene:Update(deltatime)
	--"s" goes to gameplay scene and "h" goes to highscore scene
	local input = GetCommand(InputSystem.this)
	if input == "s" then
		ChangeScene(2) --game scene
	elseif input == "h" then
		ChangeScene(3) --highscore scene
	end
end
