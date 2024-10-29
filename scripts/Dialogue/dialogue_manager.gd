extends Node2D

@onready var dialogue_ui: Control = $DialogueUI

var npc: Node = null

#show dialogue with data
func show_dialogue(npc, text = "", options = {}):
	if text != "":
		#show empty box
		dialogue_ui.show_dialogue(npc.npc_name, text, options)
	else:
		# show populated data
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
		pass
	else:
		show_dialogue(npc)
