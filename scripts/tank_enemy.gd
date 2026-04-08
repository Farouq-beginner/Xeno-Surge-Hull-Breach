extends CharacterBody2D

const SPEED = 60.0 # JAUH LEBIH LAMBAT
var health = 5 # BUTUH 5 TEMBAKAN UNTUK MATI

var player_target = null
var powerup_scene = preload("res://Scenes/power_up.tscn")
var explosion_scene = preload("res://Scenes/alien_explosion.tscn")

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_target = players[0]

func _physics_process(delta):
	if player_target != null:
		var direction = global_position.direction_to(player_target.global_position)
		velocity = direction * SPEED
		look_at(player_target.global_position)
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				# Damage yang diberikan ke pemain bisa dibuat lebih besar, misal 2 atau 3
				collider.take_damage(2) 

func take_damage(amount):
	health -= amount
	# Efek Visual Kecil: Membuat tank berkedip putih saat ditembak (Opsional tapi keren)
	modulate = Color(10, 10, 10) 
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1) # Kembali ke warna asli
	
	if health <= 0:
		die()

func die():
	var level = get_tree().current_scene
	if level.has_method("add_score"):
		level.add_score(50) # Skor lebih besar karena lebih susah dibunuh!
		
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	# Membuat ledakannya lebih besar
	explosion.scale = Vector2(2, 2) 
	get_tree().root.add_child(explosion)
	
	# Peluang 20% menjatuhkan item
	if randf() < 0.02:
		spawn_powerup()
		
	queue_free()

func spawn_powerup():
	var p = powerup_scene.instantiate()
	p.global_position = global_position
	# Pilih tipe secara acak (0 = Health, 1 = Spread Shot)
	p.current_type = randi() % 2 
	get_tree().root.add_child(p)
