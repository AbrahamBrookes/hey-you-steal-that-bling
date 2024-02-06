extends Node3D

class_name VehicleNode

# A VehicleNode has a single from_node and one or more to_nodes.
# When a vehicle reaches a node it can decide which of the to_nodes to continue to.
# A VehicleNode has a DesiredSpeed that oncoming Vehicles should attempt to match
# when they are approaching this node.
# A VehicleNode contains a list of Vehicles which is a first in first out list
# of the Vehicles that are approaching this node. If a vehicle is not the first
# in this list, it will use the "BehindVehicle" node of the vehicle in front of
# it in the list, so they don't all race to the same node.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
