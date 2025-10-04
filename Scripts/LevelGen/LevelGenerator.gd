extends Node

class_name LevelGenerator

@export var roomPool: RoomPool
@export var gridlayout: GridLayout
@export var roomWidth = 1024
@export var roomHeight = 768
@export var startRoomPos = Vector2i(10,10)
@export var startRoom : RoomData
@export var endRoom : RoomData
@export var outerBoundRoom: RoomData

#additions
@export var max_rooms: int = 50
@export var num_geckos: int = 0

#vars
var room: RoomData
var gridRoom: GridRoom
var WIDTH : int
var HEIGHT: int
var grid : Array = []
var visited : Array= []
var currPos = Vector2i()
var mainPath: Array = []

#onready
func _ready():
	WIDTH = gridlayout.width
	HEIGHT = gridlayout.height
	genLevel()
	grid = gridlayout.rooms

#algorithm to generate a level
func genLevel():
	init_grid()
	#generateMainPath()
	generateDungeon()
	#addBranches()
	addBranchesUntilMax()
	fillGridWithMain()
	assignRoomTemplatesBasedOnNeighbors()
	placeStartRoom()
	placeEndRoom()
	placeGeckoRooms()
	instantiateRooms()
	fixOuterBounds()	
	return
	
#setup grids
func init_grid():
	grid.clear()
	visited.clear()
	for x in range(WIDTH):
		grid.append([])
		visited.append([])
		for y in range(HEIGHT):
			grid[x].append(null)
			visited[x].append(false)
	currPos = startRoomPos
	return

#generate main path start-finish	
#func generateMainPath():
	#
	##start room
	#visited[currPos.x][currPos.y] = true
	#mainPath.append(currPos)
	#
	##next room
	#currPos = Vector2i(startRoomPos.x +1, startRoomPos.y)
	#visited[currPos.x][currPos.y] = true
	#mainPath.append(currPos)
	#
	##generate mainPath
	#while currPos.x < WIDTH-1:
		#var options = []
		#if currPos.y > 0 and not visited[currPos.x][currPos.y - 1]:
			#options.append(Vector2i(0, -1)) #up
		#if currPos.y < HEIGHT - 1 and not visited[currPos.x][currPos.y + 1]:
			#options.append(Vector2i(0, 1)) #down
		#if currPos.x < WIDTH - 1 and not visited[currPos.x + 1][currPos.y]:
			#options.append(Vector2i(1, 0)) #right
		#
		#if options.is_empty():
			#break
	#
		#var move = options.pick_random()
		#currPos += move
		#visited[currPos.x][currPos.y] = true
		#
		##var room = GridRoom.new()
		##room.x = currPos.x
		##room.y = currPos.y
		##grid[currPos.x][currPos.y] = room
		#
		#mainPath.append(currPos)

#adjusted algorithm of old version	
func generateDungeon():
	# start room
	visited[startRoomPos.x][startRoomPos.y] = true
	mainPath.append(startRoomPos)

	#branch in all 4 directions
	for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		if randf() < 0.75: #% chance to open this direction
			weBeDrunkenWalkin(startRoomPos, dir)	

#drunken walk algorithm
func weBeDrunkenWalkin(start: Vector2i, dir: Vector2i):
	var curr = start + dir
	while isWithinBounds(curr) and not visited[curr.x][curr.y] and mainPath.size() < max_rooms:
		visited[curr.x][curr.y] = true
		mainPath.append(curr)

		#rng turn
		if randf() < 0.5:
			dir = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)].pick_random()

		curr += dir


#generates branches/additional rooms connecting to mainpath
#should be changes if we want to use it, so only deadends get added
#func addBranches():
	#for room in mainPath.duplicate():
		#for dir in [Vector2i(0,-1), Vector2i(0,1),Vector2i(1,0),Vector2i(-1,0)]:
			#var n = room + dir
			#if isWithinBounds(n) and not visited[n.x][n.y] and randf() < 0.1:
				#visited[n.x][n.y] = true
				#mainPath.append(Vector2i(n.x,n.y))
	#
	#return mainPath
	
