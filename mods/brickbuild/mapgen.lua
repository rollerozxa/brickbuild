
minetest.register_alias("mapgen_stone", "brickbuild:dark_stone_grey")
minetest.register_alias("mapgen_water_source", "brickbuild:bright_light_blue_trans")
minetest.register_alias("mapgen_river_water_source", "brickbuild:bright_light_blue_trans")

local function register_biome(def)
	def.depth_top = def.depth_top or 1

	def.node_filler = def.node_filler or "brickbuild:reddish_brown"
	def.depth_filler = def.depth_filler or 3

	def.node_riverbed = def.node_riverbed or "brickbuild:medium_tan"
	def.depth_riverbed = def.depth_riverbed or 2

	def.y_max = def.y_max or 31000
	def.y_min = def.y_min or 4

	minetest.register_biome(def)
end

register_biome{
	name = "grasslands",
	node_top = "brickbuild:green",
	heat_point = 37.4,
	humidity_point = 34.5,
}

register_biome{
	name = "woodlands",
	node_top = "brickbuild:dark_green",
	heat_point = 82.7,
	humidity_point = 40.7,
}

register_biome{
	name = "flowerlands",
	node_top = "brickbuild:bright_green",
	heat_point = 49.8,
	humidity_point = 77.1,
}

register_biome{
	name = "beach",
	node_top = "brickbuild:medium_tan",
	node_filler = "brickbuild:medium_tan",
	y_max = 4,
	y_min = -2,
	heat_point = 50,
	humidity_point = 35,
}

register_biome{
	name = "sea",
	node_top = "brickbuild:medium_tan",
	depth_top = 1,
	node_filler = "brickbuild:medium_tan",
	depth_filler = 2,
	y_max = -2,
	y_min = -50,
	heat_point = 50,
	humidity_point = 35,
}

for id, name in pairs{
	red = "brickbuild:red",
	yellow = "brickbuild:yellow",
	blue = "brickbuild:blue",
	pink = "brickbuild:bright_pink",
	weeds = "brickbuild:dark_green"
} do
	minetest.register_decoration{
		deco_type = "simple",
		place_on = {"brickbuild:bright_green"},
		sidelen = 16,
		fill_ratio = 0.025,
		biomes = {"flowerlands"},
		y_max = 200,
		y_min = 1,
		decoration = name,
	}
end

-- Decorations

local function schem(name)
	return minetest.get_modpath("brickbuild").."/schematics/"..name..".mts"
end

minetest.register_decoration{
	name = "oblx_mapgen:tree_test",
	deco_type = "schematic",
	place_on = {"brickbuild:green"},
	sidelen = 16,
	fill_ratio = 0.0001,
	biomes = {"grasslands"},
	y_max = 31000,
	y_min = 1,
	schematic = schem("tree_test"),
	flags = "place_center_x, place_center_z",
	rotation = "random",
}

minetest.register_decoration{
	name = "oblx_mapgen:tree_test2",
	deco_type = "schematic",
	place_on = {"brickbuild:dark_green"},
	sidelen = 16,
	fill_ratio = 0.005,
	biomes = {"woodlands"},
	y_max = 31000,
	y_min = 1,
	schematic = schem("tree_test"),
	flags = "place_center_x, place_center_z",
	rotation = "random",
}
