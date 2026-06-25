extends RigidBody2D
@onready var DEATH_TIMER = $AutoDestruction
@onready var FLY_TIMER = $FlyTimer
@onready var DROP_TIMER = $DropTimer
@onready var ANIMATION_PLAYER = $AnimationPlayer

var slowing = false
var die = false
var distance

func _ready() -> void:
	FLY_TIMER.start()

func _physics_process(delta: float) -> void:
	if slowing:
		if abs(linear_velocity.x) < 0.1 and abs(linear_velocity.y) < 0.1:
			slowing = false	
			print("stop")
		else:
			linear_velocity -= linear_velocity.normalized()* (linear_velocity/linear_velocity.normalized())/8
			constant_force.y = 200
			if DROP_TIMER.is_stopped():
				DROP_TIMER.start()

func _on_auto_destruction_timeout() -> void:
	queue_free()

func _on_fly_timer_timeout() -> void:
	slowing = true

func _on_drop_timer_timeout() -> void:
	slowing = false
	constant_force.y = 0
	linear_velocity = Vector2(0,0)
