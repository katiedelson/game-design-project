extends StaticBody2D

@onready var collision1: CollisionShape2D = $CollisionShape2D
@onready var collision2: CollisionShape2D = $CollisionShape2D2
@onready var collision3: CollisionShape2D = $CollisionShape2D3

func _physics_process(delta: float) -> void:
	_enable_collisions()
	# Continuously check if the 'crouch' action (e.g., 's' key) is being held
	if Input.is_action_pressed("crouch"):
		_disable_collisions()
# Helper function to disable all collisions
func _disable_collisions() -> void:
	collision1.set_deferred("disabled", true)
	collision2.set_deferred("disabled", true)
	collision3.set_deferred("disabled", true)

# Helper function to enable all collisions
func _enable_collisions() -> void:
	collision1.set_deferred("disabled", false)
	collision2.set_deferred("disabled", false)
	collision3.set_deferred("disabled", false)
