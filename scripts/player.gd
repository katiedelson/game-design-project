extends CharacterBody2D

enum {AIR, FLOOR, WALL, SLIDE}
var state = AIR
var wall_time = 0.0
var sliding_speed = 100

const JUMP_VELOCITY = -300.0
const SLIDE_TIME = 3.0
const SPEED = 180
const MAX_SLIDING_SPEED = 15000

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_checker_left: RayCast2D = $WallCheckerLEFT
@onready var wall_checker_right: RayCast2D = $WallCheckerRIGHT


func _physics_process(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:  # Only apply movement if we're not on a wall
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if state != WALL and state != SLIDE:
		if direction < 0: 
			animated_sprite.flip_h = true
		elif direction > 0: 
			animated_sprite.flip_h = false
	# Process the player's state
	match state:
		AIR: air_state()
		FLOOR: floor_state()
		WALL: wall_state(delta)
		SLIDE: slide_state(delta)
		
	move_and_slide()
	
func air_state():
	wall_time = 0
	sliding_speed = 0
	animated_sprite.play("jump")
	if is_on_floor():
		state = FLOOR
	elif (is_near_left_wall() or is_near_right_wall()) and velocity.y > 0:
		state = WALL

func floor_state():
	wall_time = 0
	sliding_speed = 0
	if velocity.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		state = AIR
	if (is_near_left_wall() or is_near_right_wall()) and velocity.y > 0:
		state = WALL
	elif not is_on_floor():
		state = AIR
		
func wall_state(delta):
	# Lock horizontal movement and prevent sliding
	velocity.x = 0
	velocity.y = 0  # Prevent falling
	
	animated_sprite.play("climb")
	
	#increment wall timer
	wall_time += delta
	#start sliding after timer or when "f" is pressed
	if wall_time >= SLIDE_TIME or Input.is_action_pressed("fall"):
		state = SLIDE
	else:
		velocity.y = 0

	# Jump off the wall in the direction held down
	if Input.is_action_just_pressed("jump"):
		var direction = Input.get_axis("move_left", "move_right")
		if is_near_left_wall() and direction < 0:
			velocity.x = 180.0  # Adjust this value for launch speed
			velocity.y = JUMP_VELOCITY * 0.85  # Adjust jump velocity if necessary
			state = AIR  # Switch back to air state after jumping
		elif is_near_right_wall() and direction > 0:
			velocity.x = -180
			velocity.y = JUMP_VELOCITY * 0.85
			state = AIR
			
	if is_on_floor():
		state = FLOOR
	elif not is_near_left_wall() and not is_near_right_wall():
		state = AIR

func slide_state(delta):
	velocity.x = 0
	animated_sprite.play("wall_slide")
	sliding_speed += 150 * delta
	sliding_speed = clamp(sliding_speed, 0, MAX_SLIDING_SPEED)
	velocity.y = sliding_speed
	
	# still be able to jump:
	if Input.is_action_just_pressed("jump"):
		var direction = Input.get_axis("move_left", "move_right")
		if is_near_left_wall() and direction < 0:
			velocity.x = 180.0  # Adjust this value for launch speed
			velocity.y = JUMP_VELOCITY * 0.85  # Adjust jump velocity if necessary
			state = AIR  # Switch back to air state after jumping
		elif is_near_right_wall() and direction > 0:
			velocity.x = -180
			velocity.y = JUMP_VELOCITY * 0.85
			state = AIR
	
	if not is_near_left_wall() and not is_near_right_wall():
		state = AIR
	elif is_on_floor():
		state = FLOOR

func is_near_left_wall():
	return wall_checker_left.is_colliding()
func is_near_right_wall():
	return wall_checker_right.is_colliding()
