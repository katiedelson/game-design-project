extends CharacterBody2D

enum {AIR, FLOOR, WALL}
var state = AIR
var last_jump_direction = 0

const INITIAL_SLIDING_SPEED = 5.0  # Initial speed for sliding
const MAX_SLIDING_SPEED = 15000.0  # Maximum sliding speed
const SLIDING_ACCELERATION = 100.0  # How much speed increases per second

const SPEED = 180.0
const JUMP_VELOCITY = -300.0
const WALL_SLIDING_SPEED = 1500


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_checker: RayCast2D = $WallChecker

var sliding_speed = INITIAL_SLIDING_SPEED

func _physics_process(delta: float):
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:  # Only apply movement if we're not on a wall
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	match state:
		AIR: air_state()
		FLOOR: floor_state()
		WALL: wall_state(delta, direction)
	
	if direction < 0: 
		animated_sprite.flip_h = true
		wall_checker.rotation_degrees = 90
	elif direction > 0: 
		animated_sprite.flip_h = false
		wall_checker.rotation_degrees = -90
	
	move_and_slide()

func air_state():
	animated_sprite.play("jump")
	sliding_speed = INITIAL_SLIDING_SPEED
	if is_on_floor(): state = FLOOR
	elif is_near_wall() and velocity.y > 0:
		state = WALL
		velocity.x = 0

	
func floor_state():
	#reset jump direction once youre on the floor
	last_jump_direction = 0
	sliding_speed = INITIAL_SLIDING_SPEED
	if velocity.x != 0: animated_sprite.play("run")
	else: animated_sprite.play("idle")
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		state = AIR
	elif not is_on_floor():
		state = AIR
	
func wall_state(delta, direction):
	# gradually increase the sliding speed while on the wall
	sliding_speed = min(sliding_speed + SLIDING_ACCELERATION * delta, MAX_SLIDING_SPEED)
	
	# Lock horizontal movement
	velocity.x = 0
	
	# Apply the increasing sliding speed to the vertical velocity
	velocity.y = sliding_speed
	
	# transition back to floor or air
	if is_on_floor(): state = FLOOR
	elif not is_near_wall(): state = AIR
	#add wall sliding animation later
	animated_sprite.play("wall")
	

	if direction != last_jump_direction and Input.is_action_pressed("jump") and Input.is_action_pressed("move_left"):
		last_jump_direction = direction
		velocity.y = JUMP_VELOCITY * .85
		state = AIR
	elif direction != last_jump_direction and Input.is_action_pressed("jump") and Input.is_action_pressed("move_right"):
		last_jump_direction = direction
		velocity.y = JUMP_VELOCITY * .85
		state = AIR

func is_near_wall():
	return wall_checker.is_colliding()
