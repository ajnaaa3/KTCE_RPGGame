extends Control

@onready var confirm_button: Button = $CenterContainer/VBoxContainer/Button

var selected_slot: CharacterSlot = null
var slot_group := ButtonGroup.new()


func _ready() -> void:
	confirm_button.disabled = true
	confirm_button.text = "Select a character"
	confirm_button.modulate = Color(1, 1, 1, 0.5)

	for q in get_tree().get_nodes_in_group("quadrants"):
		q.slot_selected.connect(_on_slot_selected)

		for slot in q.get_node("VBoxContainer/SlotsContainer").get_children():
			if slot is Button:
				slot.toggle_mode = true
				slot.button_group = slot_group


func _on_slot_selected(slot: CharacterSlot) -> void:
	selected_slot = slot

	var style := StyleBoxFlat.new()
	style.set_border_width_all(2)
	style.border_color = Color(0.8, 0.9, 1.0)
	style.bg_color = Color(0.25, 0.25, 0.25)

	for btn in slot_group.get_buttons():
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_stylebox_override("hover")
		btn.remove_theme_stylebox_override("pressed")

	slot.add_theme_stylebox_override("normal", style)
	slot.add_theme_stylebox_override("hover", style)
	slot.add_theme_stylebox_override("pressed", style)

	confirm_button.disabled = false
	confirm_button.text = "Confirm Selection"
	confirm_button.modulate = Color(1, 1, 1, 1)



func _on_confirm_pressed() -> void:
	if selected_slot:
		print(selected_slot.character.name)
