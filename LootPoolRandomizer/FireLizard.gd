extends Lizard
class_name FireLizard

#@export var stats: Dictionary[String, float]

func onHit(_bullet: Bullet, hitObject):
	var coldChance = 0.0
	if(budgetStats.get("fire")):
		coldChance = budgetStats["fire"]
	var checkValue = coldChance + 10.0
	var diceRoll = randf_range(0,1)
	if(diceRoll <= checkValue / 100.0):
		pass
		hitObject.burn()
	#print("SPLITTING")
	
