extends CharacterBody2D

@export var CLAWS_DMG = 10.0
@export var MAX_SPEED = 140.0
@export var SPEED = 140.0
@export var THROW_FORCE_MULTIPLAYER = 290.0
@export var SPINNING_MULTIPLAYER = 1
@export var BALL_SCENE = preload("res://Scenes/ball.tscn")
@onready var SPINNING_TIMER = $SpinningTime
@onready var SPINNING_COOLDOWN_TIMER = $SpinningCooldown
@onready var BALL_POSITION = $BallPosition
@onready var BALL_ARROW = $BallPosition/Arrow
@onready var BALLS = $"../Balls"
@onready var CLAWS = $PlayerAttack
@onready var PROJECT = $"../.."

var hp = 3
var untouchable = false
var direction
var last_dir := Vector2(1,0)
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
	$PlayerAttack.scale.x = -1
	BALL_ARROW.hide()
	$BallPosition/Arrow/BallPlaceholder.modulate = colorsInfo[currentColor]["color"]
	$PlayerAttack.hide()
	$PlayerAttack/CollisionPolygon2D.disabled = true

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	if direction != Vector2(0,0):
		last_dir = direction
	if last_dir.x == -1:
		$Sprite2D.flip_h = true
	if last_dir.x == 1:
		$Sprite2D.flip_h = false
	velocity = direction * SPEED
	move_and_slide()
	if Input.is_action_just_released("change_ball"):
		change_ball()
	if canSpin:
		if Input.is_action_just_released("spin"):
			SPEED = MAX_SPEED
			stop_spinning()
			holdingTime = 0
		if Input.is_action_pressed("spin"):
			holdingTime+=delta
			SPEED = 0.4 *MAX_SPEED
			spin(delta)
		else:
			if Input.is_action_just_pressed("attack") and not untouchable:
				attack()
					
	
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

func change_ball():
	currentColor += 1
	if(currentColor > 2):
		currentColor = 0
	$BallPosition/Arrow/BallPlaceholder.modulate = colorsInfo[currentColor]["color"]
	
func attack():
	if last_dir.x == -1:
		$PlayerAttack.scale.x = 1
		$PlayerAttack.rotation_degrees = 0
	elif last_dir.x == 1:
		$PlayerAttack.scale.x = -1
		$PlayerAttack.rotation_degrees = 0
	elif last_dir.y == -1:
		$PlayerAttack.scale.x = 1
		$PlayerAttack.rotation_degrees = 90
	elif last_dir.y == 1:
		$PlayerAttack.scale.x = -1
		$PlayerAttack.rotation_degrees = 90
	$PlayerAttack.show()
	$PlayerAttack/AnimatedSprite2D.play("attack")
	$PlayerAttack/CollisionPolygon2D.disabled = false
func dmg(damage):
	if not untouchable:
		untouchable = true
		set_collision_layer_value(1, false)
		set_collision_mask_value(2, false)
		set_collision_mask_value(4, false)
		print("player dmg")
		$DamageCooldown.start()
		$AnimationPlayer.play("untouchable")
		hp -= damage
		if hp <= 0:
			PROJECT.call_deferred("restart")


func _on_spinning_time_timeout() -> void:
	print("player spinned for too long")
	SPINNING_TIMER.stop()
	SPINNING_COOLDOWN_TIMER.start(spinningCooldown*1.5)
	throw()
	SPEED = MAX_SPEED

func _on_spinning_cooldown_timeout() -> void:
	canSpin = true
	
func _on_claw_animation_finished() -> void:
	$PlayerAttack.hide()
	$PlayerAttack/CollisionPolygon2D.disabled = true

func _on_claws_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.dmg(CLAWS_DMG)

func _on_damage_cooldown_timeout() -> void:
	untouchable = false
	set_collision_layer_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(4, true)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "untouchable":
		if untouchable:
			$AnimationPlayer.play("untouchable")
