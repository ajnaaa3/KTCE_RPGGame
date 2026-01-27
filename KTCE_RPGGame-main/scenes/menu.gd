extends Node2D

# ===== Referenzen =====
@onready var start_button: Button = %StartButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var music_player: AudioStreamPlayer2D = %MenuMusic 

# Pfade zu den Szenen
const CHARACTER_SCREEN_PATH := "res://scenes/characterScreen.tscn"
const OPTIONS_SCENE_PATH := "res://scenes/options.tscn"

func _ready() -> void:
	# PRÜFUNG: Nur abspielen, wenn Musik in den GameSettings erlaubt ist
	if GameSettings.music_enabled:
		music_player.play()
	else:
		music_player.stop() # Sicherstellen, dass sie aus bleibt
	
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

# ====================
# Button-Callbacks
# ====================

func _on_start_button_pressed():
	print("Wechsle zur Charakterauswahl...")
	music_player.stop() 
	
	if ResourceLoader.exists(CHARACTER_SCREEN_PATH):
		get_tree().change_scene_to_file(CHARACTER_SCREEN_PATH)
	else:
		print("FEHLER: Zielszenen-Pfad nicht gefunden: " + CHARACTER_SCREEN_PATH)

func _on_options_button_pressed():
	print("Optionen werden geladen...")
	if ResourceLoader.exists(OPTIONS_SCENE_PATH):
		get_tree().change_scene_to_file(OPTIONS_SCENE_PATH)
	else:
		print("FEHLER: Options-Szenen-Pfad nicht gefunden: " + OPTIONS_SCENE_PATH)
	
func _on_quit_button_pressed():
	print("Spiel wird beendet.")
	get_tree().quit()
