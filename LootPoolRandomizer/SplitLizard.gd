extends Lizard
class_name SplitLizard

#@export var stats: Dictionary[String, float]
var projectile: PackedScene = preload("res://projectiles/bullet.tscn")

func onHit(bullet: Bullet, hitObject):
	#print("SPLITTING")
	var vectors = generate_circle_vectors(8, 1, Vector2(randf_range(-1,1),randf_range(-1,1)).normalized())
	for direction in vectors:
		var newBullet = projectile.instantiate()
		#newBullet.global_position = hitObject.global_position
		newBullet.direction = direction
		var multRemover = 0
		if(budgetStats.get("split")):
			multRemover = budgetStats["split"]
		newBullet.dmg = floor(bullet.dmg/(4- multRemover))
		newBullet.lifetime = 0.3
		newBullet.speed = floor(bullet.speed / 2)
		newBullet.hitObjects = hitObject
		bullet.get_parent().add_child(newBullet)
		newBullet.global_position = hitObject.global_position
	
	
func generate_circle_vectors(n: int, radius: float, start_dir: Vector2) -> Array:
	# Ensure the start direction is normalized
	var start_dir_norm = start_dir.normalized()
	var start_angle = atan2(start_dir_norm.y, start_dir_norm.x)

	var vectors = []
	for i in range(n):
		var angle = start_angle + 2.0 * PI * i / n
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		vectors.append(Vector2(x, y))
	
	return vectors
