extends Control
@export var gameStart = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gameStart:
		get_tree().change_scene_to_file("res://Scenes/project.tscn")

func _on_button_button_up() -> void:
	$AnimationPlayer.play("start_game")
	$LoadingPlayer.play("loading")

func _on_button_2_button_up() -> void:
	pass # Replace withpass # Replace with function body. function body.


func _on_button_3_button_up() -> void:
	get_tree().quit()
