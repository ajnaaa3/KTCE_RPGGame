extends Node2D

signal textbox_closed

@export var player : Character
@export var enemy : Character

var rng = RandomNumberGenerator.new()
var player_attack: Attack
var enemy_attack: Attack
enum BattleState { PLAYER_TURN, ENEMY_TURN, RESOLVE_ATTACKS, PLAYER_WIN, ENEMY_WIN }
var current_state: BattleState = BattleState.PLAYER_TURN

@onready var attack_panel = $PlayerPanel/Attacks

func _ready() -> void:
	set_health($PlayerContainer/PlayerHPBar, player.max_hp, player.max_hp)
	set_health($EnemyContainer/EnemyHPBar, enemy.max_hp, enemy.max_hp)
	$PlayerContainer/Sprite.texture = player.texture
	$EnemyContainer/Sprite.texture = enemy.texture
	$EnemyContainer/EnemyName.text = enemy.name
	$PlayerContainer/PlayerName.text = player.name
	attack_panel.populate_moves(player)
	attack_panel.attack_selected.connect(_on_player_attack_selected)
	
	$Textbox.hide()
	$PlayerPanel.hide()
	display_text($Textbox, "A wild %s appears" % enemy.name)
	await(textbox_closed)
	transition_to(current_state)

func display_text(panel_node, text):
	panel_node.show()
	panel_node.get_node("Label").text = text

func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and current_state == BattleState.PLAYER_TURN):
		$Textbox.hide()
		emit_signal("textbox_closed")
		

func set_health(hpbar_node, current_health, max_health):
	hpbar_node.value = current_health
	hpbar_node.max_value = max_health
	
func _on_player_attack_selected(attack: Attack) -> void:
	player_attack = attack
	$PlayerPanel.hide()
	transition_to(BattleState.ENEMY_TURN)
	
func transition_to(new_state: BattleState) -> void:
	current_state = new_state
	match current_state:
		BattleState.PLAYER_TURN:
			$PlayerPanel.show()
			
		BattleState.ENEMY_TURN:
			display_text($Textbox, "Waiting for %s's move" % enemy.name)
			await get_tree().create_timer(0.5).timeout
			enemy_attack = enemy.moveset[rng.randi_range(0, enemy.moveset.size() - 1)]
			transition_to(BattleState.RESOLVE_ATTACKS)
			
		BattleState.RESOLVE_ATTACKS:
			if (player.speed > enemy.speed): 
				await resolve_damage(player_attack, player, enemy, $EnemyContainer/EnemyHPBar)
				await check_battle_end()
				await resolve_damage(enemy_attack, enemy, player, $PlayerContainer/PlayerHPBar)
				
			elif (player.speed < enemy.speed):
				await resolve_damage(enemy_attack, enemy, player, $PlayerContainer/PlayerHPBar)
				await check_battle_end()
				await resolve_damage(player_attack, player, enemy, $EnemyContainer/EnemyHPBar)
				
			elif (rng.randi_range(0, 100) < 50):
				await resolve_damage(player_attack, player, enemy, $EnemyContainer/EnemyHPBar)
				await check_battle_end()
				await resolve_damage(enemy_attack, enemy, player, $PlayerContainer/PlayerHPBar)
				
			else:
				await resolve_damage(enemy_attack, enemy, player, $PlayerContainer/PlayerHPBar)
				await check_battle_end()
				await resolve_damage(player_attack, player, enemy, $EnemyContainer/EnemyHPBar)
				
			await get_tree().create_timer(1.0).timeout
			check_battle_end()
			$Textbox.hide()
			transition_to(BattleState.PLAYER_TURN)
			
func resolve_damage(attack, attacker, defender, defender_health):
	display_text($Textbox, "%s uses %s" % [attacker.name, attack.name])
	await get_tree().create_timer(1.0).timeout
	if randf() < attack.accuracy:
		var damage = max(0, (attack.power + attacker.attack) - defender.defense)
		set_health(defender_health, max(0, defender_health.value - damage), defender.max_hp)
		display_text($Textbox, "%s takes %d damage!" % [defender.name, damage])
	else:
		display_text($Textbox, "%s missed!" % attacker.name)
	await get_tree().create_timer(1.0).timeout
	
func check_battle_end():
	if $PlayerContainer/PlayerHPBar.value == 0:
		get_tree().set_meta("battle_result", "lost")
		call_deferred("deferred_goto_results")
		return
	elif $EnemyContainer/EnemyHPBar.value <= 0:
		get_tree().set_meta("battle_result", "win")
		call_deferred("deferred_goto_results")
		return
	else:
		return
		
func deferred_goto_results():
	get_tree().change_scene_to_file("res://scenes/result.tscn")
