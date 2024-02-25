
local part_buffer = {
	replace = "",
	by = {}
}

local function push_part_buffer(name)
	if part_buffer.replace == "" then
		part_buffer.replace = name
	else
		table.insert(part_buffer.by, name)
	end
end

local function pop_part_buffer()
	local parts = table.copy(part_buffer)
	part_buffer = {
		replace = "",
		by = {}
	}
	return parts
end

local function register_part(name, def)
	def.groups = def.groups or { oddly_breakable_by_hand = 3 }
	minetest.register_node(":brickbuild:"..name, def)

	push_part_buffer(name)
end

colours = {
	{1,   "F4F4F4", "White"},
	{5,   "CCB98D", "Tan"},
	{18,  "BB805A", "Nougat"},
	{21,  "B40000", "Red"},
	{23,  "1E5AA8", "Blue"},
	{24,  "FAC80A", "Yellow"},
	{26,  "0A0A0A", "Black"},
	{28,  "00852B", "Green"},
	{37,  "58AB41", "Bright Green"},
	{38,  "91501C", "Dark Orange"},
	{102, "7396C8", "Medium Blue"},
	{106, "D67923", "Medium Orange"},
	{107, "069D9F", "Dark Turquoise"},
	{119, "A5CA18", "Lime"},
	{124, "901F76", "Magenta"},
	{135, "70819A", "Sand Blue"},
	{138, "897D62", "Dark Tan"},
	{140, "19325A", "Dark Blue"},
	{141, "00451A", "Dark Green"},
	{151, "708E7C", "Sand Green"},
	{154, "720012", "Dark Red"},
	{191, "FCAC00", "Bright Light Orange"},
	{192, "5F3109", "Reddish Brown"},
	{194, "969696", "Medium Stone Grey"},
	{199, "646464", "Dark Stone Grey"},
	{212, "9DC3F7", "Bright Light Blue"},
	{221, "C8509B", "Dark Pink"},
	{222, "FF9ECD", "Bright Pink"},
	{226, "FFEC6C", "Bright Light Yellow"},
	{268, "441A91", "Dark Purple"},
	{283, "E1BEA1", "Light Nougat"},
	{308, "352100", "Dark Brown"},
	{312, "AA7D55", "Medium Nougat"},
	{321, "469BC3", "Dark Azur"},
	{322, "68C3E2", "Medium Azur"},
	{323, "D3F2EA", "Aqua"},
	{324, "A06EB9", "Medium Lavender"},
	{325, "CDA4DE", "Lavender"},
	{326, "E2F99A", "Yellowish Green"},
	{330, "8B844F", "Olive Green"},
	{353, "FD5F84", "Coral"},
	{368, "F5F500", "Neon Yellow"},
	{370, "755945", "Medium Brown"},
	{371, "CCA373", "Medium Tan"},
}

for _, clr in pairs(colours) do
	colour = clr[2]
	id = clr[3]:lower():gsub(' ', '_')
	name = clr[3]

	register_part(id, {
		description = name..' Part',
		tiles = {
			"brickbuild_outset.png^[multiply:#"..colour,
			"brickbuild_inset.png^[multiply:#"..colour,
			"brickbuild_smooth.png^[multiply:#"..colour
		},
		is_ground_content = true,
	})

	register_part(id..'_smooth', {
		description = name..' Part (Smooth)',
		tiles = {"brickbuild_smooth.png^[multiply:#"..colour},
		is_ground_content = true
	})

	register_part(id..'_half', {
		description = name..' Part (Half)',
		tiles = {
			"brickbuild_outset.png^[multiply:#"..colour,
			"brickbuild_inset.png^[multiply:#"..colour,
			"brickbuild_smooth.png^[multiply:#"..colour
		},
		is_ground_content = true,
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox1
			}
		},
	})

	register_part(id..'_half_smooth', {
		description = name..' Part (Half) (Smooth)',
		tiles = {
			"brickbuild_smooth.png^[multiply:#"..colour
		},
		is_ground_content = true,
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox1
			}
		},
	})

	register_part(id..'_trans', {
		description = name..' Part (Transparent)',
		tiles = {
			"brickbuild_smooth.png^[multiply:#"..colour.."^[opacity:127"
		},
		inventory_image = "brickbuild_transparent.png^[multiply:#"..colour,
		wield_image = "brickbuild_transparent.png^[multiply:#"..colour,
		is_ground_content = true,
		drawtype = "glasslike",
		use_texture_alpha = "blend",
		sunlight_propagates = true,
		paramtype = "light",
	})

	register_part(id..'_neon', {
		description = name..' Part (Neon)',
		tiles = {"brickbuild_smooth.png^[colorize:#"..colour..":255"},
		light_source = 14,
		is_ground_content = true
	})

	register_part(id..'_wedge', {
		description = name..' Part (Wedge)',
		tiles = {"brickbuild_smooth.png^[multiply:#"..colour},
		is_ground_content = true,
		drawtype = "mesh",
		paramtype = "light",
		paramtype2 = "facedir",
		mesh = "brickbuild_wedge.obj",
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5,  -0.5,  -0.5, 0.5, -0.25, 0.5},
				{-0.5, -0.25, -0.25, 0.5,     0, 0.5},
				{-0.5,     0,     0, 0.5,  0.25, 0.5},
				{-0.5,  0.25,  0.25, 0.5,   0.5, 0.5}
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5,  -0.5,  -0.5, 0.5, -0.25, 0.5},
				{-0.5, -0.25, -0.25, 0.5,     0, 0.5},
				{-0.5,     0,     0, 0.5,  0.25, 0.5},
				{-0.5,  0.25,  0.25, 0.5,   0.5, 0.5}
			}
		}
	})

	i3.compress('brickbuild:'..id, pop_part_buffer())

	--[[
		{
		replace = id,
		by = {id..'_half', id..'_trans', id..'_smooth', id..'_neon', id..'_wedge'}
	}
	]]
end

minetest.register_node('brickbuild:invisible_light', {
	description = 'Invisible Light\n'
				..minetest.colorize("#ff8888", "Indestructible, to remove you need to place a part in the place of it."),
	inventory_image = "brickbuild_invisible_light.png",
	wield_image = "brickbuild_invisible_light.png",
	groups = { not_in_creative_inventory = 1 },
	drawtype = "airlike",
	sunlight_propagates = true,
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true
})

for _,variant in ipairs{"a","b","c","d"} do
	minetest.register_node('brickbuild:glass_'..variant, {
		description = "Glass (Variant "..variant..")",
		drawtype = "glasslike_framed_optional",
		tiles = { "brickbuild_glass_frame.png", "brickbuild_glass_tint.png" },
		groups = { oddly_breakable_by_hand = 3 },
		paramtype = "light",
		sunlight_propagates = true,
	})

	push_part_buffer('brickbuild:glass_'..variant)
end

i3.compress('brickbuild:glass_a', pop_part_buffer())
