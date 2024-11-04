### Obejctives.gd

extends Resource

class_name Objectives

@export var id: String
@export var description: String
@export var target_id: String
@export var target_type: String
# talk_to obectice
@export var objective_dialogue: String = ""
#c ollection objective
@export var required_quantity: int = 0
@export var collected_quantity: int = 0
# objectve state
@export var is_completed: bool = false
