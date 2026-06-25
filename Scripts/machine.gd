extends Area2D

@onready var SHADOW = $PointLight2D
@onready var FALL_TIMER = $FallTimer
@onready var ATTACK_TIMER = $AttackTimer
@onready var ANIMATOR = $AnimationPlayer
var falling = true
var damage = 1

func _ready() -> void:
	$Sprite2D.hide()
	$StaticBody2D.hide()
	$StaticBody2D.set_collision_layer_value(2,false)

func _process(delta: float) -> void:
	if falling:
		SHADOW.energy += delta *0.08
		SHADOW.scale += Vector2(1,1) * delta *  0.08
		SHADOW.scale += Vector2(1,1) * delta *  0.08

func _on_fall_timer_timeout() -> void:
	reparent($"../../Enemy")
	ATTACK_TIMER.start()

func _on_attack_timer_timeout() -> void:
	if falling == true:
		falling = false
		ANIMATOR.play("machine_falling")
		ATTACK_TIMER.start(0.42)
	else:
		$StaticBody2D.show()
		$StaticBody2D.set_collision_layer_value(2,true)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and $StaticBody2D.get_collision_layer_value(2) :
		body.dmg(damage)
