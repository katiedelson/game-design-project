extends CharacterBody2D

enum {AIR, FLOOR, WALL}
var state = AIR
var wall_time = 0.0
var sliding_speed = 100
var last_jump_direction = 0

const JUMP_VELOCITY = -300.0
const SLIDE_TIME = 3.0
const SPEED = 180
const MAX_SLIDING_SPEED = 15000

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_checker: RayCast2D = $WallChecker

func _physics_process(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:  # Only apply movement if we're not on a wall
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if state != WALL:
		if direction < 0: 
			animated_sprite.flip_h = true
			wall_checker.rotation_degrees = 90
		elif direction > 0: 
			animated_sprite.flip_h = false
			wall_checker.rotation_degrees = -90
	# Process the player's state
	match state:
		AIR: air_state()
		FLOOR: floor_state()
		WALL: wall_state(delta)
		
	move_and_slide()
	
func air_state():
	wall_time = 0
	sliding_speed = 0
	animated_sprite.play("jump")
	if is_on_floor():
		state = FLOOR
	elif is_near_wall() and velocity.y > 0:
		state = WALL

func floor_state():
	wall_time = 0
	sliding_speed = 0
	last_jump_direction = 0
	if velocity.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		state = AIR
	if is_near_wall() and velocity.y > 0:
		state = WALL
		
func wall_state(delta):
	# Lock horizontal movement and prevent sliding
	velocity.x = 0
	velocity.y = 0  # Prevent falling
	
	animated_sprite.play("climb")
	#if Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		#animated_sprite.play("wall")
	
	#increment wall timer
	wall_time += delta
	#start sliding after timer or when "f" is pressed
	if wall_time >= SLIDE_TIME:
		animated_sprite.play("wall")
		sliding_speed += 150 * delta
		sliding_speed = clamp(sliding_speed, 0, MAX_SLIDING_SPEED)
		velocity.y = sliding_speed
	else:
		velocity.y = 0

	#start climbing
	if wall_time < SLIDE_TIME:
		if Input.is_action_pressed("climb_up"):
			animated_sprite.play("climbing")
			velocity.y = -100
		elif Input.is_action_pressed("fall"):
			animated_sprite.play("wall_slide")
			velocity.y = 100
	
	# Jump off the wall in the direction held down
	if Input.is_action_just_pressed("jump"):
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0 and direction != last_jump_direction:  # If A or D is held down
			velocity.x = direction * 180.0  # Adjust this value for launch speed
			velocity.y = JUMP_VELOCITY * 0.85  # Adjust jump velocity if necessary
			last_jump_direction = direction
			state = AIR  # Switch back to air state after jumping
	if is_on_floor():
		state = FLOOR

func is_near_wall():
	return wall_checker.is_colliding()
