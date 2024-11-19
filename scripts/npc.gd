extends CharacterBody2D

@onready var dialogue_manager: Node2D = $DialogueManager

# Dialogue Vars
@export var npc_id: String
@export var npc_name: String
@export var dialogue_resource: Dialogue
var current_state = "start"
var current_branch_index = 0

# Quest Vars
@export var quests: Array[Quest] = [] 
var quest_manager : Node = null

func _ready():
	# Init
	quest_manager = Global.player.quest_manager
	dialogue_manager.npc = self
	dialogue_resource = Dialogue.new()
	dialogue_resource.load_from_json("res://resources/dialogue/dialogue_data.json")
	print("NPC Ready: Quests loaded ", quests.size())

# Starts dialogue
func start_dialogue():
	var npc_dialogues = dialogue_resource.get_npc_dialogue(npc_id)
	if npc_dialogues.is_empty():
		return 
	dialogue_manager.show_dialogue(self)

# Gets current dialogue branch value
func get_current_dialogue():
	var npc_dialogues = dialogue_resource.get_npc_dialogue(npc_id)
	if current_branch_index < npc_dialogues.size():
		for dialogue in npc_dialogues[current_branch_index]["dialogues"]:
			if dialogue["state"] == current_state:
				return dialogue
	return null 

# Updates dialogue state
func set_dialogue_branch(branch_index):
	current_branch_index = branch_index
	current_state = "start"
	
func set_dialogue_state(state):
	current_state = state

# Offer quest at required branch
func offer_quest(quest_id: String):
	print("Attempting to offer quest:", quest_id)
	for quest in quests:
		if quest.quest_id == quest_id and quest.state == "not_started":
			quest.state = "in_progress"
			quest_manager.add_quest(quest) 
			return
	print("Quest not found or already started")

#Gets quest dialogue
func get_quest_dialogue() -> Dictionary:
	var active_quests = quest_manager.get_active_quests()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective.target_id == npc_id and objective.target_type == "talk_to" and not objective.is_completed:
				if current_state == "start":
					return {"text": objective.objective_dialogue, "options": {}}
	return {"text": "", "options": {}}

##func get_quest_dialogue() -> Dictionary:
	##if quest_manager.selected_quest:
		##var objectives = quest_manager.selected_quest.objectives
		### Only show quest dialogue if this NPC's objective is first and active
		##if objectives.size() > 0 and objectives[0].target_id == npc_id and objectives[0].target_type == "talk_to" and not objectives[0].is_completed:
			##return {"text": objectives[0].objective_dialogue, "options": []}
	##return {"text": "", "options": []}  # Return empty dialogue if no valid quest dialogue
#func get_quest_dialogue() -> Dictionary:
	#var active_quests = quest_manager.get_active_quests()
	#for quest in active_quests:
		#for objective in quest.objectives:
			#if objective.target_id == npc_id and objective.target_type == "talk_to" and not objective.is_completed:
				#if current_state == "start":
					#return {"text": objective.objective_dialogue, "options": {}}
	#return {"text": "", "options": {}}
