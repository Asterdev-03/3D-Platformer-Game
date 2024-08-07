extends Area3D

const ROTATE_SPEED = deg_to_rad(5) # No. of degrees the coin rotate in radian

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(ROTATE_SPEED)

func _on_body_entered(body):
	queue_free()
