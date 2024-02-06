extends CharacterBody3D

# A vehicle drives around the world from VehicleNode to VehicleNode.
# If some obstacle is detected, the vehicle will try to avoid it.
# The vehicle will also try to avoid other vehicles.
# In order to handle things like stop lights, the vehicle has a "behindVehicle" node that the
# car behind this one will attempt to park at if this one is stopped.
# The player can steal the vehicle by pressing a button when close to it.
# Some vehicles are stationary, some vehicles are locked, some vehicles have a car alarm.

@export var movement_speed: float = 4.0
@export var rotation_speed = 1.0
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@export var vehicle_node: VehicleNode = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# connect the velocity signal as per docs
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	# if we don't have a vehicle node, get a random one from the world
	if vehicle_node == null:
		vehicle_node = get_node("/root/World/VehicleNodes").get_children()[randi() % get_node("/root/World/VehicleNodes").get_child_count()]
	
	set_movement_target(vehicle_node.global_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		select_random_vehicle_node()
		set_movement_target(vehicle_node.global_position)
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)

	look_at(next_path_position)

func select_random_vehicle_node():
	vehicle_node = get_node("/root/World/VehicleNodes").get_children()[randi() % get_node("/root/World/VehicleNodes").get_child_count()]


func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
