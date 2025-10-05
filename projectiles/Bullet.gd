extends Node
class_name Bullet

@export var dmg: float = 1
@export var speed: float = 150
@export var area: float = 10
@export var pierce: float = 10
@export var bounce: float = 3
@export var fire: float = 0
@export var ice: float = 0
@export var electric: float = 0
@export var exploding: float = 0
@export var lifetime: float = 5

var direction: Vector2 = Vector2(0,0)
var velocity: Vector2 = direction * speed
var alreadyReduced: bool = false

var hitObjects

func _ready() -> void:
	$lifetime.wait_time = lifetime
	$lifetime.start()
	velocity = direction * speed
	
func _process(_delta: float) -> void:
	#self.position += direction * speed * delta
	pass

#func _physics_process(delta):
	#var next_position = self.global_position + velocity * delta
#
	## 1. Do a raycast
	##var space_state = get_viewport().find_world_2d().direct_space_state
	#var space_state = $Area2D.get_world_2d().direct_space_state
	#var circle = CircleShape2D.new()
	#circle.radius = area
	## 1. Query objects at or near the bullet's position
	#var query = PhysicsShapeQueryParameters2D.new()
	#query.collide_with_areas = true
	#query.exclude = [self]
	#query.transform = Transform2D(0.0, self.global_position)
	#query.collision_mask = $Area2D.collision_mask
	#query.shape = circle
	#var results = space_state.intersect_shape(query)
	#var result = null
	##print(results)
	#if(results.size() > 0):
		#result = results[0]
		##tile_map.local_to_map(tile_map
		#print(result)
	##print(result.shape)
	#if result:
		#if !(result.collider is TileMapLayer):
			##do enemy stuff
			#match [int(pierce), int(bounce)]:
				#[0, 0]:
					#call_deferred("queue_free")
				#[0, _]:
					#bounce -= 1
				#[_, _]:
					#alreadyReduced = true
					#pierce -= 1
		#else:
			#if(bounce == 0):
				#call_deferred("queue_free")
			#else:
				#bounce -= 1
	#if result and !alreadyReduced and !(result.collider.is_in_group("Enemy") and pierce != 0):
		 ## 2. Reflect velocity around collision normal
		##var params2 = PhysicsRayQueryParameters2D.new()
		##params2.from = self.global_position
		##params2.to = next_position
		##params2.exclude = [self]
		##params2.collision_mask = $Area2D.collision_mask
		##var result2 = space_state.intersect_ray(params2)
		##var normal = result2.normal
		##velocity = velocity.bounce(normal)
		#pass
#
		## 3. Adjust position slightly to avoid clipping
		##self.global_position = result.position + velocity.normalized() * 1.0
	#else:
		#alreadyReduced = false
		#self.global_position = next_position
		
func _physics_process(delta):
	var next_position = self.global_position + velocity * delta

	var space_state = $Area2D.get_world_2d().direct_space_state
	#number of rays cast, adjust for performance vs accuracy
	var steps = 3
	var result = null
	var vectors = generate_half_circle_vectors(steps, area, velocity.normalized())
	for i in vectors:
		#var offset = perp * (area * float(i) / steps)
		var params = PhysicsRayQueryParameters2D.new()
		params.from = self.global_position
		params.to = next_position + i
		params.exclude = [self]
		params.collision_mask = $Area2D.collision_mask
		result = space_state.intersect_ray(params)
		if result:
			break
	if result:
		if !(result.collider is TileMapLayer):
			#do enemy stuff
			if(hitObjects == result.collider):
				self.global_position = next_position
				return
			hitObjects = result.collider
			match [int(pierce), int(bounce)]:
				[0, 0]:
					call_deferred("queue_free")
				[0, _]:
					print("-bounce")
					bounce -= 1
				[_, _]:
					alreadyReduced = true
					print("-pierce")
					pierce -= 1
		else:
			if(bounce == 0):
				call_deferred("queue_free")
			else:
				print("-bounce")
				bounce -= 1
	if result and !alreadyReduced and !(result.collider.is_in_group("Enemy") and pierce != 0):
		 # 2. Reflect velocity around collision normal
		var normal = result.normal
		velocity = velocity.bounce(normal)

		# 3. Adjust position slightly to avoid clipping
		#self.global_position = result.position + velocity.normalized() * 1.0
		self.global_position = self.global_position + velocity.normalized() * 1.0
	else:
		alreadyReduced = false
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
	
