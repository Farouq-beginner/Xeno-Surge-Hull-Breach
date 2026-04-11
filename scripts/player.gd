extends CharacterBody2D

const SPEED = 300.0
var health = 100

# Memuat scene peluru agar siap dipakai
var bullet_scene = preload("res://scenes/bullet.tscn")

# Mengambil referensi node yang dibutuhkan
@onready var body_sprite = $BodySprite
@onready var weapon_pivot = $WeaponPivot
@onready var weapon_sprite = $WeaponPivot/WeaponSprite
@onready var shoot_point = $WeaponPivot/ShootPoint
@onready var camera = $Camera2D
@onready var anim_player = $AnimationPlayer

var is_spread_shot = false
@onready var powerup_timer = $PowerUpTimer

func _physics_process(delta):
	# 1. Pergerakan Karakter (Tetap sama)
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED
	move_and_slide()
	
	# LOGIKA ANIMASI
	if input_dir != Vector2.ZERO:
		anim_player.play("walk")
	else:
		anim_player.play("idle")
	
# 2. Rotasi Senjata
	var mouse_pos = get_global_mouse_position()
	weapon_pivot.look_at(mouse_pos)
	
	# 3. Logika Membalik (Flipping) Karakter dan Senjata
	if mouse_pos.x < global_position.x:
		# Jika mouse ada di sebelah KIRI karakter
		body_sprite.flip_h = true
		weapon_pivot.scale.y = -1 # Membalikkan seluruh isi Pivot (Sprite + ShootPoint)
	else:
		# Jika mouse ada di sebelah KANAN karakter
		body_sprite.flip_h = false
		weapon_pivot.scale.y = 1  # Mengembalikan posisi normalww
	
	# 4. Menembak
	if Input.is_action_just_pressed("shoot"):
		shoot()

func collect_powerup(type):
	var level = get_tree().current_scene
	
	if type == 0: # HEALTH
		health = min(health + 30, 100) # Memastikan darah tidak lebih dari 100
		if level.has_method("show_notification"):
			# Mengirimkan warna HIJAU (Red: 0, Green: 1, Blue: 0)
			level.show_notification("HEALTH RESTORED!", Color(0.2, 1.0, 0.2)) 
			
	elif type == 1: # SPREAD SHOT
		is_spread_shot = true
		powerup_timer.start(7.0)
		if level.has_method("show_notification"):
			# Mengirimkan warna KUNING/EMAS (Red: 1, Green: 1, Blue: 0)
			level.show_notification("OVERDRIVE: SPREAD SHOT!", Color(1.0, 0.8, 0.0))

# Hubungkan sinyal 'timeout' dari PowerUpTimer ke sini
func _on_power_up_timer_timeout():
	is_spread_shot = false

func shoot():
	var bullet = bullet_scene.instantiate()
	
	# Mengatur posisi dan rotasi peluru sesuai ShootPoint, BUKAN pemain
	bullet.global_position = shoot_point.global_position
	bullet.rotation = weapon_pivot.rotation
	
	if not is_spread_shot:
		create_bullet(0) # Tembakan normal
	else:
		# Menembak 3 peluru dengan sudut berbeda
		create_bullet(0)
		create_bullet(15)  # Miring 15 derajat
		create_bullet(-15) # Miring -15 derajat
	
	get_tree().root.add_child(bullet)
	$ShootSFX.play()
	
	# Getaran KECIL saat menembak (recoil)
	camera.apply_shake(5.0)

func create_bullet(angle_offset):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = shoot_point.global_position
	# Tambahkan offset pada rotasi weapon pivot
	bullet.rotation = weapon_pivot.rotation + deg_to_rad(angle_offset)
	get_tree().root.add_child(bullet)

# Fungsi untuk menerima serangan
func take_damage(amount):
	health -= amount
	print("Darah Player: ", health) # Muncul di konsol bawah untuk tes
	
	# Getaran BESAR saat terkena serangan
	camera.apply_shake(20.0)
	
	if health <= 0:
		die()

func die():
	# Reset status power-up
	is_spread_shot = false
	powerup_timer.stop()
	
	# Bersihkan semua power-up
	for item in get_tree().get_nodes_in_group("powerups"):
		item.queue_free()

	
	# Pindah ke layar Game Over
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
