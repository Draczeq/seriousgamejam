extends Area2D

@export var RADIUS_X: float = 70.0
@export var RADIUS_Y: float = 30.0
@export var SPEED: float = 6.0
@onready var SLOWING_TIMER: = $Timer
var currentBody
var spinEnded: = false

var spinningBalls: Dictionary = {}

func _physics_process(delta: float) -> void:
	for body in spinningBalls.keys():
		if is_instance_valid(body):
			body.set_physics_process(false)
			spinningBalls[body] -= SPEED * delta
			var currentAngle = spinningBalls[body]
			var offset = Vector2(
				cos(currentAngle) * RADIUS_X, 
				sin(currentAngle) * RADIUS_Y
			)
			var targetPosition = global_position + offset
			
			body.global_position = targetPosition
			body.linear_velocity = Vector2.ZERO
			body.angular_velocity = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		var localPosition = body.global_position - global_position
		var startAngle = atan2(localPosition.y / RADIUS_Y, localPosition.x / RADIUS_X)
		spinningBalls[body] = startAngle
		currentBody = body
		SLOWING_TIMER.start(1.5 + randf() * 1.5)
		SPEED = 5.5 + randf()*1.5

func _on_body_exited(body: Node2D) -> void:
	if body in spinningBalls:
		spinningBalls.erase(body)

func _on_timer_timeout() -> void:
	if (RADIUS_X > 29 and RADIUS_Y >17):
		if SPEED > 2:
			SPEED -= 0.004
		if SPEED < 2.5:
			RADIUS_X -= 0.4
			RADIUS_Y -= 0.2
		SLOWING_TIMER.start(0.01)
	else:
		SPEED=0

 
