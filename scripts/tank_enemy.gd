extends CharacterBody2D

# --- Sesuaikan variabel ini untuk masing-masing musuh ---
const SPEED = 60.0 # Gunakan 60.0 untuk Tank
var health = 5 # Gunakan 5 untuk Tank
var player_target = null
var powerup_scene = preload("res://scenes/power_up.tscn")
var explosion_scene = preload("res://scenes/alien_explosion.tscn")

# Variabel baru untuk animasi
var is_dead = false
@onready var anim_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D

# --- Variabel untuk Obstacle Avoidance ---
var raycast_distance: float = 80.0
var avoidance_strength: float = 0.7
var max_avoidance_duration: float = 1.5
var avoidance_timer: float = 0.0
var current_avoidance_direction: Vector2 = Vector2.ZERO

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_target = players[0]

func _physics_process(delta):
	if is_dead:
		return

	if player_target != null:
		var direction = global_position.direction_to(player_target.global_position)

		if direction.x < 0:
			$Sprite2D.flip_h = true
		else:
			$Sprite2D.flip_h = false

		velocity = direction * SPEED
		var collision = move_and_collide(velocity * delta)

		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				if anim_player.current_animation != "attack":
					anim_player.play("attack")
				if collider.has_method("take_damage"):
					collider.take_damage(2)
		else:
			# hanya mainkan walk kalau tidak sedang attack
			if anim_player.current_animation != "attack":
				anim_player.play("walk")

func take_damage(amount):
	if is_dead: return # Cegah damage tambahan jika sudah mati
	
	health -= amount
	modulate = Color(10, 10, 10) 
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
	
	if health <= 0:
		die()

func die():
	is_dead = true # Tandai sebagai mati
	collision_shape.set_deferred("disabled", true) # Matikan hitbox agar tidak melukai pemain lagi
	
	var level = get_tree().current_scene
	if level.has_method("add_score"):
		level.add_score(50) # 50 untuk Tank
		
	# Tetap munculkan partikel ledakan hijau (Opsional, hapus jika dirasa terlalu ramai)
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
	
	# Mainkan animasi mati dari Sprite Sheet
	anim_player.play("death")
	
	# Tunggu sampai animasi mati selesai secara penuh, BARU hapus alien
	await anim_player.animation_finished
			# Peluang 20% menjatuhkan item
	if randf() < 0.05:
		spawn_powerup()
	queue_free()

func spawn_powerup():
	var p = powerup_scene.instantiate()
	p.global_position = global_position
	# Pilih tipe secara acak (0 = Health, 1 = Spread Shot)
	p.current_type = randi() % 2 
	get_tree().root.add_child(p)
