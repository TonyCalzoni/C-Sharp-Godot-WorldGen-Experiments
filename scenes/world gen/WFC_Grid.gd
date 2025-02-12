class_name WFC_Grid extends TileMap

# Constants
const directions: Array = [
	Vector2i(0, -1), # North
	Vector2i(0, 1), # South
	Vector2i(1, 0), # East
	Vector2i(-1, 0) # West
]
#const water_string: String = "water"
#const sand_string: String = "sand"
#const grass_string: String = "grass"
#const snow_string: String = "sand"

# Variables

@export var grid_size: Vector2i = Vector2i(150,80)

var all_possible_types: Array[String] = ["grass", "sand", "water"]

# Adjacency rules
#// Define the adjacency rules
		#Dictionary<string, List<string>> adjacencyRules = new Dictionary<string, List<string>>
		#{
			#{"water", new List<string> {"water", "sand"}}, // Water can only be next to sand or water
			#{"sand", new List<string> {"sand", "water", "grass"}}, // Sand can be next to sand, water, or grass
			#{"grass", new List<string> {"grass", "sand"}}, // Grass can only be next to grass or sand
			#{"snow", new List<string> {"snow", "grass"}}, // Snow can only be next to grass
		#};
var adjacency_rules: Dictionary = {
	"water" = ["water", "sand"],
	"sand" = ["water", "sand", "grass"],
	"grass" = ["grass", "sand"],
	"snow" = ["snow", "grass"]
}



	#private Dictionary<string, Vector2I> typeToTileCoords = new Dictionary<string, Vector2I>
	#{
		#{"grass", new Vector2I(2, 2)},
		#{"water", new Vector2I(3, 1)},
		#{"sand", new Vector2I(1, 3)},
		#{"snow", new Vector2I(0, 0)},
	#};
var type_to_tile_coords: Dictionary = {
	"grass" = Vector2i(2, 2),
	"water" = Vector2i(3, 1),
	"sand" = Vector2i(1, 3),
	"snow" = Vector2i.ZERO
	}

	#private Dictionary<string, Vector2I> typeOfTreeTiles = new Dictionary<string, Vector2I>
	#{
		#{"snowy_tree", new Vector2I(2, 3)}
	#};
var type_of_tree_tiles: Dictionary = {
	"snowy_tree" = Vector2i(2, 3)
	}

	#private WFC_Cell[,] grid;
var grid: Array[Array]

	#private Random random = new Random();
var random: RandomNumberGenerator

var noise_map: WFC_Noise_Map

	#// Called when the node enters the scene tree for the first time.
	#public override void _Ready()
	#{
		#noiseMap = new Noise_Map();
		#GenerateWorld();
	#}
func _ready() -> void:
	RandomNumberGenerator.new()
	noise_map = WFC_Noise_Map.new()
	generate_world()


	#private void GenerateWorld()
	#{
		#// InitializeNoise();
		#InitializeGrid();
		#PerformWaveFunctionCollapse();
		#OutputToTileMap();
	#}
func generate_world() -> void:
	# Init Grid
	initialize_grid()
	# Perform WFC
	perform_wfc()
	# Output to TM
	output_to_tilemap()


	#private void InitializeGrid()
	#{
		#grid = new WFC_Cell[(int)gridSize.X, (int)gridSize.Y];
		#for (int x = 0; x < gridSize.X; x++)
		#{
			#for (int y = 0; y < gridSize.Y; y++)
			#{
				#float oceanAlt = noiseMap.GetOceanAltitude(x, y);//oceanAltitude.GetNoise2D(x, y);
				#float moist = noiseMap.GetMoisture(x, y);//moisture.GetNoise2D(x, y);
				#float temp = noiseMap.GetTemperature(x, y);//temperature.GetNoise2D(x, y);
				#float objectClump = noiseMap.GetObjectClumps(x, y);//for now, to be used to generate forests
#
				#List<string> possibleTypes = GetInitialPossibleTypes(oceanAlt, moist, temp, objectClump);
				#grid[x, y] = new WFC_Cell(possibleTypes, new Vector2I(x, y));
			#}
		#}
	#}
func initialize_grid() -> void:
	# We have to do this weird because Godot doesn't have built-in multidimensional arrays
	var x_arr: Array[Array] = [] # Declare our x_array, which will be an array of array
	x_arr.resize(grid_size.x) # Set the max size
	var y_arr: Array = [] # Do the same for our y_array, which will hold the actual cells
	y_arr.resize(grid_size.y)
	for i_x in x_arr.size():
		# Work in loop, need to fill the y_array with new cells now
		for i_y in y_arr.size():
			var ocean_alt: float = noise_map.get_ocean_altitude(i_x, i_y)
			var moist: float = noise_map.get_moisture(i_x, i_y)
			var temp: float = noise_map.get_temperature(i_x, i_y)
			var object_clump: float = noise_map.get_object_clumps(i_x, i_y)
			var possible_types: Array[String] = get_initial_possible_types(ocean_alt, moist, temp, object_clump)
			y_arr[i_y] = WFC_Cell.new(possible_types, Vector2i(i_x, i_y))
		# Now that that chunk of y_array is done, add it to the x_array
		x_arr[i_x] = y_arr
	
	grid = x_arr


	#//look at setting down tiles based on noise levels
	#private List<string> GetInitialPossibleTypes(float oceanAlt, float moist, float temp, float objectClump)
	#{
		#// oceans
		#if (oceanAlt < 0) return new List<string> { "water" };
		#// beach between oceans / lakes and other biomes
		#else if (oceanAlt < 0.3) return new List<string> { "sand" };
		#else{
			#// frozen biome
			#string currentBiome = getBiome(moist, temp);
