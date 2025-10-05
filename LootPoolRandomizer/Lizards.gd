extends item
class_name Lizard

	
func applyUpgrade(bullet:Bullet):
	for key in budgetStats:
		var changeVar = bullet.get(key)
		if(changeVar != null):
			print(rarity)
			print("basestats")
			print(basestats)
			print("budgetstats")
			print(budgetStats)
			var newValue = bullet.get(key) + basestats[str(key)] * budgetStats[key]
			bullet.set(key, newValue)

func onHit(_bullet: Bullet, _hitObject):
	pass
