function love.load()
	gridLeft, gridTop = 100, 100
	gridWidth, gridHeight = 500, 500
	gridSizeX, gridSizeY = 7, 7
	
	drawnGridSizeX, drawnGridSizeY = gridSizeX + 2, gridSizeY + 2
	
	objects = {}
	cellGrid = {}
	
	activePath = nil
	activePathIterator = -1
	
	currentBallX, currentBallY = -1, -1
	ballR = gridWidth / drawnGridSizeX / 4
	ballSpeed = 5
	
	bounceTreshold = gridWidth / drawnGridSizeX / 8
	
	showLines = true
end

function love.keypressed(key)
	if key == "return" then
		startBall(0, 5, 2)
	end
	
	if key == "h" then
		showLines = not showLines
	end
	
	if key == " " then
		objects = {}
		cellGrid = {}
		directions = {-1, 1}
		
		objectCount = (math.random() + math.random()) * (gridSizeX * gridSizeY / 5)
		
		for i = 1, objectCount do
			currentObject = {}
			currentObject.xPos = math.floor(math.random() * gridSizeX) + 1
			currentObject.yPos = math.floor(math.random() * gridSizeY) + 1
			currentObject.direction = directions[math.floor(math.random() * 2) + 1]
			
			valid = true
			for j = 1, #objects do
				if objects[j].xPos == currentObject.xPos and objects[j].yPos == currentObject.yPos then
					valid = false
				end
			end
			if valid then
				objects[#objects + 1] = currentObject.xPos .. "|" .. currentObject.yPos
				cellGrid[currentObject.xPos .. "|" .. currentObject.yPos] = currentObject
			end
		end
	end
	
	if key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed(x, y, button)
	if gridLeft < x and x < gridLeft + gridWidth then
		if gridTop < y and y < gridTop + (gridHeight / drawnGridSizeY) then
			startBall(math.floor((x - gridLeft) / (gridWidth / drawnGridSizeX)), 0, 3)
		elseif gridTop + gridHeight - gridHeight / drawnGridSizeY < y and y < gridTop + gridHeight then
			startBall(math.floor((x - gridLeft) / (gridWidth / drawnGridSizeX)), gridSizeY + 1, 1)
		end
	end
	
	if gridTop < y and y < gridTop + gridHeight then
		if gridLeft < x and x < gridLeft + (gridWidth / drawnGridSizeX) then
			startBall(0, math.floor((y - gridTop) / (gridHeight / drawnGridSizeY)), 2)
		elseif gridLeft + gridWidth - gridWidth / drawnGridSizeX < x and x < gridLeft + gridWidth then
			startBall(gridSizeX + 1, math.floor((y - gridTop) / (gridHeight / drawnGridSizeY)), 4)
		end
	end
end

function love.update(dt)
	if activePath then
		currentTarget = activePath[activePathIterator]
		
		arrived = true
		
		if math.abs(currentTarget.X - currentBallX) > bounceTreshold then
			arrived = false
			currentBallX = currentBallX + math.sign(currentTarget.X - currentBallX) * ballSpeed
		elseif currentTarget.X - currentBallX ~= 0 then
			currentBallX = currentBallX + math.sign(currentTarget.X - currentBallX)
		end
		
		if math.abs(currentTarget.Y - currentBallY) > bounceTreshold then
			arrived = false
			currentBallY = currentBallY + math.sign(currentTarget.Y - currentBallY) * ballSpeed
		elseif currentTarget.Y - currentBallY ~= 0 then
			currentBallY = currentBallY + math.sign(currentTarget.Y - currentBallY)
		end
		
		if arrived then
			-- print("moved to: " .. currentTarget.X .. " | " .. currentTarget.Y)
			activePathIterator = activePathIterator + 1
			if activePathIterator > #activePath then
				activePath = nil
			end
		end
		
		-- print("moving " .. currentBallX .. " x|x " .. currentTarget.X)
	end
end

function love.draw()
	love.graphics.setLineWidth(1)
	
	love.graphics.setColor(200, 0, 0)
	love.graphics.rectangle("fill", gridLeft, gridTop, gridWidth, gridHeight / drawnGridSizeY)
	love.graphics.rectangle("fill", gridLeft, gridTop + gridHeight - gridHeight / drawnGridSizeY, gridWidth, gridHeight / drawnGridSizeY)
	love.graphics.rectangle("fill", gridLeft, gridTop, gridWidth / drawnGridSizeX, gridHeight)
	love.graphics.rectangle("fill", gridLeft + gridWidth - gridWidth / drawnGridSizeX, gridTop, gridWidth / drawnGridSizeX, gridHeight)
	
	love.graphics.setColor(255, 255, 255)
	
	for i = 1, drawnGridSizeY - 1 do
		yPos = gridTop + (gridHeight / drawnGridSizeY) * i
		love.graphics.line(gridLeft, yPos, gridLeft + gridWidth, yPos)
	end
	
	for i = 1, drawnGridSizeX - 1 do
		xPos = gridLeft + (gridWidth / drawnGridSizeX) * i
		love.graphics.line(xPos, gridTop, xPos, gridTop + gridHeight)
	end
	
	love.graphics.setLineWidth(3)
	
	
	if showLines then
		for i = 1, #objects do
			currentObject = cellGrid[objects[i]]
			
			love.graphics.print(currentObject.direction)
			
			halfCellWidth = gridWidth / drawnGridSizeX / 2
			cellHeight = gridHeight / drawnGridSizeY
			
			currentCellX = gridLeft + (gridWidth / drawnGridSizeX) * (currentObject.xPos + 0.5)
			currentCellY = gridTop + (gridHeight / drawnGridSizeY) * (currentObject.yPos)
			love.graphics.line(currentCellX + currentObject.direction * (halfCellWidth - 5), currentCellY + 5,
							   currentCellX - currentObject.direction * (halfCellWidth - 5), currentCellY + cellHeight - 5)
		end
	end
	
	if activePath then
		love.graphics.circle("fill", currentBallX, currentBallY, ballR)
	end
end

-- Custom functions

function startBall(x, y, d)
	currentPath = makeBallPath(x, y, d)
	coordinateList = pathToCoordinates(currentPath)
	
	-- for i = 1, #coordinateList do
	-- 	print(coordinateList[i].X .. " | " .. coordinateList[i].Y)
	-- end
	
	activePath = coordinateList
	activePathIterator = 1
	
	currentBallX = activePath[1].X
	currentBallY = activePath[1].Y
end

function makeBallPath(startX, startY, startDir)
	print("------")
	directionMap = {
		{X =  0, Y = -1}, -- up
		{X =  1, Y =  0}, -- right
		{X =  0, Y =  1}, -- down
		{X = -1, Y =  0}  -- left
	}
	
	ballX, ballY = startX, startY
	direction = startDir
	
	moveList = {}
	
	currentMove = {}
	currentMove.from = {ballX, ballY}
	currentMove.to = {ballX, ballY}
	moveList[#moveList + 1] = currentMove
	
	finished = false
	
	while not finished do
		-- print("moved: " .. ballX .. " | " .. ballY)
		
		currentMove = {}
		currentMove.from = {ballX, ballY}
		
		repeat
			ballX = ballX + directionMap[direction].X
			ballY = ballY + directionMap[direction].Y
			print("moved: " .. ballX .. " | " .. ballY)
		until cellGrid[ballX .. "|" .. ballY] or not (ballX > 0 and ballX <= gridSizeX and ballY > 0 and ballY <= gridSizeY)
		
		currentMove.to = {ballX, ballY}
		
		moveList[#moveList + 1] = currentMove
		
		if ballX > 0 and ballX <= gridSizeX and ballY > 0 and ballY <= gridSizeY then
			if direction % 2 == 1 then
				print("dir" .. direction)
				direction = (direction + cellGrid[ballX .. "|" .. ballY].direction - 1) % 4 + 1
				print("dir" .. direction)
			else
				print("dir" .. direction)
				direction = (direction - cellGrid[ballX .. "|" .. ballY].direction - 1) % 4 + 1
				print("dir" .. direction)
			end
			-- print("moved: " .. ballX .. " | " .. ballY)
		else
			finished = true
		end
	end
	
	return moveList
end

function pathToCoordinates(path)
	coordinateList = {}
	
	for i = 1, #path do
		-- coordinateList[#coordinateList + 1] = {}
		-- coordinateList[#coordinateList].X = math.floor(gridLeft + (gridWidth / drawnGridSizeX) * (path[i].from[1] + 1))
		-- coordinateList[#coordinateList].Y = math.floor(gridTop + (gridHeight / drawnGridSizeY) * (path[i].from[2] + 1))
		coordinateList[#coordinateList + 1] = {}
		coordinateList[#coordinateList].X = math.floor(gridLeft + (gridWidth / drawnGridSizeX) * (path[i].to[1] + 0.5))
		coordinateList[#coordinateList].Y = math.floor(gridTop + (gridHeight / drawnGridSizeY) * (path[i].to[2] + 0.5))
	end
	
	return coordinateList
end

function playSound(soundData)
	
end

-- Stolen Code

function math.sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end