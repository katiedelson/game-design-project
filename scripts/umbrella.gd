extends AnimatableBody2D
@export var bounce_multiplier = 1.0  # multiplier to adjust bounce force (1.0 = equal force)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "player" in body.name and body.has_method("get_velocity"):
		body.reset_double_jump()
		body.reset_last_wall()
		var player_velocity = body.get_velocity()
		# only apply bounce if the player is falling down
		if player_velocity.y > 0:
			# reflect the player's vertical velocity to bounce back up
			body.velocity.y = -player_velocity.y * bounce_multiplier
