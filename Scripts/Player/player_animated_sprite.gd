extends AnimatedSprite2D
class_name PlayerAnimatedSprite

@onready var player_head_sprite: AnimatedSprite2D = $GeckoHead_AnimatedSprite2D
var current_default : String = "default_down"

func _on_gecko_head_animated_sprite_2d_animation_finished() -> void:
	player_head_sprite.play(current_default)
