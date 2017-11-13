-- Main.lua
-- magical piece of art... adding a current working path directory to the list of paths.
--Source: http://lua-users.org/lists/lua-l/2010-04/msg00693.html
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require('GameScene')
require('MainMenuScene')
require('HighScoreScene')
require('SaveScoreScene')

--currently loaded scene
g_currentScene = nil

--constructors to scenes
g_sceneCreators = {}

function LuaInit()
	table.insert(g_sceneCreators, mainMenuScene) --scene 1
	table.insert(g_sceneCreators, gameScene)     --scene 2
	table.insert(g_sceneCreators, highScoreScene)--scene 3
	table.insert(g_sceneCreators, saveScoreScene)--scene 4

	--destroys the map
	map:Destroy()

	--plays the background music
	PlayBgMusic(Logic.this, true)

	--will start the game with the main menu scene
	ChangeScene(1)
end

--update tick
function LuaUpdate(deltatime)
	--make sure there is a scene loaded
	if g_currentScene ~= nil then
		--make sure the scene is done loading
		if g_currentScene.isLoaded == true then
			g_currentScene:Update(deltatime)
		end
	end
end

--returns the currently loaded scene
function GetCurrentScene()
	return g_currentScene
end

--global change scene function
function ChangeScene(index)
	--make sure the index provided is within the bounds of the table of scenes
	if index > 0 and index <= #g_sceneCreators then 
		--make sure the scene exists
		if g_currentScene ~= nil then
		--destroy the scene
			g_currentScene:Destroy()
			g_currentScene = nil
		end
		--creates the new scene
		g_currentScene = g_sceneCreators[index]:Create()
	end
end
