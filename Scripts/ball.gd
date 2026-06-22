extends RigidBody2D
@onready var DEATH_TIMER = $AutoDestruction
@onready var ANIMATION_PLAYER = $AnimationPlayer
var die = false
var distance

func _ready() -> void:
	pass 

func _physics_process(delta: float) -> void:
	if not die:
		if linear_velocity.y > 20:
			print("hi")
			DEATH_TIMER.start()
			ANIMATION_PLAYER.play("die")
			freeze = true
			die = true

func _on_auto_destruction_timeout() -> void:
	queue_free()
