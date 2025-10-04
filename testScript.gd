extends Node2D
@export var projectile: PackedScene
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Attack"):
		var newBullet = projectile.instantiate()
		newBullet.global_position = self.global_position + Vector2(300,300)
		var direction = (get_global_mouse_position() - newBullet.global_position).normalized()
		newBullet.direction = direction
		self.add_child(newBullet)
