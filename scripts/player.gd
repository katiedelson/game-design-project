extends CharacterBody2D

enum {AIR, FLOOR, WALL, SLIDE}
var state = AIR
var wall_time = 0.0
var sliding_speed = 100
var can_move = true

const JUMP_VELOCITY = -300.0
const SLIDE_TIME = 3.0
const SPEED = 180
const MAX_SLIDING_SPEED = 15000

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_checker_left: RayCast2D = $WallCheckerLEFT
@onready var wall_checker_right: RayCast2D = $WallCheckerRIGHT
@onready var interact_checker: RayCast2D = $InteractChecker

var jump_count = 0
var last_wall = ""  # Tracks the last wall the player attached to

func _ready():
	Global.player = self
func _physics_process(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = Input.get_axis("move_left", "move_right")
	if can_move:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if state != WALL and state != SLIDE:
			if direction < 0: 
				animated_sprite.flip_h = true
			elif direction > 0: 
				animated_sprite.flip_h = false
	
		#flip interaction checker
		if direction < 0: 
			interact_checker.rotation_degrees = 90
		elif direction > 0: 
			interact_checker.rotation_degrees = -90

		# Process the player's state
		match state:
			AIR: air_state()
			FLOOR: floor_state()
			WALL: grab_state(delta)
			SLIDE: slide_state(delta)

		move_and_slide()

func air_state():
	wall_time = 0
	sliding_speed = 0
	animated_sprite.play("jump")

	if Input.is_action_just_pressed("jump") and jump_count < 1:
		velocity.y = JUMP_VELOCITY
		state = AIR
		jump_count += 1

	if is_on_floor():
		state = FLOOR
		jump_count = 0
	elif can_attach_to_wall() and velocity.y > 0:
		state = WALL  # Enter wall state

func floor_state():
	last_wall = ""  # Reset wall tracking on the floor
	jump_count = 0
	wall_time = 0
	sliding_speed = 0

	if velocity.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		state = AIR
	elif can_attach_to_wall() and velocity.y > 0:
		state = WALL  # Attach to the wall
	elif not is_on_floor():
		state = AIR

func grab_state(delta):
	velocity.x = 0
	animated_sprite.play("climb")
	wall_time += delta

	# Start sliding after time or when crouch is pressed
	if wall_time >= SLIDE_TIME or Input.is_action_pressed("crouch"):
		state = SLIDE
	else:
		velocity.y = 0

	# Jump off the wall in the direction held down
	if Input.is_action_just_pressed("jump"):
		if is_near_left_wall():
			velocity.y = JUMP_VELOCITY * 0.9
			last_wall = "left"  # Record the wall side
			state = AIR
		elif is_near_right_wall():
			velocity.y = JUMP_VELOCITY * 0.9
			last_wall = "right"
			state = AIR

	if is_on_floor():
		state = FLOOR
	elif not (is_near_left_wall() or is_near_right_wall()):
		state = AIR

func slide_state(delta):
	velocity.x = 0
	animated_sprite.play("wall_slide")
	sliding_speed += 150 * delta
	sliding_speed = clamp(sliding_speed, 0, MAX_SLIDING_SPEED)
	velocity.y = sliding_speed

	if Input.is_action_just_pressed("jump"):
		if is_near_left_wall():
			velocity.y = JUMP_VELOCITY * 0.9
			last_wall = "left"
			state = AIR
		elif is_near_right_wall():
			velocity.y = JUMP_VELOCITY * 0.9
			last_wall = "right"
			state = AIR

	if not (is_near_left_wall() or is_near_right_wall()):
		state = AIR
	elif is_on_floor():
		state = FLOOR

func is_near_left_wall() -> bool:
	return wall_checker_left.is_colliding()

func is_near_right_wall() -> bool:
	return wall_checker_right.is_colliding()
#
#func is_near_interation() -> bool:
	#return interact_checker.is_colliding()

func can_attach_to_wall() -> bool:
	# Only allow attaching if the player is not on the same wall side
	if is_near_left_wall() and last_wall != "left" and animated_sprite.flip_h == false:
		return true
	if is_near_right_wall() and last_wall != "right" and animated_sprite.flip_h == true:
		return true
	return false

func reset_double_jump():
	jump_count = 0
func reset_last_wall():
	last_wall = ""

func _input(event):
	if can_move:
		if event.is_action_pressed("interact"):
			var target = interact_checker.get_collider()
			if target != null:
				if target.is_in_group("NPC"):
					print("I'm talking to an NPC!")
					can_move = false
					target.start_dialogue()
				if target.is_in_group("items"):
					print("I'm interacting with an item!")
					#to-do: check if item is needed
					#to-do: remove item
					target.start_interact()
