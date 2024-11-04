
if core.get_mapgen_setting('mg_name') ~= "singlenode" then
	return
end

local c_base = core.get_content_id(core.settings:get('brickbuild_baseplate_part') or "brickbuild:green")
local size = tonumber(core.settings:get('brickbuild_baseplate_size')) or 256
local depth = tonumber(core.settings:get('brickbuild_baseplate_depth')) or 20

local data = {}

core.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = core.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	vm:get_data(data)

	local written = false

	for z = minp.z, maxp.z do
	for y = minp.y, maxp.y do
		local posi = area:index(minp.x, y, z)
		for x = minp.x, maxp.x do
			if (x >= -size and x <= size) and (z >= -size and z <= size) and (y >= -depth and y <= 0) then
				data[posi] = c_base
				written = true
			end
			posi = posi + 1
		end
	end
	end

	if written then
		vm:set_data(data)
		vm:write_to_map()
	end
end)
