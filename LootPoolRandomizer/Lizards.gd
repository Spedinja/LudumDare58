extends item
class_name Lizard

@export var stats: Dictionary[String, float]

func applyUpgrade(bullet:Bullet):
	for key in stats:
		var changeVar = bullet.get(key)
		if(changeVar != null):
			var newValue = bullet.get(key) + stats[key]
			bullet.set(key, newValue)

func onHit():
	pass
