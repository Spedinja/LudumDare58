extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true


func _on_finished() -> void:
	self.queue_free()
