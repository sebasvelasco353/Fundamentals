extends Node2D
class_name  Weapon

# signals
signal reloaded()
signal reload_progress(progress)

# States for the weapon
enum STATES { READY, FIRING, RELOADING }
var state:STATES = STATES.READY

# Exports
@export var BULLET_SCENE:PackedScene

# references
@onready var reload_timer = $Timer
@onready var audio_player = $AudioStreamPlayer

func _process(delta):
	if !reload_timer.is_stopped():
		reload_progress.emit(1 - (reload_timer.time_left / reload_timer.wait_time))

func change_state(new_state:STATES):
	# Handles the state change of the weapon
	state = new_state

func fire():
	if state == STATES.FIRING || state == STATES.RELOADING:
		return

	# change the current state
	change_state(STATES.FIRING)
	# create a bullet at our position and set its position
	var bullet = BULLET_SCENE.instantiate()
	bullet.direction = Vector2.from_angle(global_rotation)
	bullet.global_position = global_position
	
	audio_player.play()
	
	# Add bullet to the root scene so translation is in world space
	get_tree().root.add_child(bullet)
	# We set the state to reloading and start the reloading timer
	change_state(STATES.RELOADING)
	reload_timer.start()

func _on_timer_timeout():
	change_state(STATES.READY)
	reloaded.emit()
