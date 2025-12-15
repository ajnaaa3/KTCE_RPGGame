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

@onready var current_hpbar : ProgressBar = $%PlayerHPBar
@onready var attack_panel: HBoxContainer = $PlayerPanel/Attacks
@onready var player_anim: AnimationPlayer = $PlayerContainer/CharacterAnimationPlayer
@onready var enemy_anim: AnimationPlayer = $EnemyContainer/CharacterAnimationPlayer
@onready var music_player : AudioStreamPlayer = $BGMPlayer
@onready var soundfx_player : AudioStreamPlayer = $SoundFXPlayer
@onready var player : Character = selectedPlayer.duplicate_deep(Resource.DEEP_DUPLICATE_NONE)
@onready var enemy : Character = selectedEnemy.duplicate_deep(Resource.DEEP_DUPLICATE_NONE)

func _ready() -> void:
	player.set_current_hp(player.max_hp)
	enemy.set_current_hp(enemy.max_hp)
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
	if(current_state == BattleState.PLAYER_TURN 
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
			if (player.speed > enemy.speed):
				display_text($Textbox, "%s uses %s" % [player.name, player_attack.name])
				await get_tree().create_timer(1.0).timeout
				await player_attack.execute(player, enemy, enemy_anim, soundfx_player, $Textbox, %EnemyHPBar)
				await get_tree().create_timer(1.3).timeout
				if battle_end() :
					return
				current_hpbar = %PlayerHPBar
				display_text($Textbox, "%s uses %s" % [enemy.name, enemy_attack.name])
				await get_tree().create_timer(1.0).timeout
				await enemy_attack.execute(enemy, player, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				
			elif (player.speed < enemy.speed):
				display_text($Textbox, "%s uses %s" % [enemy.name, enemy_attack.name])
				await get_tree().create_timer(1.0).timeout
				await enemy_attack.execute(enemy, player, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				if battle_end() :
					return
				display_text($Textbox, "%s uses %s" % [player.name, player_attack.name])
				await get_tree().create_timer(1.0).timeout
				await player_attack.execute(player, enemy, enemy_anim, soundfx_player, $Textbox, %EnemyHPBar)
				await get_tree().create_timer(1.3).timeout
				
			elif (rng.randi_range(0, 100) < 50):
				display_text($Textbox, "%s uses %s" % [player.name, player_attack.name])
				await get_tree().create_timer(1.0).timeout
				await player_attack.execute(player, enemy, enemy_anim, soundfx_player, $Textbox, %EnemyHPBar)
				await get_tree().create_timer(1.3).timeout
				if battle_end() :
					return
				display_text($Textbox, "%s uses %s" % [enemy.name, enemy_attack.name])
				await get_tree().create_timer(1.0).timeout
				await enemy_attack.execute(enemy, player, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				
			else:
				display_text($Textbox, "%s uses %s" % [enemy.name, enemy_attack.name])
				await get_tree().create_timer(1.0).timeout
				await enemy_attack.execute(enemy, player, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				if battle_end() :
					return
				display_text($Textbox, "%s uses %s" % [player.name, player_attack.name])
				await get_tree().create_timer(1.0).timeout
				await player_attack.execute(player, enemy, enemy_anim, soundfx_player, $Textbox, %EnemyHPBar)
				await get_tree().create_timer(1.3).timeout
				
			await get_tree().create_timer(1.0).timeout
			if battle_end() :
					return
			$Textbox.hide()
			transition_to(BattleState.PLAYER_TURN)
			
		BattleState.PLAYER_WIN:
			enemy_anim.play("defeat")
			music_player.stop()
			music_player.stream = load(victory_music)
			music_player.play()
			display_text($Textbox, "You won!")
			await(textbox_closed)
			get_tree().set_meta("battle_result", "win")
			call_deferred("deferred_goto_results")
			
		BattleState.PLAYER_LOSE:
			player_anim.play("defeat")
			music_player.stop()
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
