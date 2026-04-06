extends Node2D

@onready var health_bar = $CanvasLayer/HealthBar
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var player = $Player

var score = 0
var total_terminals = 3
var repaired_count = 0

func _process(delta):
	if player:
		health_bar.value = player.health
	score_label.text = "Score: " + str(score)

func add_score(amount):
	score += amount

# Fungsi baru untuk menangani perbaikan terminal
func terminal_repaired():
	repaired_count += 1
	print("Terminal diperbaiki! Total: ", repaired_count, "/", total_terminals)
	
	# Tambahkan bonus skor besar
	add_score(500) 
	
	if repaired_count >= total_terminals:
		win_game()

func win_game():
	GlobalData.final_score = score
	# Berpindah ke scene kemenangan
	get_tree().change_scene_to_file("res://Scenes/victory.tscn")
