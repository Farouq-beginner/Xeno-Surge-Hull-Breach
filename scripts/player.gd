extends CharacterBody2D

var shoot_timer : Timer
var can_shoot = true

# --- Variabel Sistem Overheat ---
var heat : float = 0.0              # Suhu saat ini
const MAX_HEAT : float = 100.0      # Batas maksimal suhu sebelum overheat
const HEAT_PER_SHOT : float = 15.0  # Panas yang bertambah per tembakan
const COOL_SPEED : float = 40.0     # Kecepatan pendinginan per detik
var is_overheated : bool = false    # Status apakah senjata sedang macet

# --- Variabel Fisika Ruang Angkasa (Inersia) ---
const MAX_SPEED = 400.0
const ACCELERATION = 800.0  
const FRICTION = 200.0      
var health = 100

var is_dead = false 

var bullet_scene = preload("res://scenes/bullet.tscn")

@onready var body_sprite = $BodySprite
@onready var weapon_pivot = $WeaponPivot
@onready var weapon_sprite = $WeaponPivot/WeaponSprite
@onready var shoot_point = $WeaponPivot/ShootPoint
@onready var camera = $Camera2D
@onready var anim_player = $AnimationPlayer
@onready var powerup_timer = $PowerUpTimer

# --- Referensi Node UI Overheat Bar ---
# PASTIKAN PATH INI SESUAI DENGAN SUSUNAN NODE KAMU
@onready var overheat_bar = $CanvasLayer/TextureProgressBar 

var is_spread_shot = false

func _ready():
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	add_child(shoot_timer)
	shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))

func _physics_process(delta):
	if is_dead: return 

	# --- LOGIKA PENDINGINAN (COOLING) ---
	if heat > 0:
		heat -= COOL_SPEED * delta
		if heat < 0:
			heat = 0
			
		if is_overheated and heat == 0:
			is_overheated = false
			var level = get_tree().current_scene
			if level.has_method("show_notification"):
				level.show_notification("WEAPON READY!", Color(0.0, 1.0, 1.0)) # Cyan

	# --- UPDATE UI BAR ---
	if overheat_bar:
		overheat_bar.value = heat
		update_bar_color()

	# 1. Menghitung Input
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * MAX_SPEED, ACCELERATION * delta)
		if Input.is_action_pressed("move_up"):
			anim_player.play("jump")
		else:
			anim_player.play("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		anim_player.play("idle")
	
	move_and_slide()
	
	# 2 & 3. Rotasi dan Flipping
	var mouse_pos = get_global_mouse_position()
	weapon_pivot.look_at(mouse_pos)
	
	if mouse_pos.x < global_position.x:
		body_sprite.flip_h = true
		weapon_pivot.scale.y = -1 
	else:
		body_sprite.flip_h = false
		weapon_pivot.scale.y = 1  
	
	# 4. Menembak
	if Input.is_action_pressed("shoot") and can_shoot and not is_overheated:
		shoot()
		can_shoot = false
		shoot_timer.start(0.2) # jeda 0.2 detik antar peluru

func _on_shoot_timer_timeout():
	can_shoot = true

func collect_powerup(type):
	var level = get_tree().current_scene
	if type == 0: 
		health = min(health + 20, 100) 
		if level.has_method("show_notification"):
			level.show_notification("HEALTH RESTORED!", Color(0.2, 1.0, 0.2)) 
	elif type == 1: 
		is_spread_shot = true
		powerup_timer.start(7.0)
		if level.has_method("show_notification"):
			level.show_notification("OVERDRIVE: SPREAD SHOT!", Color(1.0, 0.8, 0.0))

func _on_power_up_timer_timeout():
	is_spread_shot = false

func shoot():
	# --- LOGIKA PENAMBAHAN PANAS ---
	heat += HEAT_PER_SHOT
	
	if heat >= MAX_HEAT:
		is_overheated = true
		heat = MAX_HEAT 
		
		# Kunci warna bar jadi merah saat senjata macet
		if overheat_bar:
			overheat_bar.tint_progress = Color(1.0, 0.0, 0.0) 
		
		var level = get_tree().current_scene
		if level.has_method("show_notification"):
			level.show_notification("OVERHEAT! COOLING DOWN...", Color(1.0, 0.4, 0.0)) # Oranye

	if not is_spread_shot:
		create_bullet(0) 
	else:
		create_bullet(0)
		create_bullet(15)  
		create_bullet(-15) 
	
	$ShootSFX.play()
	camera.apply_shake(5.0)

func create_bullet(angle_offset):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = shoot_point.global_position
	bullet.rotation = weapon_pivot.rotation + deg_to_rad(angle_offset)
	get_tree().root.add_child(bullet)

func take_damage(amount):
	if is_dead: return 
	health -= amount
	print("Darah Player: ", health) 
	camera.apply_shake(20.0)
	if health <= 0:
		die()

func die():
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO 
	weapon_pivot.hide() 
	
	if anim_player.has_animation("death"):
		anim_player.play("death")

	is_spread_shot = false
	powerup_timer.stop()
	
	for item in get_tree().get_nodes_in_group("powerups"):
		item.queue_free()

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

# --- FUNGSI UPDATE WARNA BAR ---
func update_bar_color():
	if is_overheated or not overheat_bar:
		return # Jangan ubah warna kalau sedang fase overheat (biarkan merah)
		
	var ratio = heat / MAX_HEAT
	if ratio < 0.5:
		overheat_bar.tint_progress = Color(0.2, 1.0, 0.2) # Hijau
	elif ratio < 0.8:
		overheat_bar.tint_progress = Color(1.0, 0.8, 0.0) # Kuning
	else:
		overheat_bar.tint_progress = Color(1.0, 0.4, 0.0) # Oranye
