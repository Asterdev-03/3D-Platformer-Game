extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 10
const CAMERA_SPEED = 0.07
const CAMERA_ROTATE_SPEED = deg_to_rad(30)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var xForm : Transform3D

@onready var cameraController = $Camera_Controller
@onready var playerMeshInstance = $MeshInstance3D
@onready var playerRayCast = $RayCast3D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# rotate camera left and right
	if Input.is_action_just_pressed("camera_left"):
		cameraController.rotate_y(CAMERA_ROTATE_SPEED)
	
	if Input.is_action_just_pressed("camera_right"):
		cameraController.rotate_y(-CAMERA_ROTATE_SPEED)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# New Vector3 direction, taking into account the user aroow inputs and the camera rotation
	var direction = (cameraController.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# rotate player mesh so oreinted towards the diection moving in rotation to the camera
	if input_dir != Vector2(0,0):
		playerMeshInstance.rotation_degrees.y = cameraController.rotation_degrees.y - rad_to_deg(input_dir.angle()) - 90
	
	# rotate the player to align with the floor
	# align with floor when player is on the floor and not moving
	# if jumping, return the player to default postion
	if is_on_floor() and input_dir != Vector2(0,0):
		align_with_floor(playerRayCast.get_collision_normal())
		# To have smooth transition while aligning with the floor 
		global_transform = global_transform.interpolate_with(xForm,0.3)
	elif not is_on_floor():
		align_with_floor(Vector3.UP)
		# To have smooth transition while aligning with the floor 
		global_transform = global_transform.interpolate_with(xForm,0.3)
	
	# Update velocity and move the player
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Make Camera_Controller match postion of Player
	cameraController.position = lerp(cameraController.position, position, CAMERA_SPEED)

func align_with_floor(floor_normal):
	xForm = global_transform
	xForm.basis.y = floor_normal
	
	# Updating the transform X axis so not to skew or strech the player
	# after aligning it with the slope, when the player moves in ramp floor
	xForm.basis.x = -xForm.basis.z.cross(floor_normal)
	xForm.basis = xForm.basis.orthonormalized()