#func _physics_process(delta):
	#var next_position = self.global_position + velocity * delta
#
	## 1. Do a raycast
	#var space_state = $Area2D.get_world_2d().direct_space_state
	#var params = PhysicsRayQueryParameters2D.new()
	#params.from = self.global_position
	#params.to = next_position
	#params.exclude = [self]
	#params.collision_mask = $Area2D.collision_mask
	#var result = space_state.intersect_ray(params)
	#if result:
		#if !(result.collider is TileMapLayer):
			##do enemy stuff
			#match [int(pierce), int(bounce)]:
				#[0, 0]:
					#call_deferred("queue_free")
				#[0, _]:
					#bounce -= 1
				#[_, _]:
					#alreadyReduced = true
					#pierce -= 1
		#else:
			#if(bounce == 0):
				#call_deferred("queue_free")
			#else:
				#bounce -= 1
	#if result and !alreadyReduced and !(result.collider.is_in_group("Enemy") and pierce != 0):
		 ## 2. Reflect velocity around collision normal
		#var normal = result.normal
		#velocity = velocity.bounce(normal)
#
		## 3. Adjust position slightly to avoid clipping
		#self.global_position = result.position + velocity.normalized() * 1.0
	#else:
		#alreadyReduced = false
		#self.global_position = next_position
		
		
		
func notWorking(delta):
	var next_position = self.global_position + velocity * delta
	self.global_position = next_position

	var space_state = $Area2D.get_world_2d().direct_space_state
	var circle = CircleShape2D.new()
	circle.radius = area
	# 1. Query objects at or near the bullet's position
	var query = PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.exclude = [self]
	query.transform = Transform2D(0.0, self.global_position)
	query.collision_mask = $Area2D.collision_mask
	query.shape = circle
	var results = space_state.intersect_shape(query)
	var hit_result = null
	#print(results.size())
	# 2. Manual distance check against each result
	for r in results:
		var collider = r.collider
		if collider == null:
			continue
		# Compute distance from bullet center to collider position
		var collider_pos = collider.global_position
		var dist = self.global_position.distance_to(collider_pos)

		if dist <= area:
			hit_result = r
			break
	
	# 3. Handle collision logic if any target was inside area radius
	if hit_result:
		var col = hit_result.collider
		if(hitObjects == col):
			return
		hitObjects = null
		hitObjects = hit_result.collider
		if !(col is TileMapLayer):
			# Enemy hit logic
			match [int(pierce), int(bounce)]:
				[0, 0]:
					call_deferred("queue_free")
				[0, _]:
					print("-bounce")
					bounce -= 1
				[_, _]:
					alreadyReduced = true
					print("-pierce")
					pierce -= 1
		else:
			# Wall hit logic
			if bounce == 0:
				call_deferred("queue_free")
			else:
				print("-bounce")
				bounce -= 1

		# 4. Bounce reflection logic
		if !alreadyReduced and !(col.is_in_group("Enemy") and pierce != 0):
			var normal = (self.global_position - col.global_position).normalized()
			velocity = velocity.bounce(normal)
			self.global_position += velocity.normalized() * 1.0
	else:
		alreadyReduced = false

func _on_lifetime_timeout() -> void:
	queue_free()
	pass # Replace with function body.


#func _on_area_2d_body_entered(body: Node2D) -> void:
	#pass
	##if !(body is TileMapLayer):
		###do enemy stuff
		##match [int(pierce), int(bounce)]:
			##[0, 0]:
				##call_deferred("queue_free")
			##[0, _]:
				##bounce -= 1
			##[_, _]:
				##alreadyReduced = true
				##pierce -= 1
	##else:
		##if(bounce == 0):
			##call_deferred("queue_free")
		##else:
			##print("reduce bounce")
			##bounce -= 1
			#
		#
#
#
#func _on_area_2d_body_exited(_body: Node2D) -> void:
	#print("revert")
	#alreadyReduced = false
