extends AnimatedSprite2D

signal moved

@onready var aboinga: AudioStreamPlayer2D = $"aboinga!"
@onready var aowooaawww: AudioStreamPlayer2D = $aowooaawww

var is_tongue_grabbed := false
var tongue_distance := 0

func extend_tongue_to(distance: int):
	tongue_distance = distance
	frame = distance
	if not is_tongue_grabbed:
		frame += 5

func _ready() -> void:
	extend_tongue_to(0)

func move(direction: Vector2) -> void:
	position = position + direction * 16 * scale
	moved.emit()
	

func _input(event) -> void:
	if is_tongue_grabbed:
		if Input.is_action_just_pressed("LaunchFrog"):
			launch()
		elif Input.is_action_just_pressed("TongueGrab"):
			cancel_grab()
			rotate_to_mouse()
			show_transparent_tongue()
	else:
		if Input.is_action_just_pressed("TongueGrab") and tongue_distance > 0:
			grab()
		elif Input.is_action_just_pressed("MoveLeft"):
			move(Vector2(-1, 0))
		elif Input.is_action_just_pressed("MoveRight"):
			move(Vector2(1, 0))
		elif Input.is_action_just_pressed("MoveUp"):
			move(Vector2(0, -1))
		elif Input.is_action_just_pressed("MoveDown"):
			move(Vector2(0, 1))
		
		rotate_to_mouse()
		show_transparent_tongue()

func grab():
	is_tongue_grabbed = true
	extend_tongue_to(tongue_distance)

func cancel_grab():
	is_tongue_grabbed = false
	extend_tongue_to(tongue_distance)

func rotate_to_mouse():
	# Rotate the frog towards the mouse
	var mouse_position_difference := get_local_mouse_position()
	
	if abs(mouse_position_difference.x) > abs(mouse_position_difference.y):
		mouse_position_difference.y = 0
	elif abs(mouse_position_difference.y) > abs(mouse_position_difference.x):
		mouse_position_difference.x = 0

	var direction = mouse_position_difference.clamp(-Vector2.ONE, Vector2.ONE)

	if direction == Vector2.UP:
		pass
	elif direction == Vector2.DOWN:
		rotation_degrees += 180
		mouse_position_difference = mouse_position_difference.rotated(deg_to_rad(180))
	elif direction == Vector2.LEFT:
		rotation_degrees += -90
		mouse_position_difference = mouse_position_difference.rotated(deg_to_rad(-90))
	elif direction == Vector2.RIGHT:
		rotation_degrees += 90
		mouse_position_difference = mouse_position_difference.rotated(deg_to_rad(90))
	

func show_transparent_tongue():
	# the frog is already pointed towards the mouse!
	# the mouse position difference here
	# is relative to the frog's position and rotation
	var mouse_position_difference := get_local_mouse_position()
	
	if abs(mouse_position_difference.x) > 32:
		mouse_position_difference.y = 0

	var tongue_distance: int = -ceil(mouse_position_difference.y / 16)
	if tongue_distance > -1:
		tongue_distance = clamp(tongue_distance, 0, 4)
		extend_tongue_to(tongue_distance)

func launch():
	var direction := Vector2(
		0,
		-tongue_distance
	).rotated(rotation)
	
	move(direction)
	is_tongue_grabbed = false
	extend_tongue_to(0)
	aboinga.play(0)

func play_die():
	aowooaawww.play(0)
	await aowooaawww.finished
