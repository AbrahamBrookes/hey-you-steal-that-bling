extends CharacterBody3D

@export var speed = 75
@export var walk_speed = 75
@export var sprint_speed = 150
@export var friction = 0.875
@export var gravity = 98
@export var camera_rotation_speed = 250
@export var projectile_scene = preload("res://Player/Projectile.tscn")

var move_direction = Vector3()
var vel = Vector3()

@onready var camera = $CameraRig/Camera3D
@onready var camera_rig = $CameraRig
@onready var cursor= $Cursor


func _ready():
	camera_rig.set_as_top_level(true)
	cursor.set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	speed = walk_speed


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _physics_process(delta):
	camera_follows_player(delta)
	rotate_camera(delta)
	
	look_at_cursor()
	run(delta)
	
	vel *= friction
	vel.y -= gravity*delta
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(3)
	move_and_slide()
	vel = velocity
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("sprint"):
		speed = sprint_speed
	
	if Input.is_action_just_released("sprint"):
		speed = walk_speed

func shoot():
	# instantiate a projectile (Player/projectile.tscn) and set its direction to the current facing direction
	var projectile = projectile_scene.instantiate()
	add_sibling(projectile)
	projectile.global_transform.origin = $ProjectileSpawn.global_transform.origin
	projectile.set_direction(-global_transform.basis.z)
	

func camera_follows_player(delta):
	var player_pos = global_transform.origin
	camera_rig.global_transform.origin = player_pos

	# if the player is obscured by the camera, set the camera's offset to 0 22 0 and rotation to -90 0 0
	# we have a marker called CameraOriginalPosition that we use to cast this ray so that when the camera
	# moves like this it doesn't then pass the ray condition (if we were casting from the camera itself)
	var target_position = Vector3(0, 21, 4)
	var target_rotation = Vector3(-75, 0, 0)
	var lerp_speed: float = 5.0
	if $CameraRig/RayCast3D.is_colliding():
		target_position = Vector3(0, 22, 0)
		target_rotation = Vector3(-89, 0, 0)
		
	# Interpolate the position
	$CameraRig/Camera3D.transform.origin = $CameraRig/Camera3D.transform.origin.lerp(target_position, lerp_speed * delta)

	# Interpolate the rotation
	$CameraRig/Camera3D.rotation_degrees = $CameraRig/Camera3D.rotation_degrees.lerp(target_rotation, lerp_speed * delta)


func rotate_camera(delta):
	if Input.is_action_pressed("rotate_camera_cw"):
		camera_rig.rotate_y(deg_to_rad(-camera_rotation_speed * delta)) 
	if Input.is_action_pressed("rotate_camera_ccw"):
		camera_rig.rotate_y(deg_to_rad(camera_rotation_speed * delta)) 


func look_at_cursor():
	# Create a horizontal plane, and find a point where the ray intersects with it
	var player_pos = global_transform.origin
	var dropPlane  = Plane(Vector3(0, 1, 0), player_pos.y)
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = dropPlane.intersects_ray(from,to)
	if ! cursor_pos:
		cursor_pos = Vector3(0,0,0)
	
	# Set the position of cursor visualizer
	cursor.global_transform.origin = cursor_pos + Vector3(0,1,0)
	
	# Make player look at the cursor
	look_at(cursor_pos, Vector3.UP)


func run(delta):
	move_direction = Vector3()
	var camera_basis = camera.get_global_transform().basis
	if Input.is_action_pressed("up"):
		move_direction -= camera_basis.z
	elif Input.is_action_pressed("down"):
		move_direction += camera_basis.z
	if Input.is_action_pressed("left"):
		move_direction -= camera_basis.x
	elif Input.is_action_pressed("right"):
		move_direction += camera_basis.x
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	vel += move_direction*speed*delta
