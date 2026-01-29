extends Control

@onready var confirm_btn: Button = $CenterContainer/VBoxContainer/Button

var selected_slot: Button = null

func _ready():
	confirm_btn.disabled = true

	for slot in get_tree().get_nodes_in_group("character_slots"):
		slot.slot_selected.connect(_on_slot_selected)

func _on_slot_selected(slot: Button):
	if selected_slot:
		selected_slot.modulate = Color.WHITE

	selected_slot = slot
	selected_slot.modulate = Color(0.7, 0.9, 1.0) # light blue
	confirm_btn.disabled = false
