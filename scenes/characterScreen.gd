extends Node2D 

# HINWEIS: Dies ist die finale, robuste Version, optimiert für Godot 4.
# BackButton-Suche und Player-Input sind auf Fehlerprüfung umgestellt.

# ===== Referenzen (Finale Version) =====

@onready var music_player: AudioStreamPlayer2D = %BGMMusic 
@onready var start_button: Button = %StartGameButton

# Player-Elemente als Control deklariert (nach der Typänderung im Editor)
@onready var player1_panel: Control = %Player1 
@onready var player2_panel: Control = %Player2
@onready var player3_panel: Control = %Player3
@onready var player4_panel: Control = %Player4

# Array der klickbaren Felder (Control)
@onready var char_panels: Array[Control] = [
	player1_panel, 
	player2_panel, 
	player3_panel, 
	player4_panel 
]

# Back Button wird in _ready gesucht, um Fehler zu vermeiden.
var back_button: Button = null

var selected_char_index: int = -1 


func _ready() -> void:
	
	# === KRITISCHER SCHRITT: BackButton-Suche erzwingen ===
	
	# WICHTIG: Ersetzen Sie HIER "TopLeftContainer/BackButton" durch den 
	# TATSÄCHLICHEN, VOLLSTÄNDIGEN Pfad in Ihrem Szenenbaum! 
	# (z.B. "LayoutBasis/MarginContainer_TopLeft/BackButton")
	var back_button_path = "TopLeftContainer/BackButton" 
	
	# Versuch, den Node zu finden. get_node_or_null verhindert, dass das Skript abstürzt.
	back_button = get_node_or_null(back_button_path) 

	if is_instance_valid(back_button):
		print("DEBUG: BackButton Node erfolgreich gefunden an: " + back_button_path)
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		# Dieser Fehler zeigt, dass der Pfad in der Zeile 27 falsch ist!
		print("KRITISCHER FEHLER: BackButton konnte NICHT gefunden werden. Prüfe Pfad: " + back_button_path)

	# === ENDE KRITISCHER SCHRITT ===
	
	music_player.play()
		
	# Start-Button verbinden
	start_button.disabled = true
	start_button.pressed.connect(_on_start_game_pressed)
	
	# Player-Felder (Control) für manuelle Klick-Erkennung vorbereiten
	for i in range(char_panels.size()):
		var panel = char_panels[i]
		
		# WICHTIG: Verbindet den Input des Panels mit unserer Logik
		panel.gui_input.connect(func(event): _handle_player_input(event, i))
		
		_set_button_style(panel, false)


# NEUE FUNKTION: Manuelle Klick-Erkennung für Player-Felder (Control-Typen)
func _handle_player_input(event: InputEvent, index: int) -> void:
	# --- DEBUG-AUSGABE: WIRD ANGEZEIGT, WENN DER KLICK DEN CONTROL-NODE ERREICHT ---
	# Wenn Sie das sehen, funktioniert der Klick.
	# print("DEBUG: Input-Event erreicht Player ", index + 1)
	# --------------------------------------------------------------------------------
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		print("DEBUG: Klick registriert für Player ", index + 1)
		_select_character(index)

# ... (Alle anderen Funktionen bleiben gleich) ...

# ===== Logik für Auswahl und Hervorhebung bleibt gleich =====

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
	if selected_char_index != -1:
		print("Character selected: Player " + str(selected_char_index + 1))


# ===== Szenenwechsel-Callbacks =====

func _on_start_game_pressed() -> void:
	if selected_char_index != -1:
		print("Starting battle with Player " + str(selected_char_index + 1))
		music_player.stop() 
		var battle_scene_path = "res://scenes/battle.tscn"
		
		if ResourceLoader.exists(battle_scene_path):
			get_tree().change_scene_to_file(battle_scene_path)
		else:
			print("FEHLER: battle.tscn wurde unter dem angegebenen Pfad nicht gefunden.")
		
# WICHTIG: Dies ist die Funktion, die der BackButton auslösen soll.
func _on_back_button_pressed() -> void:
	# --- DEBUG-AUSGABE: WIRD NUR BEIM KLICK AUSGEGEBEN ---
	print("DEBUG: BackButton KLICK ERFOLGREICH! Wechsel zum Menü...")
	# --------------------------------------------------------

	music_player.stop() 
		
	var menu_scene_path = "res://scenes/menu.tscn"
	
	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
	else:
		print("FEHLER: menu.tscn wurde unter dem angegebenen Pfad nicht gefunden.")

# ZUSÄTZLICHE FIXES: Verhindert, dass der Node2D Root Input abfängt.
func _input(event):
	pass
