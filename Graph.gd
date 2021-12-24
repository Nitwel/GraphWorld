tool
extends MeshInstance

export var pos = Vector3(0,0,0) setget setPos
export var size = Vector3(10,10,10) setget setSize

var mdt = MeshDataTool.new()

onready var debug = get_parent().get_node("DebugVectors")

func f(x, y):
	return (x / 5) * sin(x / 5) + (y / 5) * cos(y / 5)

func _ready():
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)

	# PackedVectorXArrays for mesh construction.
	var verts = PoolVector3Array()
#	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	var indices = PoolIntArray()

	for z in range(0, size.z + 1):
		for x in range(0, size.x + 1):
			normals.push_back(slope(x, z))
			verts.push_back(Vector3(x - size.x/2, f(x + pos.x,z + pos.z), z - size.z/2))

	for z in range(0, size.z * (size.x + 1), size.x + 1):
		for x in range(0, size.x):
			indices.push_back(0 + x + z)          # Bottom left
			indices.push_back(1 + x + z)          # Bottom right
			indices.push_back(1 + size.x + x + z) # Top left
			
			indices.push_back(1 + size.x + x + z) # Top left
			indices.push_back(1 + x + z)          # Bottom right
			indices.push_back(2 + size.x + x + z) # Top right
		
		
	# Assign arrays to mesh array.
	arr[Mesh.ARRAY_VERTEX] = verts
#	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices
	
	# Create mesh surface from mesh array.
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr) # No blendshapes or compression used.
	
	mesh = arr_mesh
	
	drawVectors(verts, normals)
	
	mdt.create_from_surface(mesh, 0)
	
	mesh.surface_set_material(0, load("res://GraphWorld.tres"))
	
func setSize(newSize):
	size = newSize
	updateMesh()
	
func setPos(newPos):
	pos = newPos
	translation.y = -getHeight()
	updateMesh()
	
func getHeight():
	return f(pos.x, pos.z)
	
func drawVectors(ver: PoolVector3Array, vec: PoolVector3Array):
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var verts = PoolVector3Array()
	
	for i in range(ver.size()):
		verts.push_back(ver[i])
		verts.push_back(ver[i] + vec[i])
		
	arr[Mesh.ARRAY_VERTEX] = verts
	
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arr)
	
	debug.mesh = arr_mesh
	
	
func slope(x, z):
	var precision = 0.01
	var dx = Vector3(precision, f(x + precision/2, z) - f(x - precision/2, z), 0)
	var dz = Vector3(0, f(x, z + precision/2) - f(x, z - precision/2), precision)
	
	return dz.cross(dx).normalized()
	
	
func updateMesh():
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(i)
		v.y = f(v.x + pos.x,v.z + pos.z)
		mdt.set_vertex(i, v)
	
	if mesh.get_surface_count() > 0:
		mesh.surface_remove(0)
		mdt.commit_to_surface(mesh)
		mesh.surface_set_material(0, load("res://GraphWorld.tres"))
