extends MeshInstance
class_name Chunk

export var size = Vector3(10,10,10)
var function: FuncRef

onready var threadPool = get_node("/root/ThreadPool")
var mdt = MeshDataTool.new()
var material = preload("res://GraphWorld.tres")

func _init(start_pos: Vector3, start_size: Vector3, fun: FuncRef):
	translation = start_pos
	size = start_size
	self.function = fun

func _ready():
	threadPool.connect("task_finished", self, "task_done")
	threadPool.connect("task_discarded", self, "task_failed")
	threadPool.submit_task_unparameterized(self, "calculate_vectors", get_tag())
	
func calculate_vectors():
	
#	print(get_tag())
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)

	# PackedVectorXArrays for mesh construction.
	var verts = PoolVector3Array()
#	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	var indices = PoolIntArray()
	
	var scaled_size = Vector3(size.x / scale.x, 0, size.z / scale.z)

	for z in range(0, scaled_size.z + 1):
		for x in range(0, scaled_size.x + 1):
			var x_loc = scale.x * x + translation.x
			var z_loc = scale.z * z + translation.z
			
			normals.push_back(slope(x_loc, z_loc))
			verts.push_back(Vector3(x, function.call_func(x_loc, z_loc), z))

	for z in range(0, scaled_size.z * (scaled_size.x + 1), scaled_size.x + 1):
		for x in range(0, scaled_size.x):
			indices.push_back(0 + x + z)          # Bottom left
			indices.push_back(1 + x + z)          # Bottom right
			indices.push_back(1 + scaled_size.x + x + z) # Top left
			
			indices.push_back(1 + scaled_size.x + x + z) # Top left
			indices.push_back(1 + x + z)          # Bottom right
			indices.push_back(2 + scaled_size.x + x + z) # Top right
		
		
	# Assign arrays to mesh array.
	arr[Mesh.ARRAY_VERTEX] = verts
#	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices
	
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr) # No blendshapes or compression used.
	
	mesh = arr_mesh
	mdt.create_from_surface(mesh, 0)
	mesh.surface_set_material(0, material)
	
	return arr
	
func get_tag():
	return String(translation.x) + String(translation.z)
	
func task_failed(task_tag):
	print("failed ", task_tag)

func task_done(task_tag):
#	print("task finished", task_tag)
	if task_tag != get_tag():
		return
#	showNormals()
	
func slope(x, z):
	var precision = 0.1
	var dx = Vector3(precision, function.call_func(x + precision/2, z) - function.call_func(x - precision/2, z), 0)
	var dz = Vector3(0, function.call_func(x, z + precision/2) - function.call_func(x, z - precision/2), precision)
	
	return dz.cross(dx).normalized()
	
func showNormals():
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var vectors = PoolVector3Array()
	
	for i in mdt.get_vertex_count():
		var vert = mdt.get_vertex(i)
		var normal =mdt.get_vertex_normal(i)
		vectors.push_back(vert)
		vectors.push_back(vert + normal)
		
	arr[Mesh.ARRAY_VERTEX] = vectors
	var mesh = MeshInstance.new()
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arr)
	mesh.mesh = arr_mesh
	add_child(mesh)
	
func updateMesh():
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(i)
		v.y = function.call_func(v.x + translation.x,v.z + translation.z)
		mdt.set_vertex(i, v)
	
	if mesh.get_surface_count() > 0:
		mesh.surface_remove(0)
		mdt.commit_to_surface(mesh)
		mesh.surface_set_material(0, load("res://GraphWorld.tres"))
