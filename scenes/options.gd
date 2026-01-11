extends Node2D

# UI Referenzen
@onready var check_sound: CheckButton = %CheckButton_Sound
@onready var check_music: CheckButton = %CheckButton_Music
@onready var option_mode: OptionButton = %OptionButton_Mode
@onready var btn_back: Button = %Back
@onready var btn_save: Button = %Save

const MAIN_MENU_PATH := "res://scenes/menu.tscn"

func _ready() -> void:
	option_mode.clear() 
	option_mode.add_item("Versus PC")
	option_mode.add_item("Multiplayer (2P)")
	
	_load_current_settings()

	btn_back.pressed.connect(_on_back_pressed)
	btn_save.pressed.connect(_on_save_pressed)

func _load_current_settings() -> void:
	check_sound.button_pressed = GameSettings.sfx_enabled
	check_music.button_pressed = GameSettings.music_enabled
	option_mode.selected = 1 if GameSettings.game_mode == "Multiplayer (2P)" else 0

func _on_back_pressed() -> void:
	print("Abbruch: Zurück zum Hauptmenü...")
	_change_to_main_menu()

func _on_save_pressed() -> void:
	var sfx_val = check_sound.button_pressed
	var music_val = check_music.button_pressed
	var game_mode_text = option_mode.get_item_text(option_mode.selected)
	
	GameSettings.set_music(music_val)
	GameSettings.sfx_enabled = sfx_val
	GameSettings.game_mode = game_mode_text
	
	print("Gespeichert: SFX: ", sfx_val, " | Musik: ", music_val, " | Mode: ", game_mode_text)
	
	_change_to_main_menu()

func _change_to_main_menu() -> void:
	if ResourceLoader.exists(MAIN_MENU_PATH):
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
	else:
		print("KRITISCHER FEHLER: Hauptmenü-Szene nicht gefunden unter: ", MAIN_MENU_PATH)
