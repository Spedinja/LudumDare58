extends Area2D

@export var dmg: float = 5
@export var speed: float = 150
@export var lifetime: float = 3

var direction: Vector2 = Vector2(0,0)
var velocity: Vector2 = direction * speed
var lifetimeTimer: Timer

func _ready() -> void:
	lifetimeTimer = Timer.new()
	lifetimeTimer.one_shot = true
	add_child(lifetimeTimer)
	lifetimeTimer.wait_time = lifetime
	lifetimeTimer.start()
	velocity = direction * speed


func _physics_process(delta):
	var next_position = self.global_position + velocity * delta

	var space_state = get_world_2d().direct_space_state
	#number of rays cast, adjust for performance vs accuracy
	var steps = 3
	var result = null
	var area = 4.0
	var vectors = generate_half_circle_vectors(steps, area, velocity.normalized())
	for i in vectors:
		#var offset = perp * (area * float(i) / steps)
		var params = PhysicsRayQueryParameters2D.new()
		params.from = self.global_position
		params.to = next_position + i
		params.exclude = [self]
		params.collision_mask = collision_mask
		result = space_state.intersect_ray(params)
		if result:
			break
	if result:
		var col = result.collider
		if (col is TileMapLayer):
			call_deferred("queue_free")
			return
		if(col.is_in_group("Player")):
			col.take_damage(dmg)
			call_deferred("queue_free")
	else:
		self.global_position = next_position

func generate_half_circle_vectors(n: int, radius: float, start_dir: Vector2) -> Array:
	# Normalize start vector
	var start_dir_norm = start_dir.normalized()
	# Center angle of half-circle
	var center_angle = atan2(start_dir_norm.y, start_dir_norm.x)

	var vectors = []
	for i in range(n):
		# Spread vectors evenly over a half-circle (-PI/2 to +PI/2)
		var angle_offset = -PI/2 + (PI * i / (n - 1))
		var angle = center_angle + angle_offset
		if(i == 0):
			radius = radius * 0.7
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		vectors.append(Vector2(x, y))
	
	return vectors
