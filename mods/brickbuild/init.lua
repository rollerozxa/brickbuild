
minetest.register_alias('mapgen_stone', 'oblx_parts:red')
minetest.register_alias('mapgen_water_source', 'air')
minetest.register_alias('mapgen_river_water_source', 'air')

minetest.register_item(':', {
	type = 'none',
	wield_image = 'brickbuild_hand.png',
	wield_scale = {x = 0.5, y = 0.85, z = 4},
	range = 25,
	tool_capabilities = {
		max_drop_level = 0,
		groupcaps = {
			oddly_breakable_by_hand = {
				times = {[3] = 0},
				uses = 0,
			},
		}
	},
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.is_creative_enabled(placer:get_player_name()) then
			local pointed_node = minetest.get_node(pointed_thing.under)
			return pointed_node
		end
	end
})

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	-- Unlimited blocks in creative mode
	if placer and placer:is_player() then
		return minetest.is_creative_enabled(placer:get_player_name())
	end
end)

local old_handle_node_drops = minetest.handle_node_drops
function minetest.handle_node_drops(pos, drops, digger)
	if not digger or not digger:is_player() or
		not minetest.is_creative_enabled(digger:get_player_name()) then
		return old_handle_node_drops(pos, drops, digger)
	end
	local inv = digger:get_inventory()
	if inv then
		for _, item in ipairs(drops) do
			if not inv:contains_item("main", item, true) then
				inv:add_item("main", item)
			end
		end
	end
end

local function include(file)
	dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/"..file..".lua")
end
include('parts')
include('player')
include('player_api')

include('baseplate')
