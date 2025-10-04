extends Resource
class_name RoomData

@export var hasLeftNbr: bool = false
@export var hasRightNb: bool = false
@export var hasTopNb: bool = false
@export var hasBottomNb: bool = false

@export var isMain: bool = false
@export var isEnd: bool = false
@export var isDeadEnd = false
@export var isGeckoRoom : bool = false
@export var room: PackedScene
