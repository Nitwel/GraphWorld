extends Camera

var moveSpeed = 1.0
var jumpForce = 5.0
var gravity = 12.0
var minLookAngle = -90.0
var maxLookAngle = 90.0
var lookSensitivity = 100.0

var vel = Vector3()
var mouseDelta = Vector2()
var mouseLocked = true

onready var graph = get_parent().get_node("MeshInstance")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	vel.x = 0
	vel.z = 0
	
	var input = Vector2()
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backward"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	
	input = input.normalized()
	
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	var relativeDirection = (forward * input.y + right * input.x)
	
	vel.x = relativeDirection.x * moveSpeed
	vel.z = relativeDirection.z * moveSpeed
	
#	vel.y -= gravity * delta
	if vel.x != 0 or vel.y != 0 or vel.z != 0:
		graph.pos += vel
	
	
	if Input.is_action_pressed("jump"):
		vel.y = jumpForce

func _process(delta):
	if Input.is_action_just_pressed("menu"):
		if mouseLocked:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouseLocked = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouseLocked = true
			
	if mouseLocked:
		rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	
		rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
		rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	mouseDelta = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
