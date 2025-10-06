extends Enemy
class_name ShotgunRat

@onready var sfx_shoot: AudioStreamPlayer2D = $sfx_shoot
var projectile: PackedScene = preload("res://projectiles/EnemyBullet.tscn")

func _attack() -> bool:
	if(super()):
		sfx_shoot.play()
		var newProjectile = projectile.instantiate()
		newProjectile.direction = (follow_object.global_position - self.global_position).normalized()
		newProjectile.lifetime = 3
		newProjectile.speed = 300
		self.get_parent().add_child(newProjectile)
		newProjectile.global_position = self.global_position
		newProjectile.look_at(follow_object.global_position)
		return true
	else:
		return false
