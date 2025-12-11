extends Control

@onready var title_lbl: Label = %Title
@onready var btn_restart: Button = %Restart
@onready var btn_change: Button = %ChangeCharacter
@onready var btn_quit: Button = %Quit
@onready var vbox: VBoxContainer = %VBoxContainer   # optional, falls du Abstand anpassen willst

# Pfade zu deinen Szenen
const BATTLE_SCENE_PATH := "res://scenes/battle.tscn"
const CHARACTER_SCREEN_PATH := "res://scenes/characterScreen.tscn"

func _ready() -> void:
	# Optional: Button-Abstand einstellen
	if vbox:
		vbox.add_theme_constant_override("separation", 20)

	# Ausgang (Gewonnen / Verloren) vom SceneTree lesen
	var outcome := "lost"
	if get_tree().has_meta("battle_result"):
		outcome = str(get_tree().get_meta("battle_result"))
		get_tree().set_meta("battle_result", null)  # Reset, damit’s nicht bleibt

	var won := (outcome == "win")
	title_lbl.text = "YOU WON!" if won else "YOU LOST!"
	title_lbl.modulate = Color(0.3, 1.0, 0.3) if won else Color(1.0, 0.3, 0.3)

	# Button-Signale verbinden
	btn_restart.pressed.connect(_on_restart)
	btn_change.pressed.connect(_on_change_character)
	btn_quit.pressed.connect(_on_quit)

	btn_restart.grab_focus()  # Fokus fürs Gamepad/Keyboard

func _unhandled_input(event: InputEvent) -> void:
	# Komfort: Enter = Restart, Esc = Quit
	if event.is_action_pressed("ui_accept"):
		_on_restart()
	elif event.is_action_pressed("ui_cancel"):
		_on_quit()

func _on_restart() -> void:
	get_tree().change_scene_to_file(BATTLE_SCENE_PATH)

func _on_change_character() -> void:
	get_tree().change_scene_to_file(CHARACTER_SCREEN_PATH)

func _on_quit() -> void:
	get_tree().quit()
