unused_args = false
allow_defined_top = true
max_line_length = false
redefined = false

read_globals = {
	"dump",
	"vector",
	"VoxelManip", "VoxelArea",
	"ItemStack",
	"Settings",
	"unpack",
	-- Silence errors about custom table methods.
	table = { fields = { "copy", "indexof" } },
	-- Silence warnings about accessing undefined fields of global 'math'
	math = { fields = { "sign" } },
	"string",

	"include"
}

globals = {
	"minetest"
}
