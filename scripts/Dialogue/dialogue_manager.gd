extends Node2D

@onready var dialogue_ui: Control = $DialogueUI

var npc: Node = null

#show dialogue with data
func show_dialogue(npc, text = "", options = {}):
	if text != "":
		#show empty box
		dialogue_ui.show_dialogue(npc.npc_name, text, options)
	else:
		# show quest related dialogues
		var quest_dialogue = npc.get_quest_dialogue()
		if quest_dialogue["text"] != "":
			dialogue_ui.show_dialogue(npc.npc_name, quest_dialogue["text"], quest_dialogue["options"])
		# show non-quest related dialogues
		else:
			var dialogue = npc.get_current_dialogue()
			if dialogue == null:
				return
			dialogue_ui.show_dialogue(npc.npc_name, dialogue["text"], dialogue["options"])

func hide_dialogue():
	dialogue_ui.hide_dialogue()

#dialogue state management
func handle_dialogue_choice(option):
	# get current dialogue branch
	var current_dialogue = npc.get_current_dialogue()
	if current_dialogue == null:
		return
		
	# update state
	var next_state = current_dialogue["options"].get(option, "start")
	npc.set_dialogue_state(next_state)
	
	# handle state transitions
	if next_state == "end":
		if npc.current_branch_index < npc.dialgue_resource.get_npc_dialogue(npc.npc_id):
			npc.set_dialogue_branch(npc.current_branch_index + 1)
		hide_dialogue()
	elif next_state == "exit":
		npc.set_dialogue_state("start")
		hide_dialogue()
	elif next_state == "give_quests":
		if npc.dialogue_resource.get_npc_dialogue(npc.npc_id)[npc.current_branch_index]["branch_id"] == "npc_default":
			offer_remaining_quests()
		else:
			offer_quests(npc.dialogue_resource.get_npc_dialogue(npc.npc_id)[npc.current_branch_index]["branch_id"])
		show_dialogue(npc)
	else:
		show_dialogue(npc)

# at branch, offer all currently available quests
func offer_quests(branch_id: String):
	for quest in npc.quests:
		if quest.unlock_id == branch_id and quest.state == "not_started":
			npc.offer_quest(quest.quest_id)

# at default branch, offer all previously unaccepted quests
func offer_remaining_quests():
	for quest in npc.quests:
		if quest.state == "not_started":
			npc.offer_quest(quest.quest_id)
