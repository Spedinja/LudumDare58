extends Node2D
@export var projectile: PackedScene
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Attack"):
		var newBullet = projectile.instantiate()
		newBullet.direction = Vector2(1,0)
		newBullet.global_position = self.global_position + Vector2(300,300)
		self.add_child(newBullet)
