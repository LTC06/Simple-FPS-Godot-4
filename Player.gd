extends CharacterBody3D

@export var MoveVelocity : float = 4.5
@export var SprintVelocity : float = 4.5
@export var JumpVelocity : float = 5.0

@export var LookSens : Vector2 = Vector2(0.1, 0.1)

@export var Gravity : float = 10

@export var Acceleration : float = 25
@export var Decceleration : float = 15
@export var LookAngle : Array = [-75, 85]


@export_group("Nodes")
@export var Camera : Camera3D
@export var Head : Node3D


var LookDir : Vector3 = Vector3.ZERO

var InputDir : Vector2 = Vector2.ZERO
var MoveDir : Vector3 = Vector3.ZERO

var FinalMoveVelocity : float = 0.0

var Sprinting : bool = false

func _ready() -> void:
	# Locks Mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _input(event: InputEvent) -> void:
	
	# Look
	if event is InputEventMouseMotion:
		LookDir.x -= event.relative.x * LookSens.x
		LookDir.y = clamp(LookDir.y - event.relative.y * LookSens.y, LookAngle[0], LookAngle[1])


func _process(delta: float) -> void:
	# Applies LookDir
	rotation_degrees.y = LookDir.x
	Head.rotation_degrees.x = LookDir.y

func _physics_process(delta: float) -> void:
	InputDir = Input.get_vector('Left', 'Right', 'Forwards', 'Backwards')
	
	MoveDir = transform.basis * Vector3(InputDir.x, 0, InputDir.y).normalized()
	
	
	# Gravity
	if not is_on_floor():
		velocity.y -= Gravity * delta
	
	# Jump
	if is_on_floor() and Input.is_action_just_pressed('Jump'):
		velocity.y = JumpVelocity
	
	# Sprint
	if Input.is_action_just_pressed('Sprint'):
		if not Sprinting:
			Sprinting = true
		else:
			Sprinting = false
	
	if Sprinting:
		FinalMoveVelocity = SprintVelocity
	else:
		FinalMoveVelocity = MoveVelocity
	
	
	# Move
	if MoveDir.length() > 0:
		velocity.x = lerp(velocity.x, MoveDir.x * FinalMoveVelocity, delta * Acceleration)
		velocity.z = lerp(velocity.z, MoveDir.z * FinalMoveVelocity, delta * Acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * Decceleration)
		velocity.z = lerp(velocity.z, 0.0, delta * Decceleration)
	
	move_and_slide()


