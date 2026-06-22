extends CharacterBody2D

@export var MAX_SPEED = 70.0
@export var SPEED = 70.0
@export var THROW_FORCE_MULTIPLAYER = 110.0
@export var SPINNING_MULTIPLAYER = 0.8
@export var BALL_SCENE = preload("res://Scenes/ball.tscn")
@onready var SPINNING_TIMER = $SpinningTime
@onready var SPINNING_COOLDOWN_TIMER = $SpinningCooldown
@onready var BALL_POSITION = $BallPosition
@onready var BALL_ARROW = $BallPosition/Arrow
@onready var BALLS = $"../Balls"
var spinningCooldown = 3
var canSpin = true
var spinningTime
var holdingTime: float
var colorsInfo = [
	{"id": 1, "name": "black", "color": Color(0,0,0,255)},
	{"id": 2, "name": "red", "color": Color(255,0,0,255)},
	{"id": 3, "name": "green", "color":Color(0,255,0,255)}
]
var currentColor = 0

func _ready() -> void:
	BALL_ARROW.hide()
	$BallPosition/BallPlaceholder.modulate = colorsInfo[currentColor]["color"]

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity = direction * SPEED
	move_and_slide()
	if Input.is_action_just_released("change_ball"):
		change_ball()
	if canSpin:
		if Input.is_action_pressed("spin"):
			holdingTime+=delta
			if holdingTime > 0.15:
				SPEED = 0.4 *MAX_SPEED
				spin(delta)
		if Input.is_action_just_released("spin"):
			if holdingTime <= 0.15:
				attack()
			else:
				SPEED = MAX_SPEED
				stop_spinning()
			holdingTime = 0
	
func spin(delta):
	if SPINNING_TIMER.is_stopped():
		BALL_ARROW.show()
		SPINNING_TIMER.start()
		BALL_POSITION.rotation_degrees = randi() % 360 + 1
	spinningTime = SPINNING_TIMER.wait_time - SPINNING_TIMER.time_left
	BALL_POSITION.rotation_degrees+=260 * delta * (spinningTime+ 1) * SPINNING_MULTIPLAYER
	
	
func throw():
	BALL_ARROW.hide()
	canSpin = false
	var ball = BALL_SCENE.instantiate()
	BALLS.add_child(ball)
	ball.modulate = colorsInfo[currentColor]["color"]
	ball.global_position = BALL_ARROW.global_position
	ball.apply_impulse((BALL_ARROW.global_position - global_position).normalized()  * spinningTime * THROW_FORCE_MULTIPLAYER)
	BALL_POSITION.rotation_degrees = 0.0

func stop_spinning():
	print("player stopped spinning")
	SPINNING_TIMER.stop()
	SPINNING_COOLDOWN_TIMER.start(spinningCooldown)
	throw()

func attack():
	pass

func _on_spinning_time_timeout() -> void:
	print("player spinned for too long")
	SPINNING_TIMER.stop()
	SPINNING_COOLDOWN_TIMER.start(spinningCooldown*1.5)
	throw()
	SPEED = MAX_SPEED

func _on_spinning_cooldown_timeout() -> void:
	canSpin = true
	
func change_ball():
	currentColor += 1
	if(currentColor > 2):
		currentColor = 0
	$BallPosition/BallPlaceholder.modulate = colorsInfo[currentColor]["color"]
		
	