func addBranchesUntilMax():
	var room_count = mainPath.size()
	
	while room_count < max_rooms:
		var base_room = mainPath.pick_random()
		var directions = [Vector2i(0,-1), Vector2i(0,1), Vector2i(1,0), Vector2i(-1,0)]
		directions.shuffle()
		
		var placed = false
		for dir in directions:
			var n = base_room + dir
			if isWithinBounds(n) and not visited[n.x][n.y] and randf() < 1.0:
				visited[n.x][n.y] = true
				mainPath.append(n)
				room_count += 1
				placed = true
				break
		
		#cant place a new room at all (surrounded), break to avoid infinite loop
		if not placed:
			break
		return
	
#setup base gridroom in the grid, only need to find and add a roomtemplate later
func fillGridWithMain():
	for pos in mainPath:
		
		
		#create gridroom
		var room = GridRoom.new()
		room.x = pos.x
		room.y = pos.y
		
		#roomdata
		var rd = RoomData.new()
		rd.hasLeftNbr = isValidRoom(pos.x - 1, pos.y)
		rd.hasRightNb = isValidRoom(pos.x + 1, pos.y)
		rd.hasTopNb = isValidRoom(pos.x, pos.y - 1)
		rd.hasBottomNb = isValidRoom(pos.x, pos.y + 1)
		
		#check for deadends
		#var connections = 0
		#if rd.hasLeftNbr: connections += 1
		#if rd.hasRightNb: connections += 1
		#if rd.hasTopNb: connections += 1
		#if rd.hasBottomNb: connections += 1

		#if connections == 1:
		#	rd.isDeadEnd = true
		#else :
		#	rd.isMain = true
		
		room.roomdata = rd
		grid[room.x][room.y] = room
	return

#add the starting room at the beginning + adds roomdata
func placeStartRoom():
	var gridRoom = grid[startRoomPos.x][startRoomPos.y]
	gridRoom.roomdata = startRoom
	return

#finds the furthest room away from start, and flags its + add roomdata
func placeEndRoom():
	#var furthest = Vector2i(0, 0)
	#for x in range(WIDTH):
		#for y in range(HEIGHT):
			#if visited[x][y] and x > furthest.x:
				#furthest = Vector2i(x, y)
#
	var furthest = bfsFurthestRoom(startRoomPos) #added - above removed
	var room = grid[furthest.x][furthest.y]
	room.roomdata = null
	room.roomdata = endRoom

#use bfs to find furthest away point as end room
func bfsFurthestRoom(start: Vector2i) -> Vector2i:
	var queue = [start]
	var dist = {}
	dist[start] = 0
	var furthest = start

	while not queue.is_empty():
		var current = queue.pop_front()
		for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var n = current + dir
			if isValidRoom(n.x, n.y) and not dist.has(n):
				dist[n] = dist[current] + 1
				queue.append(n)
				if dist[n] > dist[furthest]:
					furthest = n

	return furthest

func placeGeckoRooms():
	var candidates: Array[Vector2i] = []
	for pos in mainPath:
		if pos != startRoomPos:
			var grid_room = grid[pos.x][pos.y]
			if grid_room and grid_room.roomdata != endRoom:
				candidates.append(pos)

	candidates.shuffle()
	for i in range(min(num_geckos, candidates.size())):
		grid[candidates[i].x][candidates[i].y].roomdata.isGeckoRoom = true

#checks wether the position is inside the grid or not
func isWithinBounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < WIDTH and pos.y >= 0 and pos.y < HEIGHT
	
#finds and assigns possible neighbours of all rooms inside the grid
func assignRoomTemplatesBasedOnNeighbors():
	#for pos in mainPath:
			#if !grid[pos.x][pos.y] == null:
				#var connections = getRequiredConnections(pos.x,pos.y)
				#var match = findTemplate(connections)
				#if match:
					#var room = grid[pos.x][pos.y]
					#room.roomdata = match 
	#return
	
	for pos in mainPath:
		var grid_room = grid[pos.x][pos.y]
		if grid_room == null:
			continue
		
		var connections = getRequiredConnections(pos.x, pos.y)
		
		# gecko check
		if grid_room.roomdata.isGeckoRoom:
			var shop_match = findTemplate(connections, true)
			if shop_match:
				grid_room.roomdata = shop_match
			continue
		
		# normal room
		var match = findTemplate(connections, false)
		if match:
			grid_room.roomdata = match
		
	return

