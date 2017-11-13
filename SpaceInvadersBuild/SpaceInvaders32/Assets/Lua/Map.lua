-- Bullet.lua
map = {}
mapWidth = 113
mapHeight = 113

function map:Create(tileSize, mapWidth, mapHeight)
	local result = {}

	--map dimensions
	result.tileSize = tileSize
	result.mapWidth = mapWidth
	result.mapHeight = mapHeight

	setmetatable(result, self)
	self.__index = self
	return result
end

--destroy tiles around a given position with a given radius
function map:DestroyTilesAroundPosition(position, radius)

	--go in both negative and positive in half of delta and destroy tiles in those indexes.
	for x=(-radius/2 * self.tileSize),(radius/2) * self.tileSize,self.tileSize do
		for y=(-radius/2 * self.tileSize),(radius/2) * self.tileSize,self.tileSize do

			--thats our x and y positions
			local position = {x = position.x + x, y = position.y + y}
			--destroy the tile of the index of the calculated position
			local index = self:GetTileIndexFromPosition(position, self.tileSize)
			DisableTile(Logic.this, 1, index)
		end
	end
end

--get the index from given x, y coordinates with tileSize as the offset
function map:GetTileIndexFromPosition(position, tileSize)
	local xIndex = math.floor(position.x/tileSize)
	local yIndex = math.floor(position.y/tileSize)
	local index = (xIndex) + (yIndex * self.mapWidth)
	return index
end

--nothing really to destroy here
function map:Destroy()
    for index = 0, (mapWidth*mapHeight) -1, 1 do
		DisableTile(Logic.this, 1, index)
	end
end
