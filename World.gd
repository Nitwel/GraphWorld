extends Spatial
const Chunk = preload("res://Chunk.gd")

var chunks = {}
var last_chunk = Vector3(1,1,1)
export var max_chunk_radius = 10
export var chunk_radius = 10
export var chunk_size = 10
onready var player = $Player
onready var thread_pool = $"/root/ThreadPool"

var noise = OpenSimplexNoise.new()

func _process(delta):
	pass
	
func _ready():
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	thread_pool.discard_finished_tasks = false
	VisualServer.set_debug_generate_wireframes(true)
	generate_chunks()
	
func _input(event):
	generate_chunks()
	#pass
# f(x, y) = x

func f(x, y):
#	return x
#	return 1
	return 10 if noise.get_noise_2d(x/10, y/10) > 0 else 0
#	return noise.get_noise_2d(x/100,y/100) * 500 + noise.get_noise_2d(x/1000,y/1000) * 5000
#	return gcd(x,y)
	
func gcd(a: int, b: int) -> int:
	return a if b == 0.0 else gcd(b, a % b)
	
func get_chunk(pos: Vector3):
	var x = floor(pos.x / chunk_size)
	var y = floor(pos.y / chunk_size)
	var z = floor(pos.z / chunk_size)
	return Vector3(x, y, z)
	
func distance(x1, z1, x2, z2):
	return Vector2(x1, z1).distance_to(Vector2(x2, z2))

func generate_chunks():
	var player_chunk = get_chunk(player.translation)
	
	if player_chunk == last_chunk:
		return
	
	last_chunk = player_chunk
	
	var res_map = {}
	res_map[0] = 1
	for i in range(1, chunk_radius * 2 + 2):
		var last = res_map[i - 1]
		res_map[i] = max(gcd(i, chunk_size/10), last)
	
	for z in range(-chunk_radius + player_chunk.z, chunk_radius + 1 + player_chunk.z):
		for x in range(-chunk_radius + player_chunk.x, chunk_radius + 1 + player_chunk.x):
			
			if [x,z] in chunks:
				continue
				
			chunks[[x,z]] = null
			
			var chunk = Chunk.new(Vector3(x * chunk_size, 0, z * chunk_size), Vector3(chunk_size, chunk_size, chunk_size), funcref(self, 'f'))
			var dist = abs(distance(player_chunk.x, player_chunk.z, x, z))
#			if abs(distance(player_chunk.x, player_chunk.z, x, z))  >= 2:
#				chunk.scale = Vector3(2, 1, 2)
#				chunk.transform.origin = Vector3(x, 0, z)
#			else:
			#var res = res_map[int(dist)]
			#chunk.scale = Vector3(5, 1, 5)
#				chunk.transform.origin = Vector3(x, 0, z)
			
				
			add_child(chunk)
			chunks[[x,z]] = chunk	
	
	for chunk in chunks.keys():
		if abs(distance(player_chunk.x, player_chunk.z, chunk[0], chunk[1])) >= max_chunk_radius:
			var chunk_mesh = chunks[chunk]
			remove_child(chunk_mesh)
			chunks.erase(chunk)
		