#
			#if(currentBiome == "snow"){
#
				#return new List<string> { "snow" };
			#}
			#else return new List<string> { "grass" };
		#}
	#}
func get_initial_possible_types(ocean_alt: float, moist: float, temp: float, _object_clump: float) -> Array[String]:
	if ocean_alt < 0:
		return ["water"]
	elif ocean_alt < 0.3:
		return ["sand"]
	else:
		var current_biome: String = get_biome(moist, temp)
		if current_biome == "snow":
			return ["snow"]
		else:
			return ["grass"]


	#private string getBiome(float moist, float temp)
	#{
		#string currentBiome = "";
#
		#// frozen biome
		#if(moist < 0 && temp < 0){
			#currentBiome = "snow";
		#}
		#else currentBiome = "grass";
#
		#return currentBiome;
	#}
func get_biome(moist: float, temp: float) -> String:
	var current_biome: String = ""
	
	if ((moist < 0) and (temp < 0)):
		current_biome = "snow"
	else:
		current_biome = "grass"
	
	return current_biome


	#private WFC_Cell SelectCellWithLeastEntropy()
	#{
		#int minEntropy = int.MaxValue;
		#List<WFC_Cell> cellsWithLeastEntropy = new List<WFC_Cell>();
#
		#for (int x = 0; x < gridSize.X; x++)
		#{
			#for (int y = 0; y < gridSize.Y; y++)
			#{
				#WFC_Cell cell = grid[x, y];
				#if (!cell.IsCollapsed)
				#{
					#int entropy = cell.PossibleTypes.Count;
					#if (entropy < minEntropy)
					#{
						#minEntropy = entropy;
						#cellsWithLeastEntropy.Clear();
						#cellsWithLeastEntropy.Add(cell);
					#}
					#else if (entropy == minEntropy)
					#{
						#cellsWithLeastEntropy.Add(cell);
					#}
				#}
			#}
		#}
		#if (cellsWithLeastEntropy.Count == 0) return null; // All cells are collapsed
		#int randomIndex = random.Next(cellsWithLeastEntropy.Count);
		#return cellsWithLeastEntropy[randomIndex];
	#}
func select_cell_with_least_entropy() -> WFC_Cell:
	var min_entropy: int = 9223372036854775807 # Max value
	var cells_with_least_entropy: Array[WFC_Cell] = []
	
	for i_x in grid_size.x:
		for i_y in grid_size.y:
			var cell: WFC_Cell = grid[i_x][i_y]
			if ! cell.is_collapsed:
				var entropy: int = cell.possible_types.size()
				if entropy < min_entropy:
					min_entropy = entropy
					cells_with_least_entropy.clear()
					cells_with_least_entropy.append(cell)
				elif entropy == min_entropy:
					cells_with_least_entropy.append(cell)
	if cells_with_least_entropy.size() == 0:
		return null
	return cells_with_least_entropy.pick_random()


	#private void CollapseCell(WFC_Cell cell)
	#{
		#int randomIndex = random.Next(cell.PossibleTypes.Count);
		#string chosenType = cell.PossibleTypes[randomIndex];
		#cell.PossibleTypes = new List<string> { chosenType };
		#cell.IsCollapsed = true;
	#}
func collapse_cell(cell: WFC_Cell) -> void:
	#var random_index: int = random.randi_range(0, cell.possible_types.size())
	var chosen_type: String = cell.possible_types.pick_random()
	cell.possible_types = [chosen_type]
	cell.is_collapsed = true


	#private bool PropagateConstraints(WFC_Cell cell)
	#{
		#// Define the adjacency rules
		#Dictionary<string, List<string>> adjacencyRules = new Dictionary<string, List<string>>
		#{
			#{"water", new List<string> {"water", "sand"}}, // Water can only be next to sand or water
			#{"sand", new List<string> {"sand", "water", "grass"}}, // Sand can be next to sand, water, or grass
			#{"grass", new List<string> {"grass", "sand"}}, // Grass can only be next to grass or sand
			#{"snow", new List<string> {"snow", "grass"}}, // Snow can only be next to grass
		#};
		#var neighbors = GetNeighbors(cell.Position);
		#foreach (var neighbor in neighbors)
		#{
			#if (!neighbor.IsCollapsed)
			#{
				#var allowedNeighborTypes = adjacencyRules[cell.PossibleTypes[0]];
				#var newPossibleTypes = neighbor.PossibleTypes.Intersect(allowedNeighborTypes).ToList();
				#if (newPossibleTypes.Count == 0)
				#{
					#return false; // Contradiction found
				#}
				#neighbor.PossibleTypes = newPossibleTypes;
			#}
		#}
		#return true; // No contradiction found
	#}
