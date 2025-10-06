extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		call_deferred("_emit_next_layer")

func _emit_next_layer():
	SignalManager.emit_signal("go_to_next_layer")
