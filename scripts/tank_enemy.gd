extends CharacterBody2D

const SPEED = 60.0 # Kecepatan Tank
var health = 5 # Darah Tank
var player_target = null

# Pastikan folder dan nama file sesuai dengan huruf besar/kecil di komputermu
var powerup_scene = preload("res://Scenes/power_up.tscn")
var explosion_scene = preload("res://Scenes/alien_explosion.tscn")

var is_dead = false
var can_attack = true # Variabel baru untuk mencegah instan-kill (Cooldown)

@onready var anim_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_target = players[0]

func _physics_process(delta):
	if is_dead:
		return

	if player_target != null:
		var direction = global_position.direction_to(player_target.global_position)

		# Membalik sprite (Flip)
		if direction.x < 0:
			$Sprite2D.flip_h = true
		else:
			$Sprite2D.flip_h = false

		velocity = direction * SPEED
		
		# Menggunakan move_and_slide agar karakter bisa meluncur di pinggir tembok (Auto Avoidance)
		move_and_slide()

		# Logika mengecek tabrakan dengan pemain setelah move_and_slide
		var is_colliding_with_player = false
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider.is_in_group("player"):
				is_colliding_with_player = true
				
				# Mainkan animasi attack jika belum dimainkan
				if anim_player.current_animation != "attack":
					anim_player.play("attack")
				
				# Beri damage HANYA JIKA cooldown sudah selesai
				if can_attack and collider.has_method("take_damage"):
					collider.take_damage(5)
					cooldown_attack() # Panggil fungsi cooldown

		# Jika tidak sedang menabrak pemain dan animasi attack sudah selesai, kembali berjalan
		if not is_colliding_with_player and anim_player.current_animation != "attack":
			anim_player.play("walk")

# Fungsi untuk memberi jeda serangan (1 detik)
func cooldown_attack():
	can_attack = false
	await get_tree().create_timer(1.0).timeout
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
		level.add_score(50)
		
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	# Perbesar ledakan karena ini Tank
	explosion.scale = Vector2(2, 2) 
	get_tree().root.add_child(explosion)
	
	anim_player.play("death")
	await anim_player.animation_finished
	
	# Peluang 20% (0.2) menjatuhkan item
	if randf() < 0.05:
		spawn_powerup()
		
	queue_free()

func spawn_powerup():
	var p = powerup_scene.instantiate()
	p.global_position = global_position
	p.current_type = randi() % 2 
	# Gunakan call_deferred agar aman menambahkan node saat physics berjalan
	get_tree().root.call_deferred("add_child", p)
