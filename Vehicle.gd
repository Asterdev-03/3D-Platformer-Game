extends VehicleBody3D

@export var MAX_STEER = 4.9
@export var ENGINE_POWER = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	steering = move_toward(steering,Input.get_axis("move_right","move_left") * MAX_STEER,delta * 10)
	engine_force = Input.get_axis("move_back","move_forward") * ENGINE_POWER