func propagate_constraints(cell: WFC_Cell) -> bool:
	var neighbors: Array[WFC_Cell] = get_neighbors(cell)
	for neighbor_cell in neighbors:
		if !neighbor_cell.is_collapsed:
			var allowed_neighbor_types: Array[String] = adjacency_rules[cell.possible_types.front()] # orig [0]
			var new_possible_types: Array[String] # Intersection array, now we have to populate it
			for i in neighbor_cell.possible_types:
				if allowed_neighbor_types.has(i):
					new_possible_types.append(i)
			if new_possible_types.size() == 0:
				return false
			neighbor_cell.possible_types = new_possible_types
	return true


	#private List<WFC_Cell> GetNeighbors(Vector2I position)
	#{
		#List<WFC_Cell> neighbors = new List<WFC_Cell>();
		#var directions = new List<Vector2I>
		#{
			#new Vector2I(0, -1), // North
			#new Vector2I(1, 0),  // East
			#new Vector2I(0, 1),  // South
			#new Vector2I(-1, 0)  // West
		#};
#
		#foreach (var direction in directions)
		#{
			#Vector2I neighborPos = position + direction;
			#if (IsValidPosition(neighborPos))
			#{
				#neighbors.Add(grid[(int)neighborPos.X, (int)neighborPos.Y]);
			#}
		#}
#
		#return neighbors;
	#}
func get_neighbors(cell: WFC_Cell) -> Array[WFC_Cell]:
	var neighbors: Array[WFC_Cell]
	for dir in directions:
		var neighbor_pos: Vector2i = cell.position + directions[dir]
		if is_valid_position(neighbor_pos):
			neighbors.append(neighbor_pos)
	
	return neighbors


	#private bool IsValidPosition(Vector2I position)
	#{
		#return position.X >= 0 && position.X < gridSize.X && position.Y >= 0 && position.Y < gridSize.Y;
	#}
func is_valid_position(_position: Vector2i) -> bool:
	return _position.x >= 0 && _position.x < grid_size.x && _position.y >= 0 && _position.y < grid_size.y


	#private bool PerformWaveFunctionCollapse()
	#{
		#while (true)
		#{
			#WFC_Cell cell = SelectCellWithLeastEntropy();
			#if (cell == null) return true; // All cells are collapsed
#
			#CollapseCell(cell);
			#PropagateConstraints(cell);
		#}
	#}
func perform_wfc() -> bool:
	while(true):
		var cell: WFC_Cell = select_cell_with_least_entropy()
		if cell == null:
			return true
		else:
			collapse_cell(cell)
			propagate_constraints(cell)
		
	# This isn't needed but the compiler wants it here so that all paths return a value
	return false


	#private void OutputToTileMap()
	#{
		#for (int x = 0; x < gridSize.X; x++)
		#{
			#for (int y = 0; y < gridSize.Y; y++)
			#{
				#WFC_Cell cell = grid[x, y];
				#if (cell.IsCollapsed && cell.PossibleTypes.Count > 0)
				#{
					#string tileType = cell.PossibleTypes[0];
					#if (typeToTileCoords.TryGetValue(tileType, out Vector2I tileCoords))
					#{
						#Vector2I cellCoord = new Vector2I(x, y);
						#SetCell(0, cellCoord, 0, tileCoords);
#
						#//with this code, the trees will 100% show up on each snow tile; use the noiseMap objectClumps noise to create more natural (hopefully) forests
						#if(tileType == "snow" && noiseMap.GetObjectClumps(x, y) < -0.5)
						#{
							#SetCell(1, cellCoord, 1, typeOfTreeTiles["snowy_tree"]);
						#}
					#}
				#}
			#}
		#}
	#}
func output_to_tilemap() -> void: # TODO
	for i_x in grid_size.x:
		for i_y in grid_size.y:
			var cell: WFC_Cell = grid[i_x][i_y]
			if cell.is_collapsed and cell.possible_types.size() > 0:
				var tile_type: String = cell.possible_types.front() # orig [0]
				var tile_coords: Vector2i = type_to_tile_coords[tile_type]
				var cell_coord: Vector2i = Vector2i(i_x, i_y)
				set_cell(0, cell_coord, 0, tile_coords)
				
				if tile_type == "snow" and noise_map.get_object_clumps(i_x, i_y) < -0.5:
					set_cell(1, cell_coord, 1, type_of_tree_tiles["snowy_tree"])
