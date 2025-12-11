extends Node2D

# ===== References by Unique Names =====
@onready var player_hp_bar: ProgressBar = %PlayerHPBar
@onready var enemy_hp_bar:  ProgressBar = %EnemyHPBar

# Containers can be Node2D OR Control -> reference as CanvasItem
@onready var player_node: CanvasItem = %Player
@onready var enemy_node:  CanvasItem = %Enemy

# Visible children (Sprite2D OR ColorRect/Control)
@onready var player_vis: CanvasItem = %PlayerIcon
@onready var enemy_vis:  CanvasItem = %EnemyIcon

@onready var btn20: BaseButton = %AttackButton20
@onready var btn10: BaseButton = %AttackButton10

# Music (optional). Set the stream in the editor (node: %Music).
@onready var music: AudioStreamPlayer = %Music

# Optional damage popup (correctly via NodePath with %)
const DAMAGE_LABEL_PATH := NodePath("%DamageLabel")
@onready var dmg_label: Label = get_node_or_null(DAMAGE_LABEL_PATH)

# ===== State =====
var player_hp: int = 100
var enemy_hp:  int = 100

const RESULTS_SCENE := "res://scenes/results.tscn"

func _ready() -> void:
	# Connect buttons (if not connected in the editor)
	if btn20:
		btn20.pressed.connect(_on_attack_button_20_pressed)
	if btn10:
		btn10.pressed.connect(_on_attack_button_10_pressed)

	if player_hp_bar:
		player_hp_bar.min_value = 0
		player_hp_bar.max_value = 100
	if enemy_hp_bar:
		enemy_hp_bar.min_value = 0
		enemy_hp_bar.max_value = 100

	_refresh_bars()
	_set_buttons_enabled(true)

	# Start music if stream is set and not already playing
	if music and music.stream and not music.playing:
		music.volume_db = 0.0
		music.play()

# ===== HP / Utility =====
func _refresh_bars() -> void:
	if player_hp_bar:
		player_hp_bar.value = clamp(player_hp, 0, 100)
	if enemy_hp_bar:
		enemy_hp_bar.value = clamp(enemy_hp, 0, 100)

func _check_end() -> void:
	if enemy_hp <= 0:
		enemy_hp = 0
		_refresh_bars()
		_set_buttons_enabled(false)
		_goto_results(true)
	elif player_hp <= 0:
		player_hp = 0
		_refresh_bars()
		_set_buttons_enabled(false)
		_goto_results(false)

func _set_buttons_enabled(enabled: bool) -> void:
	if btn20: btn20.disabled = not enabled
	if btn10: btn10.disabled = not enabled

# ===== Navigation =====
func _goto_results(won: bool) -> void:
	get_tree().set_meta("battle_result", "win" if won else "lost")
	await _fade_out_music(0.35)
	get_tree().change_scene_to_file(RESULTS_SCENE)

func _fade_out_music(duration: float = 0.35) -> void:
	if music and music.playing:
		var t := create_tween()
		t.tween_property(music, "volume_db", -40.0, duration)
		await t.finished
		music.stop()

# ===== Button Callbacks =====
func _on_attack_button_20_pressed() -> void:
	if enemy_hp > 0 and player_hp > 0:
		enemy_hp -= 20
		player_hp -= 5
		_refresh_bars()
		_play_enemy_hit_fx(20)
		_check_end()

func _on_attack_button_10_pressed() -> void:
	if enemy_hp > 0 and player_hp > 0:
		enemy_hp -= 10
		_refresh_bars()
		_play_enemy_hit_fx(10)
		_check_end()

# ===== Hit FX (works for Node2D & Control) =====
func _play_enemy_hit_fx(dmg: int) -> void:
	if enemy_node == null:
		return

	var t := create_tween()

	# 1) Red flash on visible child (if any)
	if enemy_vis != null:
		var orig_mod := enemy_vis.modulate
		t.tween_property(enemy_vis, "modulate", Color(1, 0.4, 0.4, 1), 0.08)
		t.tween_property(enemy_vis, "modulate", orig_mod, 0.15)

	# 2) Punch scale (only if 'scale' exists)
	var can_scale: bool = enemy_node.has_method("set_scale") or enemy_node.has_property("scale")
	if can_scale:
		var orig_scale = enemy_node.get("scale")
		t.parallel().tween_property(enemy_node, "scale", orig_scale * 1.08, 0.07)
		t.tween_property(enemy_node, "scale", orig_scale, 0.12)

	# 3) Mini shake (only if 'position' exists)
	var can_move: bool = enemy_node.has_method("set_position") or enemy_node.has_property("position")
	if can_move:
		var orig_pos = enemy_node.get("position")
		t.parallel().tween_property(enemy_node, "position", orig_pos + Vector2(8, 0), 0.05)
		t.tween_property(enemy_node, "position", orig_pos - Vector2(6, 0), 0.05)
		t.tween_property(enemy_node, "position", orig_pos, 0.05)

	_show_enemy_damage_popup(dmg)

# ===== Damage popup =====
func _show_enemy_damage_popup(dmg: int) -> void:
	if dmg_label == null:
		return
	dmg_label.text = "-" + str(dmg)
	dmg_label.visible = true
	dmg_label.modulate = Color(1, 1, 1, 1)

	var start_pos := dmg_label.position
	dmg_label.position = start_pos

	var t := create_tween()
	t.tween_property(dmg_label, "position", start_pos + Vector2(0, -30), 0.4)
	t.parallel().tween_property(dmg_label, "modulate:a", 0.0, 0.4)
	t.finished.connect(func ():
		dmg_label.visible = false
		dmg_label.position = start_pos
		dmg_label.modulate = Color(1, 1, 1, 1)
	)
