# when the player clicks, the projectile is shot. It receives a velocity and travels in a straight line until it hits something.
# the projectile is a kinematic body, so it can't be affected by gravity or other forces. It can only be moved by code.
# the projectile has a collision shape, so it can detect when it hits something.

extends CharacterBody3D

class_name Projectile

# the projectile's speed in meters per second
var speed = 88

# how long after spawning until the projectile force-despawns
var despawn_time = 2

# the projectile's direction
var direction = Vector3()

func _process(delta):
	# move the projectile
	var collision: KinematicCollision3D = move_and_collide(direction * speed * delta)

	if(collision):
		var collider = collision.get_collider()
		# if the object we collided with has a function get_shot, call it
		if(collider.has_method("get_shot")):
			collider.get_shot(collision)
		# remove the projectile
		despawn()

# set the projectile's direction
func set_direction(new_direction):
	direction = new_direction

# detect if the projectile hit something
func despawn():
	# remove the projectile
	queue_free()


func _on_timer_timeout():
	despawn()