#gets the connetion the room at gridPos x,y needs to be setup
func getRequiredConnections(x: int, y: int) -> Dictionary:
	return {
		#"left": grid[x - 1][y].roomdata.hasRightNb if isValidRoom(x - 1, y) else false,
		#"right": grid[x + 1][y].roomdata.hasLeftNbr if isValidRoom(x + 1, y) else false,
		#"top": grid[x][y - 1].roomdata.hasBottomNb if isValidRoom(x, y - 1) else false,
		#"bottom": grid[x][y + 1].roomdata.hasTopNb if isValidRoom(x, y + 1) else false
		"left": isValidRoom(x - 1, y),
		"right":  isValidRoom(x + 1, y),
		"top":  isValidRoom(x, y - 1) ,
		"bottom": isValidRoom(x, y + 1)
		}

#is room within bounds and is visited / otherwise no valid gridspot to place room
func isValidRoom(posX:int,posY:int) -> bool: 
	return posX >= 0 and posX < WIDTH and posY >= 0 and posY < HEIGHT and visited[posX][posY] == true

#find a valid room template for placement
func findTemplate(connections: Dictionary, requires_Gecko):
	#var options = []
	#for room in roomPool.rooms:
		#if room.hasLeftNbr == connections["left"] and \
			#room.hasRightNb == connections["right"] and \
			#room.hasTopNb == connections["top"] and \
			#room.hasBottomNb == connections["bottom"]:
			#options.append(room)
	#return options.pick_random()
	var options = []
	for room in roomPool.rooms:
		if room.isGeckoRoom != requires_Gecko:
			continue
		
		if room.hasLeftNbr == connections["left"] and \
			room.hasRightNb == connections["right"] and \
			room.hasTopNb == connections["top"] and \
			room.hasBottomNb == connections["bottom"]:
			options.append(room)
	
	if options.is_empty():
		return null
	return options.pick_random()

#spawn/instantiate all rooms via roomdata in the grid
func instantiateRooms():
	var roomParent = self
	for pos in mainPath:
		var grid_room = grid[pos.x][pos.y]
		if grid_room and grid_room.roomdata and grid_room.roomdata.room:
			var room_scene = grid_room.roomdata.room.instantiate()
			room_scene.position = Vector2(pos.x * roomWidth, pos.y * roomHeight)
			self.add_child(room_scene)
	return

func fixOuterBounds():
	var boundsPos
	for columns in grid:
		for rooms in columns:
			if (rooms == null):
				continue
			var roomData = rooms.roomdata
			var connections = getRequiredConnections(rooms.x,rooms.y)
			var room_position = Vector2(rooms.x * roomWidth, rooms.y * roomHeight)
			
			for dir in connections.keys():
				if not connections[dir]:
					match dir:
						"left":
							boundsPos = room_position + Vector2(-roomWidth, 0)
							instantiateOuterBounds(boundsPos)
						"right":
							boundsPos = room_position + Vector2(roomWidth, 0)
							instantiateOuterBounds(boundsPos)
						"top":
							boundsPos = room_position + Vector2(0, -roomHeight)
							instantiateOuterBounds(boundsPos)
						"bottom":
							boundsPos = room_position + Vector2(0, roomHeight)
							instantiateOuterBounds(boundsPos)
					# now check for corners
					if not connections["left"] and not connections["top"]:
						instantiateOuterBounds(room_position + Vector2(-roomWidth, -roomHeight))

					if not connections["right"] and not connections["top"]:
						instantiateOuterBounds(room_position + Vector2(roomWidth, -roomHeight))

					if not connections["left"] and not connections["bottom"]:
						instantiateOuterBounds(room_position + Vector2(-roomWidth, roomHeight))

					if not connections["right"] and not connections["bottom"]:
						instantiateOuterBounds(room_position + Vector2(roomWidth, roomHeight))


func instantiateOuterBounds(boundsPos:Vector2):
	var roomParent =  self
	var room_scene = outerBoundRoom.room.instantiate()
	room_scene.position = boundsPos
	self.add_child(room_scene)
