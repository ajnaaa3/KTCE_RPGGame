extends Node2D
class_name Battle

signal textbox_closed

@export var selectedPlayer : Character
@export var selectedEnemy : Character

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player_attack: Attack
var enemy_attack: Attack

enum BattleState { PLAYER_TURN, ENEMY_TURN, RESOLVE_ATTACKS, PLAYER_WIN, PLAYER_LOSE}
var current_state: BattleState = BattleState.PLAYER_TURN

var victory_music: String = "res://assets/sounds/victory.ogg"
var defeat_music: String = "res://assets/sounds/defeat.ogg"

var player_confused_next: bool = false
var enemy_confused_next: bool = false

var player_burned: bool = false
var enemy_burned: bool = false

var player_bleeding: bool = false
var enemy_bleeding: bool = false

var player_slash_streak: int = 0
var enemy_slash_streak: int = 0

@onready var current_hpbar : ProgressBar = %PlayerHPBar
@onready var attack_panel: HBoxContainer = $PlayerPanel/Attacks
@onready var player_anim: AnimationPlayer = $PlayerContainer/CharacterAnimationPlayer
@onready var enemy_anim: AnimationPlayer = $EnemyContainer/CharacterAnimationPlayer
@onready var music_player : AudioStreamPlayer = $BGMPlayer
@onready var soundfx_player : AudioStreamPlayer = $SoundFXPlayer

@onready var player : Character = selectedPlayer.duplicate_deep(Resource.DEEP_DUPLICATE_NONE)
@onready var enemy : Character = selectedEnemy.duplicate_deep(Resource.DEEP_DUPLICATE_NONE)

@onready var player_sprite: CanvasItem = $PlayerContainer/Sprite
@onready var enemy_sprite: CanvasItem = $EnemyContainer/Sprite


func _ready() -> void:
	randomize()
	
	if GameSettings.music_enabled:
		music_player.play()
	else:
		music_player.stop()

	if not GameSettings.sfx_enabled:
		soundfx_player.volume_db = -80 
	else:
		soundfx_player.volume_db = 0 

	player.set_current_hp(player.max_hp)
	enemy.set_current_hp(enemy.max_hp)
	player.set_current_attack(player.attack)
	enemy.set_current_attack(enemy.attack)
	player.set_current_defense(player.defense)
	enemy.set_current_defense(enemy.defense)
	player.set_current_speed(player.speed)
	enemy.set_current_speed(enemy.speed)

	set_health($PlayerContainer/PlayerHPBar, player.current_hp, player.max_hp)
	set_health($EnemyContainer/EnemyHPBar, enemy.current_hp, enemy.max_hp)

	$PlayerContainer/Sprite.texture = player.texture
	$EnemyContainer/Sprite.texture = enemy.texture
	$EnemyContainer/Name.text = enemy.name
	$PlayerContainer/Name.text = player.name

	attack_panel.populate_moves(player)
	attack_panel.attack_selected.connect(_on_player_attack_selected)

	$Textbox.hide()
	$PlayerPanel.hide()
	display_text($Textbox, "A wild %s appears" % enemy.name)
	await(textbox_closed)
	transition_to(current_state)


func display_text(panel_node : Panel, text : String):
	panel_node.show()
	panel_node.get_node("Label").text = text


