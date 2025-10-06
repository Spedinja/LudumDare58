extends Lizard
class_name FireLizard

#@export var stats: Dictionary[String, float]

func onHit(_bullet: Bullet, hitObject):
	var coldChance = 0.0
	var stacks = 1
	if(budgetStats.get("fire")):
		coldChance = budgetStats["fire"]
	if(budgetStats.get("stacks")):
		stacks = budgetStats["stacks"]
	var checkValue = coldChance + 10.0
	var diceRoll = randf_range(0,1)
	if(diceRoll <= checkValue / 100.0):
		pass
		hitObject.burn(stacks)
	#print("SPLITTING")
	
