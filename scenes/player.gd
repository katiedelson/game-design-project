extends CharacterBody2D


const SPEED = 180.0
const JUMP_VELOCITY = -300.0
const WALL_SLIDING_SPEED = 3000


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_checker: RayCast2D = $WallChecker


var jumpsMade = 0
var doWallJump = false

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	# Add the gravity.
	if is_near_wall():
		velocity.y = WALL_SLIDING_SPEED * delta
	elif not is_on_floor(): velocity += get_gravity() * delta
	else: jumpsMade = 0
	
	if Input.is_action_just_pressed("jump"):
		if is_near_wall():
			velocity.y = JUMP_VELOCITY
			velocity.x = -direction + SPEED
			doWallJump = true
			
			$"../WallJumpTimer".start()
		elif is_on_floor() || jumpsMade <2:
			velocity.y = JUMP_VELOCITY
			jumpsMade += 1
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || jumpsMade <2):
		velocity.y = JUMP_VELOCITY
		jumpsMade += 1
	# Get the input direction and handle the movement/deceleration.
	

		
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	#flip direction

	
	#play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	
	
	if direction && not doWallJump: velocity.x = direction * SPEED
	elif not doWallJump:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	set_direction()
	move_and_slide()
	
func set_direction():
	var direction = Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite.flip_h = false
		wall_checker.rotation_degrees = -90
	elif direction < 0:
		animated_sprite.flip_h = true
		wall_checker.rotation_degrees = 90
	#wall_checker.rotation_degrees = 90 * -direction
		
func is_near_wall():
	return $WallChecker.is_colliding()

func _on_wall_jump_timer_timeout() -> void:
	doWallJump = false
