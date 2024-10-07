extends AnimatableBody2D

@export var force = -500


func _on_area_2d_body_entered(body: Node2D) -> void:
	if "player" in body.name:
		body.velocity.y = force
