extends StaticBody2D

@onready var collision1: CollisionShape2D = $CollisionShape2D
@onready var collision2: CollisionShape2D = $CollisionShape2D2
@onready var collision3: CollisionShape2D = $CollisionShape2D3

func _input(event: InputEvent) -> void:
	collision1.set_deferred("disabled", false)
	collision2.set_deferred("disabled", false)
	collision3.set_deferred("disabled", false)
	if event.is_action_pressed("crouch"):
		collision1.set_deferred("disabled", true)
		collision2.set_deferred("disabled", true)
		collision3.set_deferred("disabled", true)

#func _on_area_2d_body_entered(body: Node2D) -> void:
	
#func _on_area_2d_body_exited(body: Node2D) -> void:
	
