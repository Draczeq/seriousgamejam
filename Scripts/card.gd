extends CharacterBody2D

@onready var NAVIGATION_AGENT:= $NavigationAgent2D
@onready var PLAYER: CharacterBody2D = $"../../CharacterBody2D"
@onready var START_TIMER = $StartTimer
var start = false
var SPEED = 80
var hp = 10
var damage = 1
var direction: Vector2
var alcoholicOffset = 1

func _physics_process(delta: float) -> void:
	if start:
		NAVIGATION_AGENT.target_position = PLAYER.global_position
		direction = global_position.direction_to(NAVIGATION_AGENT.get_next_path_position())
		
		if NAVIGATION_AGENT.is_target_reached() == false:
			if not PLAYER.untouchable:
				velocity = direction * SPEED
			else:
				velocity = Vector2(0,0)
			move_and_slide()
		

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _on_turn_side_timer_timeout() -> void:
	alcoholicOffset = alcoholicOffset * -1
	$TurnSideTimer.start()

func dmg(damage):
	hp -= damage
	if hp <= 0:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.dmg(damage)
		queue_free()

func _on_start_timer_timeout() -> void:
	start = true
