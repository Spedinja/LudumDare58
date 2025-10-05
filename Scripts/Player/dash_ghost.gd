extends Sprite2D
class_name DashGhost

@export var duration: float = 2

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tween = create_tween()
	tween.finished.connect(queue_free)
	tween.tween_property(self,"modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.play()
