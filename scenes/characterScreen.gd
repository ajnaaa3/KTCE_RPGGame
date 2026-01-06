extends Node2D 

# ===== Referenzen =====

@onready var music_player: AudioStreamPlayer2D = %BGMMusic 
@onready var start_button: Button = %StartGameButton

# Unique Name für den Back Button (Rechtsklick auf BackButton -> Access as Unique Name)
@onready var back_button: Button = %BackButton 

# Player-Elemente
@onready var player1_panel: Control = %Player1 
@onready var player2_panel: Control = %Player2
@onready var player3_panel: Control = %Player3
@onready var player4_panel: Control = %Player4

@onready var char_panels: Array[Control] = [
	player1_panel, 
	player2_panel, 
	player3_panel, 
	player4_panel 
]

var selected_char_index: int = -1 

func _ready() -> void:
	# 1. Musik-Logik (Prüft globale Einstellungen)
	if GameSettings.music_enabled:
		music_player.play()
	else:
		music_player.stop()

	# 2. Back Button Verbindung (Einfach via Unique Name)
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		print("FEHLER: BackButton mit Unique Name '%' nicht gefunden!")

	# 3. Start-Button vorbereiten
	start_button.disabled = true
	start_button.pressed.connect(_on_start_game_pressed)
	
	# 4. Player-Felder vorbereiten
	for i in range(char_panels.size()):
		var panel = char_panels[i]
		panel.gui_input.connect(func(event): _handle_player_input(event, i))
		_set_button_style(panel, false)


# Manuelle Klick-Erkennung für Player-Felder
func _handle_player_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_select_character(index)

func _set_button_style(button: Control, is_selected: bool) -> void: 
	if is_selected:
		button.modulate = Color(0.7, 1.0, 0.7, 1.0)
	else:
		button.modulate = Color(1.0, 1.0, 1.0, 1.0) 

func _select_character(index: int) -> void:
	if index == selected_char_index:
		selected_char_index = -1
	else:
		selected_char_index = index
		
	for i in range(char_panels.size()):
		_set_button_style(char_panels[i], i == selected_char_index)
		
	start_button.disabled = (selected_char_index == -1)

# ===== Szenenwechsel-Callbacks =====

func _on_start_game_pressed() -> void:
	if selected_char_index != -1:
		# Speichere den gewählten Charakter im globalen Skript, damit der Kampf-Screen ihn kennt
		# GameSettings.selected_player_id = selected_char_index 
		
		music_player.stop() 
		var battle_scene_path = "res://scenes/battle.tscn"
		
		if ResourceLoader.exists(battle_scene_path):
			get_tree().change_scene_to_file(battle_scene_path)

func _on_back_button_pressed() -> void:
	print("Wechsel zum Menü...")
	music_player.stop() 
	
	# Stelle sicher, dass der Pfad zu deinem Hauptmenü stimmt (eventuell "res://scenes/main_menu.tscn"?)
	var menu_scene_path = "res://scenes/menu.tscn"
	
	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
	else:
		print("FEHLER: menu.tscn nicht gefunden!")
