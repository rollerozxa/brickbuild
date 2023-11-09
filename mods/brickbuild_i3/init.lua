
i3 = {
	data = {},

	-- Caches
	init_items = {},

	recipe_filters = {},

	compress_groups = {},
	compressed = {}
}

local function include(path)
	return dofile(minetest.get_modpath(minetest.get_current_modname()).."/"..path)
end

include("common.lua")

local make_fs = include("gui.lua")

include("fields.lua")

function i3.set_fs(player)
	if not player or player.is_fake_player then return end
	local name = player:get_player_name()
	local data = i3.data[name]
	if not data then return end

	local fs = make_fs(player, data)
	player:set_inventory_formspec(fs)
end

function i3.compress(item, def)
	local t = {}
	i3.compress_groups[item] = i3.compress_groups[item] or {}

	for _, str in ipairs(def.by) do
		local it = item:gsub(def.replace, str)

		table.insert(t, it)
		table.insert(i3.compress_groups[item], it)

		i3.compressed[it] = true
	end
end

local reset_data, valid_item = i3.get("reset_data", "valid_item")

minetest.register_on_priv_grant(function(name, _, priv)
	if priv == "creative" or priv == "all" then
		local data = i3.data[name]
		reset_data(data)

		local player = minetest.get_player_by_name(name)
		minetest.after(0, i3.set_fs, player)
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	i3.data[name] = i3.data[name] or {}
	local data = i3.data[name]

	local _preselect = {}
	local init_items = {}

	for name, def in pairs(minetest.registered_items) do
		if name ~= "" and valid_item(def) then
			_preselect[name] = true
		end
	end

	for name in pairs(_preselect) do
		table.insert(init_items, name)
	end

	table.sort(init_items)

	local info = minetest.get_player_information(name)

	data.player_name = name
	data.filter      = ""
	data.pagenum     = 1
	data.items       = init_items
	data.items_raw   = init_items
	data.itab        = 1
	data.lang_code   = info and info.lang_code

	minetest.after(0, i3.set_fs, player)
end)


