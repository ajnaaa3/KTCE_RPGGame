extends Node2D

# ====================
# UI-Referenzen
# ====================

@onready var music_player: AudioStreamPlayer2D = %BGMMusic
@onready var start_button: Button = %StartGameButton
@onready var back_button: Button = %BackButton
@onready var counter_label: Label = $StartButtonWrapper/SelectedCounterLabel



# ====================
# Character-Auswahl
# ====================

var selected_slots: Array[CharacterSlot] = []
const MAX_PLAYERS := 4


func _ready() -> void:
	# 1. Musik
	if GameSettings.music_enabled:
		music_player.play()
	else:
		music_player.stop()

	# 2. Back Button
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		print("FEHLER: BackButton nicht gefunden")

	# 3. Start Button
	start_button.disabled = true
	start_button.text = "Start Game"
	start_button.pressed.connect(_on_start_game_pressed)

	# Counter Label (Anzeige für Auswahl)
	counter_label.text = "Selected: 0/4"
	counter_label.visible = true

	# 4. Character Slots verbinden (aus Quadrants)
	for q in get_tree().get_nodes_in_group("quadrants"):
		q.slot_selected.connect(_on_slot_selected)


# ====================
# Slot-Auswahl
# ====================

func _on_slot_selected(slot: CharacterSlot) -> void:
	if slot in selected_slots:
		selected_slots.erase(slot)
		slot.set_selected(false)
	else:
		if selected_slots.size() >= MAX_PLAYERS:
			return
		selected_slots.append(slot)
		slot.set_selected(true)

	_update_start_button()


func _update_start_button() -> void:
	var count := selected_slots.size()

	if count > 0:
		start_button.disabled = false
		counter_label.visible = true
		counter_label.text = "Selected: " + str(count) + "/4"
	else:
		start_button.disabled = true
		counter_label.visible = false


# ====================
# Szenenwechsel
# ====================

func _on_start_game_pressed() -> void:
	if selected_slots.is_empty():
		return

	music_player.stop()

	var players_party: Array[Character] = []
	for slot in selected_slots:
		players_party.append(slot.character)

	GameSettings.playersParty = players_party

	print("PLAYERS PARTY:")
	for c in players_party:
		print("-", c.name)

	get_tree().change_scene_to_file("res://scenes/battle.tscn")


func _on_back_button_pressed() -> void:
	print("Wechsel zum Menü...")
	music_player.stop()

	var menu_scene_path := "res://scenes/menu.tscn"
	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
	else:
		print("FEHLER: menu.tscn nicht gefunden")
