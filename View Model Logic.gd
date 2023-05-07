extends Node3D

### DISCLAMER ##
# PLEASE EDIT SCRIPT FOR YOUR OWN USES BECAUSE SOMETHINGS WRITTEN IN IT MIGHT NOT WORK FOR YOU.

## MAKE SURE TO SET THIS VARIABLE
@export var PlayerNode : CharacterBody3D

## Used to pivot the weapon around its origin and not the around ViewModels origin.
@export var WeaponPivot : Node3D
var DefaultWeaponPivotPOS : Vector3

# Final Vectors ---
var SwayVector : Vector3
var IdleVectorPOS : Vector3
var IdleVectorROT : Vector3
var MoveBobVector : Vector3
# ------------------------------------------------------------------------------

# Sway Parameters & Variables ---
@export_group('Sway')

## The Maximum amount the WeaponPivot will be displaced.
@export var MaxSway : float = .1

## The Strength of the spinginess of the WeaponPivot.
@export var SwayStrength : float = 25.0

## This changes how fast the WeaponPivot will go to its resting position.
@export var SwayDamping : float = 10.0

var SwayDir : Vector3
var SwayForce : Vector3
# ------------------------------------------------------------------------------

# Idle Parameters & Variables ---
@export_group('Idle')

## This curve controls how the WeaponPivot will bob up & down while Idle.
@export var IdleCurve : Curve

## This controls how the WeaponPivot will not stay still to mimic how humans can't keep perfectly still.
@export var IdleNoise : Noise

## Controls the strength of the Idle.
@export var IdleStrength : float = .05

## Controls the speed of the Idle.
@export var IdleSpeed : float = .1

var IdleCurveDelta : float = 0.0
var IdleNoiseDelta : float = 0.0
# ------------------------------------------------------------------------------

# MoveBob Parameters & Variables ---
@export_group('MoveBob')

## Controls the strength of the MoveBob.
@export var MoveBobStrength : float = 1.0

## Controls the speed of the MoveBob.
@export var MoveBobSpeed : float = 1.0

@export_subgroup('MoveBob Curves')
## Controls Left & Right Movement
@export var MoveBobCurveX : Curve

## Controls Up & Down Movement
@export var MoveBobCurveY : Curve

var MoveBobDelta : float = 0.0
var MoveStrength : float = 0.0
# ------------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	
	# Gets the mouse movements.
	if event is InputEventMouseMotion:
		SwayDir.x = event.relative.x * (MaxSway * 0.01)
		SwayDir.y = event.relative.y * (MaxSway * 0.01)

func ProcessSway(delta : float) -> void:
	
	# All this code basically calculates a spring force.
	SwayForce.x = SwayVector.x * SwayStrength
	SwayForce.y = SwayVector.y * SwayStrength
	
	SwayDir.x = clamp(SwayDir.x - (SwayForce.x * delta), -MaxSway, MaxSway)
	SwayDir.y = clamp(SwayDir.y - (SwayForce.y * delta), -MaxSway, MaxSway)
	
	SwayVector.x = lerp(SwayVector.x, SwayDir.x, delta * SwayDamping)
	SwayVector.y = lerp(SwayVector.y, SwayDir.y, delta * SwayDamping)

func ProcessIdle(delta : float) -> void:
	# Loops Delta
	if IdleCurveDelta < 1:
		IdleCurveDelta += delta * IdleSpeed
	else:
		IdleCurveDelta = clamp(IdleCurveDelta - 1.0, 0.0, INF)
	
	IdleNoiseDelta += delta * 25
	
	IdleVectorROT.x = IdleNoise.get_noise_2d(IdleNoiseDelta, 0) * 0.025
	IdleVectorROT.y = IdleNoise.get_noise_2d(IdleNoiseDelta, 25) * 0.025
	IdleVectorROT.z = IdleNoise.get_noise_2d(IdleNoiseDelta, 50) * 0.025
	
	IdleVectorPOS.y = IdleCurve.sample(IdleCurveDelta) * IdleStrength

func ProcessMoveBob(delta : float) -> void:
	
	MoveStrength = (PlayerNode.get_real_velocity().length() / PlayerNode.MoveVelocity)
	
	# Loops Delta
	if MoveBobDelta < 1.0:
		MoveBobDelta += (delta * MoveBobSpeed) * MoveBobStrength
	else:
		MoveBobDelta = clamp(MoveBobDelta - 1.0, 0.0, INF)
	
	MoveBobVector.x = (MoveBobCurveX.sample(MoveBobDelta) * MoveBobStrength) * MoveStrength
	MoveBobVector.y = (MoveBobCurveY.sample(MoveBobDelta) * MoveBobStrength) * MoveStrength

func _ready() -> void:
	# Remove this line to set your own Weapon Pivot
	WeaponPivot = get_child(0).get_node('Weapon Pivot')
	
	DefaultWeaponPivotPOS = WeaponPivot.position

func _physics_process(delta: float) -> void:
	ProcessSway(delta)
	ProcessIdle(delta)
	ProcessMoveBob(delta)
	
	# Applies all vectors to the weapon pivot
	WeaponPivot.rotation.x = IdleVectorROT.y
	WeaponPivot.rotation.y = IdleVectorROT.x
	WeaponPivot.rotation.z = IdleVectorROT.z + (-SwayVector.x * 2)
	
	WeaponPivot.position.x = DefaultWeaponPivotPOS.x + -SwayVector.x + MoveBobVector.x
	WeaponPivot.position.y = DefaultWeaponPivotPOS.y + IdleVectorPOS.y + SwayVector.y + MoveBobVector.y
	
	$'../HUD/Crosshair Pivot'.position.x = (1920 * 0.5) + ((-SwayVector.x + MoveBobVector.x + IdleVectorROT.y) * 250)
	$'../HUD/Crosshair Pivot'.position.y = (1080 * 0.5) + ((-SwayVector.y + -MoveBobVector.y - IdleVectorROT.x) * 250)
