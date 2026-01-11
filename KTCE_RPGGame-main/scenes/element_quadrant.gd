extends Panel
class_name ElementQuadrant

@export var element: Type.Type
@export var slot_scene: PackedScene

@onready var slots_container: Control = $VBoxContainer/SlotsContainer
@onready var title_label: Label = $VBoxContainer/Label

signal slot_selected(slot: CharacterSlot)

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/select_player.tscn")

func _ready() -> void:
	title_label.text = Type.Type.keys()[element]
	load_characters_for_element()

func load_characters_for_element() -> void:
	clear_slots()

	var dir := DirAccess.open("res://resources/Characters")
	if dir == null:
		return

	dir.list_dir_begin()
	var file := dir.get_next()

	while file != "":
		if file.ends_with(".tres"):
			var character: Character = load("res://resources/Characters/" + file)
			if character.type == element:
				add_character(character)
		file = dir.get_next()

	dir.list_dir_end()

func add_character(character: Character) -> void:
	var slot: CharacterSlot = slot_scene.instantiate()
	slots_container.add_child(slot)
	slot.set_character(character)

	slot.pressed.connect(func():
		slot_selected.emit(slot)
	)

func clear_slots() -> void:
	for child in slots_container.get_children():
		child.queue_free()
