extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENSITIVITY = 0.003

@onready var camera_3d: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $anim/AnimationPlayer
@onready var mesh_instance: Node3D = $anim
@onready var player_name: Label = $tag/SubViewport/VBoxContainer/name
@onready var ip: Label = $tag/SubViewport/VBoxContainer/ip

# Add these variables to store player info
var player_display_name: String = "Player"
var player_ip_address: String = ""
var is_host: bool = false
var has_been_initialized = false
@export var debug_mode: bool = false  # Toggle for debug prints

func _enter_tree() -> void:
	# Set authority based on node name (which is the player ID)
	set_multiplayer_authority(str(name).to_int())

func _ready():
	# Only initialize once
	if has_been_initialized:
		return
	
	has_been_initialized = true
	
	# Set camera only for local player
	camera_3d.current = is_multiplayer_authority()
	
	# Only show mesh for other players (not ourselves)
	mesh_instance.visible = !is_multiplayer_authority()
	
	# Update labels with professional formatting
	_update_player_display()
	
	# Set spawn position after being added to the tree
	var spawn_pos = get_meta("spawn_position", Vector3.ZERO)
	if spawn_pos != Vector3.ZERO:
		global_position = spawn_pos
		if debug_mode:
			print("POSITION SET: ", player_display_name, " at: ", global_position)
	
	# Remove the meta data since we've used it
	if has_meta("spawn_position"):
		remove_meta("spawn_position")
	
	if debug_mode:
		print("PLAYER READY: ", player_display_name, " | Authority: ", get_multiplayer_authority(), " | Camera: ", camera_3d.current)

func set_player_info(display_name: String, ip_address: String, host_status: bool):
	player_display_name = display_name
	player_ip_address = ip_address
	is_host = host_status

func _update_player_display():
	if player_name:
		player_name.text = player_display_name
		# Add color coding for host vs client
		if is_host:
			player_name.add_theme_color_override("font_color", Color.GOLD)
		else:
			player_name.add_theme_color_override("font_color", Color.CYAN)
	
	if ip:
		ip.text = player_ip_address
		ip.add_theme_color_override("font_color", Color.LIGHT_GRAY)

func _input(event):
	if not is_multiplayer_authority():
		return
	
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_3d.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, -1.5, 1.5)
	
	# Click to capture mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Key handling
	if event is InputEventKey and event.pressed:
		# ESC to release mouse
		if event.keycode == KEY_ESCAPE:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		# Quit game
		if event.keycode == KEY_Q:
			get_tree().quit()

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Reset velocity
	velocity = Vector3.ZERO
	
	# Get input direction
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply movement
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
	move_and_slide()
	
	# Handle animations
	update_animation(direction)

func update_animation(direction: Vector3):
	if direction.length() > 0:
		# Moving - play walk animation
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
	else:
		# Not moving - play idle animation
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
