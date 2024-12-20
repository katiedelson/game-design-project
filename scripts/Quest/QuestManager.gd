### quest_manager.gd

extends Node2D

class_name QuestManager

@onready var quest_ui: Control = $QuestUI

# vars
signal quest_updated(quest_id: String)
signal objective_updated(quest_id: String, objective_id: String)
signal quest_list_updated()
var quests = {}
var current_quest_id: String = ""

func add_quest(quest: Quest):
	quests[quest.quest_id] = quest
	quest_updated.emit(quest.quest_id)

func _remove_quest(quest_id: String):
	quests.erase(quest_id)
	quest_list_updated.emit()
	
func get_quest(quest_id: String) -> Quest:
	return quests.get(quest_id, null)

func update_quest(quest_id: String, state: String):
	var quest = get_quest(quest_id)
	if quest:
		quest.state = state
		quest_updated.emit(quest_id)
		if state == "completed":
			_remove_quest(quest_id)
			
func get_active_quests() -> Array:
	var active_quests = []
	for quest in quests.values():
		if quest.state == "in_progress":
			active_quests.append(quest)
	return active_quests

func complete_objective(quest_id: String, objective_id: String):
	var quest = get_quest(quest_id)
	if quest:
		quest.complete_objective(objective_id)
		objective_updated.emit(quest_id, objective_id)
						
func show_quest_log():
	quest_ui.show_hide_log()

######## CHAT GPT ADDED ########

#func set_current_quest(quest_id: String):
	#current_quest_id = quest_id
	#emit_signal("quest_updated", quest_id)
#
#func get_current_quest() -> Quest:
	#return get_quest(current_quest_id)

func is_first_active_objective(quest_id: String, objective_id: String) -> bool:
	var quest = get_quest(quest_id)
	if quest and quest.state == "in_progress" and quest.objectives.size() > 0:
		var first_objective = quest.objectives[0]
		return first_objective.id == objective_id and first_objective.is_active()
	return false
