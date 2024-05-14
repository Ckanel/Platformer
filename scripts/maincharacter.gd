class_name Player
extends CharacterBody2D


@export var SPEED : float = 260
@export var JUMP_VELOCITY : float = -600.0
@export var jump_time : float = 0.25
@export var COYOTE_TIME = 0.075
@export var gravity_multiplying: float = 1.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping : bool = false
var coyote_timer : float = 0.0
var jump_timer : float = 0.0
var applied_impulse = false
var applied_impulse_timer = 0
var applied_impulse_force = 5
var can_control : bool = true
var force_timer = 0.0
var force_duration = 0.5  
@onready var sprite_2d = $AnimatedSprite2D
var starting_position = Vector2(180,200)
var max_health = 3
var health = 0
var can_take_damage = true;


func _ready():
	health = max_health
	GameManager.player = self

func _physics_process(delta):
	if not can_control: return 
	#gravity 
	if not is_on_floor() and not is_jumping:
		velocity.y += gravity * gravity_multiplying* delta
		coyote_timer += delta
	else:
		coyote_timer = 0.0
	
	  

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or coyote_timer < COYOTE_TIME) :
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif  Input.is_action_just_pressed("ui_accept") and is_jumping:
		velocity.y = JUMP_VELOCITY

	if is_jumping and Input.is_action_just_pressed("ui_accept") and jump_timer <jump_time :
		jump_timer += delta
	else:
		is_jumping  = false
		jump_timer = 0

	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED

	#Animations
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = 'walking'
	else : 
		sprite_2d.animation = 'default'
		
	# Add impulse force to the kinematic body
	
	if applied_impulse:
		applied_impulse_timer += delta # count the time passed from t0=0
		velocity.y = -applied_impulse_force* SPEED + gravity * applied_impulse_timer # calcualte y velocity
		# if velocity ~ 0, stop applying forceaaaaaa
		if velocity.y < 0.01:
			applied_impulse_timer = 0
			applied_impulse = false
		# Flip the sprite based on the direction of movement.
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, 10)
	
	if direction != 0:
		sprite_2d.flip_h = direction < 0
		
	move_and_slide()
	if position.y >= 600:
		die()
func add_force(explosion_position : Vector2):
	applied_impulse = true
	
	#gwnia p th kinithoume 
	print("Global position: ",global_position)
	print("Explosion position: ",explosion_position)
	var direction = (global_position - explosion_position)
	print(direction)
	
	velocity.x = direction.x * SPEED/5
	velocity.y = SPEED*direction.y/5
	
func take_damage(damage_amount : int):
	if can_take_damage:
		iframes()
		
		health -= damage_amount
		
		get_node("Healthbar2").update_healthbar(health, max_health)
		
		if health <= 0:
			handle_danger()

func iframes():
	can_take_damage = false	
	$AnimationPlayer.play("iframes")
	await get_tree().create_timer(1).timeout
	can_take_damage = true
	
func power_up(power_up):
	var boomstick_node = get_node("Boomstick")
	if boomstick_node:
		boomstick_node.cooldown_power_up(power_up)
func downgrade_power_up():
	var boomstick_node = get_node("Boomstick")
	if boomstick_node:
		boomstick_node.cooldown_power_up(0.8)
func handle_danger() -> void:
	print("Player died")
	visible = false
	can_control = false
	var lvl = LevelManager.loaded_level.level_id
	LevelManager.unload_level()
	LevelManager.load_level(lvl)
	await get_tree().create_timer(1).timeout
	reset_player()
func reset_player() -> void:
	LevelManager.loaded_level.level_start_pos.global_position = starting_position
	global_position = starting_position
	visible = true
	can_control = true
	
func die():
	if health>0:
		GameManager.respawn_player()
	elif health<= 0:
		take_damage(1)
	SPEED = 260.0
