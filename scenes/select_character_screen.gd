extends Control

# ====================
# UI-Referenzen
# ====================

@onready var confirm_button: Button = %StartGameButton
@onready var menu_button: Button = %BackButton
@onready var music_player: AudioStreamPlayer = %BGMMusic


# ====================
# Auswahl-Logik
# ====================

# Liste aller aktuell ausgewählten Charakter-Slots
var selected_slots: Array[CharacterSlot] = []

# Maximale Anzahl an spielbaren Charakteren
const MAX_PLAYERS := 4

# ButtonGroup für Toggle-Verhalten der Slots
var slot_group := ButtonGroup.new()


func _ready() -> void:
	# Hintergrundmusik abspielen, falls erlaubt
	if music_player and GameSettings.music_enabled:
		music_player.play()

	# Start-Button initial deaktivieren
	confirm_button.disabled = true
	confirm_button.text = "Select characters"
	confirm_button.modulate = Color(1, 1, 1, 0.5)
	confirm_button.pressed.connect(_on_confirm_pressed)

	# Zurück-zum-Menü-Button verbinden
	menu_button.pressed.connect(_on_menu_pressed)

	# Alle Quadranten durchgehen und Slot-Signale verbinden
	for q in get_tree().get_nodes_in_group("quadrants"):
		q.slot_selected.connect(_on_slot_selected)

		# Slots innerhalb des Quadranten konfigurieren
		for slot in q.get_node("VBoxContainer/SlotsContainer").get_children():
			if slot is Button:
				slot.toggle_mode = true
				slot.button_group = slot_group


# ====================
# Slot-Auswahl
# ====================

func _on_slot_selected(slot: CharacterSlot) -> void:
	# Falls der Slot bereits ausgewählt ist → deselektieren
	if slot in selected_slots:
		selected_slots.erase(slot)
		slot.set_selected(false)
	else:
		# Falls bereits 4 Charaktere ausgewählt sind → keine Aktion
		if selected_slots.size() >= MAX_PLAYERS:
			return

		# Slot zur Auswahl hinzufügen
		selected_slots.append(slot)
		slot.set_selected(true)

	# Start-Button aktualisieren
	_update_confirm_button()


# ====================
# Start-Button-Status
# ====================

func _update_confirm_button() -> void:
	if selected_slots.size() >= 1:
		confirm_button.disabled = false
		confirm_button.text = "Start Game (" + str(selected_slots.size()) + "/4)"
		confirm_button.modulate = Color(1, 1, 1, 1)
	else:
		confirm_button.disabled = true
		confirm_button.text = "Select characters"
		confirm_button.modulate = Color(1, 1, 1, 0.5)


# ====================
# Spiel starten
# ====================

func _on_confirm_pressed() -> void:
	# Hintergrundmusik stoppen
	if music_player:
		music_player.stop()

	# Zusammenstellung der Spieler-Party
	var players_party: Array = []
	for slot in selected_slots:
		players_party.append(slot.character)

	# Party global speichern
	GameSettings.playersParty = players_party

	# Debug-Ausgabe
	print("PLAYERS PARTY:")
	for c in GameSettings.playersParty:
		print("- ", c.name)

	# Wechsel zur Kampfszene
	get_tree().change_scene_to_file("res://scenes/battle.tscn")


# ====================
# Zurück zum Menü
# ====================

func _on_menu_pressed() -> void:
	print("MENU PRESSED")
	if music_player:
		music_player.stop()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
