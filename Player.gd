extends Camera
class_name Player

var moveSpeed = 0.2
var jumpForce = 5.0
var gravity = 5.0
var minLookAngle = -90.0
var maxLookAngle = 90.0
var lookSensitivity = 100.0

var vel = Vector3()
var mouseDelta = Vector2()
var mouseLocked = true
var fly = true

onready var world = get_parent()

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
	
	relativeDirection.y = 0
	relativeDirection = relativeDirection.normalized()
	
	var mvSpeed = moveSpeed if !fly else moveSpeed * 10
	vel.x = relativeDirection.x * mvSpeed
	vel.z = relativeDirection.z * mvSpeed
	
	if !fly:
		vel.y -= gravity * delta
		
	if vel.x != 0 or vel.y != 0 or vel.z != 0:
		translation += vel
		
	if world == null:
		return
	
	var height = world.f(translation.x, translation.z)	+ 2
	
	if translation.y <= height:
		translation.y = height
	
	
	if Input.is_action_pressed("jump"):
		vel.y = jumpForce
	elif Input.is_action_pressed("sneak"):
		vel.y = -jumpForce
	elif fly:
		vel.y = 0

func _process(delta):
	if mouseLocked:
		rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	
		rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
		rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	mouseDelta = Vector2()

func _input(event):
	if Input.is_action_just_pressed("menu"):
		if mouseLocked:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouseLocked = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouseLocked = true
	
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 4
	if event is InputEventKey and Input.is_key_pressed(KEY_F):
		fly = !fly
