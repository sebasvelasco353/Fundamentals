extends CharacterBody2D
class_name Tank

# constants
const SPEED:float = 64.0
const TURN_SPEED:int = 2
const ROTATE_SPEED:int = 20

# variables
var direction:Vector2 = Vector2.RIGHT
var speed_modifier:float = 1.0

# signals
signal collected(collectable)
signal reloaded()
signal reload_progress(progress)

#exports
@export var weapon: Weapon

# references
@onready var body_sprite = $BodySprite
@onready var animation_player = $AnimationPlayer
@onready var collider = $CollisionShape2D

func _ready():
	weapon.reloaded.connect(func(): reloaded.emit())
	weapon.reload_progress.connect(func(progress): reload_progress.emit(progress))

func _physics_process(delta):
	var input_direction := Input.get_vector("turn_left", "turn_right", "move_backward", "move_forward")
	if input_direction.x != 0:
		# Rotate direction based on the input vector and apply turn speed
		direction = direction.rotated(input_direction.x * (PI/2) * TURN_SPEED * delta)
		rotation = direction.angle()
	if input_direction.y != 0:
		speed_modifier = World.get_custom_data_at(position, "speed_modifier")
		var move_speed = SPEED * speed_modifier
		# Move forward/backward depending of input
		animation_player.play("move")
		velocity = lerp(velocity, (direction.normalized() * input_direction.y) * move_speed, SPEED * delta)
	else:
		# Stop our character
		velocity = Vector2.ZERO
		animation_player.play("idle")

	# Apply our movement
	move_and_slide()
	
	# Apply Weapon rotation
	var weapon_rotate_direction := Input.get_axis("rotate_wapon_left", "rotate_weapon_right")
	weapon.rotation_degrees += (weapon_rotate_direction * ROTATE_SPEED * delta * PI)

func _input(event):
	if event.is_action_pressed("weapon_fire"):
		weapon.fire()

func collect(collectable):
	collected.emit(collectable)
