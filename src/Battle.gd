extends Control

signal textbox_closed

export(Resource) var enemy = null

var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

func _ready():
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	$Textbox.hide()
	$ActionsPanel.hide()
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	$ActionsPanel.show()

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(BUTTON_LEFT)) and $Textbox.visible:
		$Textbox.hide()
		emit_signal("textbox_closed")

func display_text(text):
	$ActionsPanel.hide()
	$Textbox.show()
	$Textbox/Label.text = text

func enemy_turn():
	display_text("%s launches at you fiercely!" % enemy.name)
	yield(self, "textbox_closed")
	
	if is_defending:
		is_defending = false
		$AnimationPlayer.play("mini_shake")
		yield($AnimationPlayer, "animation_finished")
		display_text("You defended successfully!")
		yield(self, "textbox_closed")
	else:
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		$AnimationPlayer.play("shake")
		yield($AnimationPlayer, "animation_finished")
		display_text("%s dealt %d damage!" % [enemy.name, enemy.damage])
		yield(self, "textbox_closed")
	$ActionsPanel.show()

func _on_Run_pressed():
	display_text("Got away safely!")
	yield(self, "textbox_closed")
	yield(get_tree().create_timer(0.25), "timeout")
	get_tree().quit()

func _on_Attack_pressed():
	display_text("You swing your piercing sword!")
	yield(self, "textbox_closed")
	
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)

	$AnimationPlayer.play("enemy_damaged")
	yield($AnimationPlayer, "animation_finished")
	
	display_text("You dealt %d damage!" % State.damage)
	yield(self, "textbox_closed")
	
	if current_enemy_health == 0:
		display_text("%s was defeated!" % enemy.name)
		yield(self, "textbox_closed")
		
		$AnimationPlayer.play("enemy_died")
		yield($AnimationPlayer, "animation_finished")
		
		yield(get_tree().create_timer(0.25), "timeout")
		get_tree().quit()

	enemy_turn()

func _on_Defend_pressed():
	is_defending = true
	
	display_text("You prepare defensively!")
	yield(self, "textbox_closed")
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	enemy_turn()
