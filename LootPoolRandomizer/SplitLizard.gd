extends Lizard
class_name SplitLizard

#@export var stats: Dictionary[String, float]
var projectile: PackedScene = preload("res://projectiles/bullet.tscn")

func onHit(bullet: Bullet, hitObject):
	print("SPLITTING")
	var vectors = generate_circle_vectors(8, 1)
	for direction in vectors:
		var newBullet = projectile.instantiate()
		newBullet.global_position = hitObject.global_position
		newBullet.direction = direction
		var multRemover = 0
		if(budgetStats.get("split")):
			multRemover = budgetStats["split"]
		newBullet.dmg = floor(bullet.dmg/(4- multRemover))
		newBullet.lifetime = 1
		newBullet.hitObjects = hitObject
		bullet.get_parent().add_child(newBullet)
	
	
func generate_circle_vectors(n: int, radius: float) -> Array:
	var vectors = []
	for i in range(n):
		var angle = 2.0 * PI * i / n
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		vectors.append(Vector2(x, y))
	return vectors
