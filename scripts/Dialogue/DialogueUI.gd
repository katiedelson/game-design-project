extends Control

@onready var panel: Panel = $CanvasLayer/Panel
@onready var dialogue_speaker: Label = $CanvasLayer/Panel/DialogueBox/DialogueSpeaker
@onready var dialogue_text: Label = $CanvasLayer/Panel/DialogueBox/DialogueText
@onready var dialogue_options: HBoxContainer = $CanvasLayer/Panel/DialogueBox/DialogueOptions

func _ready():
	hide_dialogue()

func show_dialogue(speaker, text, options):
	panel.visible = true
	
	dialogue_speaker.text = speaker
	dialogue_text.text = text
	
	#removing existing options
	for option in dialogue_options.get_children():
		dialogue_options.remove_child(option)
	
	#populate options
	for option in options.keys():
		var button = Button.new()
		button.text = option
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_on_option_selected.bind(option))
		dialogue_options.add_child(button)

#handle response selection
func _on_option_selected(option):
	get_parent().handle_dialogue_choice(option)

func hide_dialogue():
	panel.visible = false
	Global.player.can_move = true


func _on_close_button_pressed() -> void:
	hide_dialogue()
