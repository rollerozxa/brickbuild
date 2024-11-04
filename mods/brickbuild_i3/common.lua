
local old_is_creative_enabled = core.is_creative_enabled

function core.is_creative_enabled(name)
	if name == "" then
		return old_is_creative_enabled(name)
	end

	return core.check_player_privs(name, {creative = true}) or old_is_creative_enabled(name)
end

local function search(data)
	data.alt_items = nil
	data.expand = ""

	local filtered_list, c = {}, 0

	for i = 1, #data.items_raw do
		local item = data.items_raw[i]
		local def = core.registered_items[item]
		local desc = string.lower(core.get_translated_string(data.lang_code, def and def.description)) or ""
		local search_in = string.format("%s", desc)
		local to_add

		local ok = true

		for keyword in string.gmatch(data.filter, "%S+") do
			if not string.find(search_in, keyword, 1, true) then
				ok = nil
				break
			end
		end

		if ok then
			to_add = true
		end

		if to_add then
			c = c + 1
			filtered_list[c] = item
		end
	end

	data.items = filtered_list
end

local function valid_item(def)
	return def and def.groups.not_in_creative_inventory ~= 1 and
		def.description and def.description ~= ""
end

local function compression_active(data)
	return not next(i3.recipe_filters) and data.filter == ""
end

local function compressible(item, data)
	return compression_active(data) and i3.compress_groups[item]
end

local function sort_by_category(data)
	data.alt_items = nil
	data.expand = ""
	local items = data.items_raw

	if data.filter ~= "" then
		search(data)
		items = data.items
	end

	local new = {}

	for i = 1, #items do
		local item = items[i]
		local to_add = true

		if data.itab == 2 then
			to_add = core.registered_nodes[item]
		elseif data.itab == 3 then
			to_add = core.registered_craftitems[item] or core.registered_tools[item]
		end

		if to_add then
			table.insert(new, item)
		end
	end

	data.items = new
end

local function reset_data(data)
	data.filter        = ""
	data.expand        = ""
	data.pagenum       = 1
	data.query_item    = nil
	data.recipes       = nil
	data.usages        = nil
	data.alt_items     = nil
	data.items         = data.items_raw

	if data.itab > 1 then
		sort_by_category(data)
	end
end

local _ = {
	-- Compression
	compressible = compressible,
	compression_active = compression_active,

	-- Sorting
	search = search,
	sort_by_category = sort_by_category,

	-- Misc. functions
	valid_item = valid_item,
	reset_data = reset_data,
}

function i3.get(...)
	local t = {}

	for i, var in ipairs{...} do
		t[i] = _[var]
	end

	return unpack(t)
end
