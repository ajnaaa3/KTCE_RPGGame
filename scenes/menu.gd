extends Node2D

# HINWEIS: Reine Godot 4-Syntax unter Verwendung der Unique Names (%).
# Die Engine findet diese Nodes automatisch, da sie das %-Zeichen haben.

# ===== Referenzen (Godot 4 Unique Name %) =====
@onready var start_button: Button = %StartButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var music_player: AudioStreamPlayer2D = %MenuMusic 


func _ready() -> void:
	
	music_player.play()
	
	# Verbindungen herstellen (Godot 4-Syntax: object.signal.connect(method))
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


# ====================
# Button-Callbacks
# ====================

func _on_start_button_pressed():
	print("Wechsle zur Charakterauswahl...")
	
	music_player.stop() 
	
	var target_scene_path = "res://scenes/characterScreen.tscn" 
	
	if ResourceLoader.exists(target_scene_path):
		get_tree().change_scene_to_file(target_scene_path)
	else:
		print("FEHLER: Zielszenen-Pfad nicht gefunden: " + target_scene_path)


func _on_options_button_pressed():
	print("Optionen werden geladen...")
	
func _on_quit_button_pressed():
	print("Spiel wird beendet.")
	get_tree().quit()
