extends CharacterBody2D

@export_category("移动参数")
@export var double_press_interval := 0.3
@export var move_speed: float = 75.0
@export var acceleration: float = 600.0
@export var deceleration: float = 800.0
@export var jump_velocity: float = -190.0
@export var max_jumps: int = 2
@export var fall_limit_y: float = 800.0

@export_category("瞬移参数")
@export var teleport_distance: float =40


@onready var sprite: Sprite2D = $Sprite2D

var flying: bool = false
var jump_count: int = 0
var last_space_press_time := -1000

func _physics_process(delta: float) -> void:
	if global_position.y > fall_limit_y:
		die()
		return

	if !flying:
		if is_on_floor():
			jump_count = 0
		apply_gravity(delta)
		handle_jump()
	else:
		handle_vertical_movement(delta)
	
	handle_horizontal_movement(delta)
	update_sprite_direction()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_vertical_movement(delta: float) -> void:
	var direction := Input.get_axis("squat", "jump")
	var target_speed := direction * jump_velocity
	if direction != 0.0:
		velocity.y = move_toward(velocity.y, target_speed, acceleration * delta)
	else:
		velocity.y = move_toward(velocity.y, 0.0, acceleration * delta)

func handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var target_speed := direction * move_speed
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_velocity
		jump_count += 1

func update_sprite_direction() -> void:
	if velocity.x != 0.0:
		sprite.flip_h = velocity.x < 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fly") and !event.is_echo():
		handle_space_pressed()
	if event.is_action_pressed("teleport") and !event.is_echo():
		teleport()

func teleport() -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	if direction_x == 0:
		direction_x = -1.0 if sprite.flip_h else 1.0
	var target_pos = global_position + Vector2(teleport_distance * direction_x, 0)
	global_position = target_pos

func handle_space_pressed() -> void:
	var current_time := Time.get_ticks_msec()
	var elapsed_time := current_time - last_space_press_time
	if elapsed_time <= double_press_interval * 1000.0:
		flying = not flying
		last_space_press_time = -1000
	else:
		last_space_press_time = current_time

func die() -> void:
	print("主角死亡，游戏重新开始！")
	get_tree().reload_current_scene()

# ========== 传送逻辑（核心在这里） ==========
# 这个函数由“门”的信号触发
func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		print("确认是主角，准备传送！")  # 只有确认是主角才会打印
		get_tree().change_scene_to_file("res://scenes/second.tscn")

  
	

# 碰钉子
func _on_spikes_01_body_entered(body: Node2D) -> void:
	if body == self:
		die()

func _on_spikes_02_body_entered(body: Node2D) -> void:
	if body == self:
		die()
