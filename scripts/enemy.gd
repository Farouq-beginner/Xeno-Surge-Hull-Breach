extends CharacterBody2D

const SPEED = 150.0 # Gunakan 60.0 untuk Tank
var health = 1 # Gunakan 5 untuk Tank
var player_target = null
var powerup_scene = preload("res://scenes/power_up.tscn")
var explosion_scene = preload("res://scenes/alien_explosion.tscn")

# Variabel baru untuk animasi
var is_dead = false
@onready var anim_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D

# --- Tambahan untuk cooldown ---
var attack_cooldown = 1 # dalam detik
var can_attack = true

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_target = players[0]

func _physics_process(delta):
	if is_dead:
		return 

	if player_target != null:
		anim_player.play("fly") # Ganti menjadi "walk" di script tank_enemy.gd
		
		var direction = global_position.direction_to(player_target.global_position)
		velocity = direction * SPEED
		
		if direction.x < 0:
			$Sprite2D.flip_h = true
		else:
			$Sprite2D.flip_h = false
			
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("player") and can_attack:
				collider.take_damage(2)
				start_attack_cooldown()

func start_attack_cooldown():
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount):
	if is_dead: return 
	
	health -= amount
	modulate = Color(10, 10, 10) 
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
	
	if health <= 0:
		die()

func die():
	is_dead = true
	collision_shape.set_deferred("disabled", true)
	
	var level = get_tree().current_scene
	if level.has_method("add_score"):
		level.add_score(10)
		
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
	
	anim_player.play("death")
	await anim_player.animation_finished
	
	if randf() < 0.02:
		spawn_powerup()
	queue_free()

func spawn_powerup():
	var p = powerup_scene.instantiate()
	p.global_position = global_position
	p.current_type = randi() % 2 
	get_tree().root.add_child(p)
