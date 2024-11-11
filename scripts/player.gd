extends CharacterBody2D

# scene-tree node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_checker_left: RayCast2D = $WallCheckerLEFT
@onready var wall_checker_right: RayCast2D = $WallCheckerRIGHT
@onready var interact_checker: RayCast2D = $InteractChecker
@onready var amount: Label = $HUD/Points/Amount
@onready var quest_tracker: ColorRect = $HUD/QuestTracker
@onready var title: Label = $HUD/QuestTracker/Details/Title
@onready var objectives: VBoxContainer = $HUD/QuestTracker/Details/Objectives

@onready var quest_manager: Node2D = $QuestManager

# states
enum {AIR, FLOOR, WALL, SLIDE}

# variables
var state = AIR
var wall_time = 0.0
var sliding_speed = 100
var can_move = true
var jump_count = 0
var last_wall = ""  # tracks the last wall the player attached to

const JUMP_VELOCITY = -300.0
const SLIDE_TIME = 3.0
const SPEED = 180
const MAX_SLIDING_SPEED = 15000

# dialog & quest vars
var selected_quest: Quest = null
var point_amount = 0

func _ready():
	Global.player = self
	quest_tracker.visible = false
	update_points()
	
	# signal connection
	quest_manager.quest_updated.connect(_on_quest_updated)
	quest_manager.objective_updated.connect(_on_objective_updated)
	
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
					can_move = false
					target.start_dialogue()
					check_quest_objectives(target.npc_id, "talk_to")
				elif target.is_in_group("Item"):
					print("I'm interacting with an item!")
					if is_item_needed(target.item_id):
						check_quest_objectives(target.item_id, "collection", target.item_quantity)
						target.queue_free()
					else:
						print("item not needed for any active quest")
	# open/close quest log
		if event.is_action_pressed("ui_quest_menu"):
			quest_manager.show_quest_log()

# check if quest item is needed
func is_item_needed(item_id: String) -> bool:
	if selected_quest != null:
		for objective in selected_quest.objectives:
			if objective.target_id == item_id and objective.target_type == "collection" and not objective.is_completed:
				return true
	return false

func check_quest_objectives(target_id: String, target_type: String, quantity: int = 1):
	if selected_quest == null:
		return
	
	# Update objectives
	var objective_updated = false
	for objective in selected_quest.objectives:
		if objective.target_id == target_id and objective.target_type == target_type and not objective.is_completed:
			print("Completing objective for quest: ", selected_quest.quest_name)
			selected_quest.complete_objective(objective.id, quantity)
			objective_updated = true
			break
	
	# Provide rewards
	if objective_updated:
		if selected_quest.is_completed():
			handle_quest_completion(selected_quest)
	
		# Update UI
		update_quest_tracker(selected_quest)

# point rewards
func handle_quest_completion(quest: Quest):
	for reward in quest.rewards:
		if reward.reward_type == "points":
			point_amount += reward.reward_amount
			update_points()
	update_quest_tracker(quest)
	quest_manager.update_quest(quest.quest_id, "completed")


# update point UI
func update_points():
	amount.text = str(point_amount)

# update tracker UI
# Update tracker UI
func update_quest_tracker(quest: Quest):
	# if we have an active quest, populate tracker
	if quest:
		quest_tracker.visible = true
		title.text = quest.quest_name	
		
		for child in objectives.get_children():
			objectives.remove_child(child)
			
		for objective in quest.objectives:
			var label = Label.new()
			label.text = objective.description
			
			if objective.is_completed:
				label.add_theme_color_override("font_color", Color(0, 1, 0))
			else:
				label.add_theme_color_override("font_color", Color(1,1, 1))
				
			objectives.add_child(label)
	# no active quest, hide tracker		
	else:
		quest_tracker.visible = false

# Update tracker if quest is complete
func _on_quest_updated(quest_id: String):
	var quest = quest_manager.get_quest(quest_id)
	if quest == selected_quest:
		update_quest_tracker(quest)
	selected_quest = null
	
# Update tracker if objective is complete
func _on_objective_updated(quest_id: String, objective_id: String):
	if selected_quest and selected_quest.quest_id == quest_id:
		update_quest_tracker(selected_quest)
	selected_quest = null
