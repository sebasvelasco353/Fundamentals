extends Area2D

# Constants
const SPEED = 500

# Variables
var direction:Vector2 = Vector2()

func _physics_process(delta):
	position += direction.normalized() * SPEED * delta
