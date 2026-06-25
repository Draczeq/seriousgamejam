extends Area2D

@export var CHIP_SCENE = preload("res://Scenes/poker.tscn")
@export var CARD_SCENE = preload("res://Scenes/card.tscn")
@export var DICE_SCENE = preload("res://Scenes/dice.tscn")
@export var MACHINE_SCENE = preload("res://Scenes/machine.tscn")
@export var START_RADIUS_X: float = 70.0
@export var START_RADIUS_Y: float = 30.0
@export var START_SPEED: float = 6.0

@onready var PLAYER = $"../CharacterBody2D"
@onready var ENEMY_NODE: = $"../Enemy"
@onready var SLOWING_TIMER: = $SlowingTimer
@onready var ATTACK_TIMER: = $AttackTimer

var RADIUS_X: float 
var RADIUS_Y: float 
var SPEED: float
var currentBody
var spinEnded: = false
var spinningBalls: Dictionary = {}
var random_value
var damage = 1

func _ready() -> void:
	position = Vector2(320,58)
	random_value = randi() % 17
	ATTACK_TIMER.start()
	reset_orbit()
	
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
			var targetPosition = global_position + offset + $Sprite2D.position
			body.global_position = targetPosition
			body.linear_velocity = Vector2.ZERO
			body.angular_velocity = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and spinningBalls.is_empty():
		body.call_deferred("reparent",$Sprite2D/Balls)
		var localPosition = body.global_position - global_position
		var startAngle = atan2(localPosition.y / RADIUS_Y, localPosition.x / RADIUS_X)
		spinningBalls[body] = startAngle
		SLOWING_TIMER.start(1.5 + randf() * 1.5)
		SPEED = 5.5 + randf()*1.5
	else:
		if body is RigidBody2D:
			var bounce_vector = (body.global_position-global_position).normalized()
			body.linear_velocity = Vector2(0,0)
			body.apply_impulse(bounce_vector * 500)
			print("szpont")
		if body.is_in_group("player"):
			body.dmg(damage)

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
		for body in spinningBalls.keys():
			var tempPos = body.global_position
			spinningBalls.clear()
			#body.reparent()
			body.global_position = tempPos
			body.linear_velocity = Vector2(0,0)
		random_value = randi() % 17
		reset_orbit()

func reset_orbit():
	RADIUS_X = START_RADIUS_X
	RADIUS_Y = START_RADIUS_Y
	SPEED = START_SPEED
	
func boss_attack(number):
	if number == 0:
		print("dices")
		var numberOfDices = 4+  randi()%2
		var distanceBeetween = 640 / numberOfDices
		var offset = randi() % distanceBeetween + 1
		for i in range(numberOfDices):
			var dice = DICE_SCENE.instantiate()
			ENEMY_NODE.add_child(dice)
			dice.global_position = Vector2(offset + distanceBeetween * i,0)
	if number == 1:
		print("cards")	
		var numberOfcards = 2+  randi()%3
		for i in range(numberOfcards):
			var wall = randi() % 2 
			var x
			var y
			if wall == 0:
				x = randi() % 2 * 640
				y = randi() % 360
			else:
				x = randi() % 640
				y = randi() % 2 * 360
			var card = CARD_SCENE.instantiate()
			ENEMY_NODE.add_child(card)
			card.global_position = Vector2(x,y)
			
	if number == 2:
		print("poker chips")
		var numberOfchips = 5+  randi()%3
		var singleSpread = 27
		var spread = -1.0 * (numberOfchips * singleSpread) /2 
		#var distanceBeetween = (360 * 0.7) / (numberOfchips - 1)
		var xMultiplier = randi() % 2
		var x = xMultiplier* 640
		#var rounded_distance: int = floor(0.3 * 360)
		var offset = 40 + randi() % 280
		var dirMultiplier 
		if xMultiplier == 0: 
			dirMultiplier = 1
		else:
			dirMultiplier = -1
		for i in range(numberOfchips):
			var chip = CHIP_SCENE.instantiate()
			ENEMY_NODE.add_child(chip)
			chip.global_position = Vector2(x, offset)
			var tempDir = dirMultiplier* spread + singleSpread * i * dirMultiplier
			chip.direction = Vector2(dirMultiplier,0).rotated(deg_to_rad(tempDir))
		
	if number == 3:
		print("roulette slam")
		$"../AnimationPlayer".play("roulette_slam")
		
	if number == 4:
		var machine = MACHINE_SCENE.instantiate()
		PLAYER.add_child(machine)
		machine.global_position = PLAYER.global_position
		

func random_attack():
	var random = 4#:= randi() % 5
	boss_attack(random)

func _on_attack_timer_timeout() -> void:
	random_attack()