func _input(event: InputEvent) -> void:
	if (current_state == BattleState.PLAYER_TURN
		or current_state == BattleState.PLAYER_WIN
		or current_state == BattleState.PLAYER_LOSE) \
		and (Input.is_action_just_pressed("ui_accept")
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		$Textbox.hide()
		emit_signal("textbox_closed")


func set_health(hpbar_node, current_health, max_health):
	hpbar_node.value = current_health
	hpbar_node.max_value = max_health


func _on_player_attack_selected(attack: Attack) -> void:
	player_attack = attack
	$PlayerPanel.hide()
	transition_to(BattleState.ENEMY_TURN)

func _apply_end_of_round_status_damage() -> void:
	var did_any := false

	if player_burned and player.current_hp > 0 and randf() < 0.2:
		player.set_current_hp(player.current_hp - 10)
		set_health($PlayerContainer/PlayerHPBar, player.current_hp, player.max_hp)
		await show_status_applied(player, "Burned (-10 HP)", false)
		did_any = true

	if enemy_burned and enemy.current_hp > 0 and randf() < 0.2:
		enemy.set_current_hp(enemy.current_hp - 10)
		set_health($EnemyContainer/EnemyHPBar, enemy.current_hp, enemy.max_hp)
		await show_status_applied(enemy, "Burned (-10 HP)", true)
		did_any = true

	if player_bleeding and player.current_hp > 0:
		player.set_current_hp(player.current_hp - 7)
		set_health($PlayerContainer/PlayerHPBar, player.current_hp, player.max_hp)
		await show_status_applied(player, "Bleeding (-7 HP)", false)
		did_any = true

	if enemy_bleeding and enemy.current_hp > 0:
		enemy.set_current_hp(enemy.current_hp - 7)
		set_health($EnemyContainer/EnemyHPBar, enemy.current_hp, enemy.max_hp)
		await show_status_applied(enemy, "Bleeding (-7 HP)", true)
		did_any = true

	if did_any:
		await get_tree().create_timer(0.2).timeout


func _should_miss_due_to_confused(is_attacker_enemy: bool) -> bool:
	if is_attacker_enemy:
		if enemy_confused_next:
			enemy_confused_next = false
			return randf() < 0.4
	else:
		if player_confused_next:
			player_confused_next = false
			return randf() < 0.4
	return false


func _after_attack_apply_statuses(attack_used: Attack, attacker_is_enemy: bool) -> void:
	var target: Character = player if attacker_is_enemy else enemy
	var target_is_enemy: bool = (not attacker_is_enemy)

	if attack_used != null and attack_used.name == "Set Alight":
		if target_is_enemy:
			enemy_burned = true
		else:
			player_burned = true
		await show_status_applied(target, "Burned", target_is_enemy)

	if attack_used != null and attack_used.name == "Tackle":
		if randf() < 0.4:
			if target_is_enemy:
				enemy_confused_next = true
			else:
				player_confused_next = true
			await show_status_applied(target, "Confused", target_is_enemy)

	if attack_used != null and attack_used.name == "Slash":
		if attacker_is_enemy:
			enemy_slash_streak += 1
			if enemy_slash_streak >= 2:
				player_bleeding = true
				await show_status_applied(player, "Bleeding", false)
		else:
			player_slash_streak += 1
			if player_slash_streak >= 2:
				enemy_bleeding = true
				await show_status_applied(enemy, "Bleeding", true)
	else:
		if attacker_is_enemy:
			enemy_slash_streak = 0
		else:
			player_slash_streak = 0

func transition_to(new_state: BattleState) -> void:
	current_state = new_state
	match current_state:
		BattleState.PLAYER_TURN:
			$PlayerPanel.show()

		BattleState.ENEMY_TURN:
			display_text($Textbox, "Waiting for %s's move" % enemy.name)
			await get_tree().create_timer(1.0).timeout
			enemy_attack = enemy.moveset[rng.randi_range(0, enemy.moveset.size() - 1)]
			transition_to(BattleState.RESOLVE_ATTACKS)

		BattleState.RESOLVE_ATTACKS:
			var do_attack = func(attacker: Character, target: Character, attacker_anim: AnimationPlayer, target_anim: AnimationPlayer, hpbar: ProgressBar, attack_used: Attack, attacker_is_enemy: bool) -> bool:
				if _should_miss_due_to_confused(attacker_is_enemy):
					display_text($Textbox, "%s is confused... MISS!" % attacker.name)
					await get_tree().create_timer(0.9).timeout
					$Textbox.hide()
					return false

				display_text($Textbox, "%s uses %s" % [attacker.name, attack_used.name])
				await get_tree().create_timer(1.0).timeout
				await attack_used.execute(attacker, target, attacker_anim, target_anim, soundfx_player, $Textbox, hpbar)
				await get_tree().create_timer(1.0).timeout

				await _after_attack_apply_statuses(attack_used, attacker_is_enemy)
				return true


			if (player.current_speed > enemy.current_speed):
				await do_attack.call(player, enemy, player_anim, enemy_anim, %EnemyHPBar, player_attack, false)
				await get_tree().create_timer(0.3).timeout
				if battle_end(): return

				await do_attack.call(enemy, player, enemy_anim, player_anim, %PlayerHPBar, enemy_attack, true)
				await get_tree().create_timer(0.3).timeout

			elif (player.current_speed < enemy.current_speed):
				await do_attack.call(enemy, player, enemy_anim, player_anim, %PlayerHPBar, enemy_attack, true)
				await get_tree().create_timer(0.3).timeout
				if battle_end(): return

				await do_attack.call(player, enemy, player_anim, enemy_anim, %EnemyHPBar, player_attack, false)
				await get_tree().create_timer(0.3).timeout

			elif (rng.randi_range(0, 100) < 50):
				await do_attack.call(player, enemy, player_anim, enemy_anim, %EnemyHPBar, player_attack, false)
				await get_tree().create_timer(0.3).timeout
				if battle_end(): return

				await do_attack.call(enemy, player, enemy_anim, player_anim, %PlayerHPBar, enemy_attack, true)
				await get_tree().create_timer(0.3).timeout

			else:
				await do_attack.call(enemy, player, enemy_anim, player_anim, %PlayerHPBar, enemy_attack, true)
				await get_tree().create_timer(0.3).timeout
				if battle_end(): return

				await do_attack.call(player, enemy, player_anim, enemy_anim, %EnemyHPBar, player_attack, false)
				await get_tree().create_timer(0.3).timeout

			await _apply_end_of_round_status_damage()
			if battle_end(): return

			$Textbox.hide()
			transition_to(BattleState.PLAYER_TURN)

		BattleState.PLAYER_WIN:
			enemy_anim.play("defeat")
			soundfx_player.stream = load("res://assets/sounds/Soundfx/downed.wav")
			soundfx_player.play()
			await get_tree().create_timer(0.7).timeout
			music_player.stop()
			
			if GameSettings.music_enabled:
				music_player.stream = load(victory_music)
				music_player.play()
				
			display_text($Textbox, "You won!")
			await(textbox_closed)
			get_tree().set_meta("battle_result", "win")
			call_deferred("deferred_goto_results")

		BattleState.PLAYER_LOSE:
			player_anim.play("defeat")
			soundfx_player.stream = load("res://assets/sounds/Soundfx/downed.wav")
			soundfx_player.play()
			await get_tree().create_timer(0.7).timeout
			music_player.stop()
			
			if GameSettings.music_enabled:
				music_player.stream = load(defeat_music)
				music_player.play()
				
			display_text($Textbox, "You lost...")
			await(textbox_closed)
			get_tree().set_meta("battle_result", "lost")
			call_deferred("deferred_goto_results")


func battle_end() -> bool:
	if player.current_hp <= 0:
		transition_to(BattleState.PLAYER_LOSE)
		return true
	elif enemy.current_hp <= 0:
		transition_to(BattleState.PLAYER_WIN)
		return true
	else:
		return false


func deferred_goto_results():
	get_tree().change_scene_to_file("res://scenes/result.tscn")

func show_status_applied(target: Character, status_text: String, is_enemy: bool) -> void:
	display_text($Textbox, "%s is %s!" % [target.name, status_text])

	if is_enemy:
		blink_icon(enemy_sprite)
	else:
		blink_icon(player_sprite)

	await get_tree().create_timer(0.6).timeout
	$Textbox.hide()


func blink_icon(icon: CanvasItem) -> void:
	if icon == null:
		return
	var orig: Color = icon.modulate
	var t := create_tween()
	t.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.06)
	t.tween_property(icon, "modulate", orig, 0.10)
	t.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.06)
	t.tween_property(icon, "modulate", orig, 0.10)
