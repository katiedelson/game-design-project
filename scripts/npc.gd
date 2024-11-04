extends CharacterBody2D


@export var npc_id: String
@export var npc_name: String
#dialogue vars
@onready var dialogue_manager: Node2D = $DialogueManager
@export var dialogue_resource: Dialogue
var current_state = "start"
var current_branch_index = 0

# quest vars
@export var quests: Array[Quest] = []
var quest_manager: Node = null


func _ready():
	# load dialogue data
	dialogue_resource.load_from_json("res://resources/dialogue/dialogue_data.json")
	#initialize npc ref
	dialogue_manager.npc = self
	# get quest manager
	quest_manager = Global.player.quest_manager
	print("NPC ready. Quests loaded: ", quests.size())
	
func start_dialogue():
	var npc_dialogues = dialogue_resource.get_npc_dialogue(npc_id)
	if npc_dialogues.is_empty():
		return
	dialogue_manager.show_dialogue(self)

# get current branch dialogue
func get_current_dialogue():
	var npc_dialogues = dialogue_resource.get_npc_dialogue(npc_id)
	if current_branch_index < npc_dialogues.size():
		for dialogue in npc_dialogues[current_branch_index]["dialogues"]:
			if dialogue["state"] == current_state:
				return dialogue
	return null

#update dialogue branch
func set_dialogue_tree(branch_index):
	current_branch_index = branch_index
	current_state = "start"

#update dualligue state
func set_dialogue_state(state):
	current_state = state

# offer quest at required branch
func offer_quest(quest_id: String):
	print("Attempting to offer quest: ", quest_id)
	
	for quest in quests:
		if quest.quest_id == quest_id and quest.state == "not_started":
			quest.state = "in_progress"
			quest_manager.add_quest(quest)
			return
	print("quest not found or started already")
	
	# returns quest dialogue
func get_quest_dialogue() -> Dictionary:
	var active_quests = quest_manager.get_active_quests()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective.target_id == npc_id and objective.target_type == "talk_to" and not objective.is_completed:
				if current_state == "start":
					return {"text": objective.objective_dialogue, "options": {}}
	return {"text": "", "options": {}}
