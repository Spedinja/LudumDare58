extends Resource
# base class for items extend this one for custom types
class_name item

@export var id: int
@export var itemName: String
@export var rarity: String
@export var hasBudget: bool
@export var budgetStats: Dictionary[String, float]
@export var description: String
