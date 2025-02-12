class_name WFC_Noise_Map extends Node

	#public FastNoiseLite OceanAltitude { get; private set; }
	#public FastNoiseLite Moisture { get; private set; }
	#public FastNoiseLite Temperature { get; private set; }
	#public FastNoiseLite ObjectClumps { get; private set; }


var OceanAltitude: FastNoiseLite:
	get:
		return OceanAltitude

var Moisture: FastNoiseLite:
	get:
		return Moisture

var Temperature: FastNoiseLite:
	get:
		return Temperature

var ObjectClumps: FastNoiseLite:
	get:
		return ObjectClumps

#region Constructor
func _init():
	_initialize_noise()
#endregion

#region Noise initialization and functions
	#//go through initialization process; choose noise types, seeds, etc.
	#private void InitializeNoise()
	#{
		#OceanAltitude = new FastNoiseLite();
		#OceanAltitude.Seed = 1337; //(int)DateTime.Now.Ticks;//rand number
		#OceanAltitude.Frequency = 0.033f;
		#OceanAltitude.NoiseType = FastNoiseLite.NoiseTypeEnum.Simplex;
		#OceanAltitude.FractalType = FastNoiseLite.FractalTypeEnum.None;
#
		#Moisture = new FastNoiseLite();
		#Moisture.Seed = (int)DateTime.Now.Ticks;//rand number
		#Moisture.Frequency = 0.033f;
		#Moisture.NoiseType = FastNoiseLite.NoiseTypeEnum.Simplex;
		#Moisture.FractalType = FastNoiseLite.FractalTypeEnum.None;
#
		#Temperature = new FastNoiseLite();
		#Temperature.Seed = (int)DateTime.Now.Ticks;//rand number
		#Temperature.Frequency = 0.033f;
		#Temperature.NoiseType = FastNoiseLite.NoiseTypeEnum.Simplex;
		#Temperature.FractalType = FastNoiseLite.FractalTypeEnum.None;
#
		#ObjectClumps = new FastNoiseLite();
		#ObjectClumps.Seed = (int)DateTime.Now.Ticks;//rand number
		#ObjectClumps.Frequency = 0.033f;
		#ObjectClumps.NoiseType = FastNoiseLite.NoiseTypeEnum.Simplex;
		#ObjectClumps.FractalType = FastNoiseLite.FractalTypeEnum.None;
	#}
func _initialize_noise() -> void:
	OceanAltitude = FastNoiseLite.new()
	OceanAltitude.seed = 1337
	OceanAltitude.frequency = float(0.033)
	OceanAltitude.noise_type = FastNoiseLite.TYPE_SIMPLEX
	OceanAltitude.fractal_type = FastNoiseLite.FRACTAL_NONE
	
	Moisture = FastNoiseLite.new()
	Moisture.seed = 1337
	Moisture.frequency = int(Time.get_ticks_msec())
	Moisture.noise_type = FastNoiseLite.TYPE_SIMPLEX
	Moisture.fractal_type = FastNoiseLite.FRACTAL_NONE
	
	Temperature = FastNoiseLite.new()
	Temperature.seed = 1337
	Temperature.frequency = int(Time.get_ticks_msec())
	Temperature.noise_type = FastNoiseLite.TYPE_SIMPLEX
	Temperature.fractal_type = FastNoiseLite.FRACTAL_NONE
	
	ObjectClumps = FastNoiseLite.new()
	ObjectClumps.seed = 1337
	ObjectClumps.frequency = int(Time.get_ticks_msec())
	ObjectClumps.noise_type = FastNoiseLite.TYPE_SIMPLEX
	ObjectClumps.fractal_type = FastNoiseLite.FRACTAL_NONE


	#// Additional methods to get noise values for specific coordinates
	#public float GetOceanAltitude(int x, int y) => OceanAltitude.GetNoise2D(x, y);
	#public float GetMoisture(int x, int y) => Moisture.GetNoise2D(x, y);
	#public float GetTemperature(int x, int y) => Temperature.GetNoise2D(x, y);
	#public float GetObjectClumps(int x, int y) => ObjectClumps.GetNoise2D(x, y);

func get_ocean_altitude(x: int, y: int) -> float:
	return OceanAltitude.get_noise_2d(x, y)

func get_moisture(x: int, y: int) -> float:
	return Moisture.get_noise_2d(x, y)

func get_temperature(x: int, y: int) -> float:
	return Temperature.get_noise_2d(x, y)

func get_object_clumps(x: int, y: int) -> float:
	return ObjectClumps.get_noise_2d(x, y)
#endregion
