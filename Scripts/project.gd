extends Control

@onready var current_game = $Game
@onready var GAME_SCENE := preload("res://Scenes/game.tscn")
func _ready() -> void:
	pass 

func restart():
	current_game.queue_free()
	var game=GAME_SCENE.instantiate()
	add_child(game)
	move_child(game, 0)
	game.global_position = global_position
	current_game = game
