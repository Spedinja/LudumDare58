extends Node2D
@export var projectile: PackedScene
@export var upgradeLizards: Array[Lizard]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Attack"):
		for i in 1:
			var newBullet = projectile.instantiate()
			for buff in upgradeLizards:
				buff.applyUpgrade(newBullet)
			newBullet.global_position = self.global_position + Vector2(300,300) #+ Vector2(randi_range(0,150),randi_range(0,150))
			var direction = (get_global_mouse_position() - newBullet.global_position).normalized()
			newBullet.direction = direction
			newBullet.printStats()
			self.add_child(newBullet)
		
		
		#var space_state = get_world_2d().direct_space_state
		#var circle = CircleShape2D.new()
		#circle.radius = 30
		## 1. Query objects at or near the bullet's position
		#var query = PhysicsShapeQueryParameters2D.new()
		#query.collide_with_areas = true
		#query.exclude = [self]
		#query.transform = Transform2D(0.0, get_global_mouse_position())
		#query.collision_mask = $TileMapLayer/Wall.collision_mask
		#query.shape = circle
		#var results = space_state.intersect_shape(query)
		#var hit_result = null
		#print(results.size())
