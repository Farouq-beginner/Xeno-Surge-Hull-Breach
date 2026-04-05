extends CharacterBody2D

const SPEED = 300.0

# Memuat scene peluru agar siap dipakai
var bullet_scene = preload("res://bullet.tscn")

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED
	move_and_slide()
	
	look_at(get_global_mouse_position())
	
	# Mengecek apakah tombol tembak (klik kiri) ditekan
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	# 1. Membuat instance (kloningan) dari peluru
	var bullet = bullet_scene.instantiate()
	
	# 2. Menyesuaikan posisi dan rotasi peluru sama dengan senjata/player
	bullet.global_position = global_position
	bullet.rotation = rotation
	
	# 3. Memasukkan peluru ke dalam level utama (bukan ke dalam player)
	get_tree().root.add_child(bullet)
