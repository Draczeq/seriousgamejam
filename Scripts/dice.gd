extends Area2D

@export var speed := 180
@onready var START_TIMER = $StartTimer
var start = false
var damage := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if start:
		global_position.y += delta*speed

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.dmg(damage)

func _on_start_timer_timeout() -> void:
	start = true
