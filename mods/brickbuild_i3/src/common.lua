local fmt = string.format

local old_is_creative_enabled = minetest.is_creative_enabled

function minetest.is_creative_enabled(name)
	if name == "" then
		return old_is_creative_enabled(name)
	end

	return minetest.check_player_privs(name, {creative = true}) or old_is_creative_enabled(name)
end

local function is_num(x)
	return type(x) == "number"
end

local function is_str(x)
	return type(x) == "string"
end

local function is_table(x)
	return type(x) == "table"
end

local function is_func(x)
	return type(x) == "function"
end

local function true_str(str)
	return is_str(str) and str ~= ""
end

local function true_table(x)
	return is_table(x) and next(x)
end

local function reset_compression(data)
	data.alt_items = nil
	data.expand = ""
end

local function msg(name, str)
	local prefix = "[i3]"
	return minetest.chat_send_player(name, fmt("%s %s", minetest.colorize("#ff0", prefix), str))
end

local function err(str)
	return minetest.log("error", str)
end

local function round(num, decimal)
	local mul = 10 ^ decimal
	return math.floor(num * mul + 0.5) / mul
end

local function search(data)
	reset_compression(data)

	local filter = data.filter
	local opt = "^(.-)%+([%w_]+)=([%w_,]+)"
	local search_filter = next(i3.search_filters) and string.match(filter, opt)
	local filters = {}

	if search_filter then
		search_filter = search_filter:trim()

		for filter_name, values in string.gmatch(filter, string.sub(opt, 6)) do
			if i3.search_filters[filter_name] then
				values = string.split(values, ",")
				filters[filter_name] = values
			end
		end
	end

	local filtered_list, c = {}, 0

	for i = 1, #data.items_raw do
		local item = data.items_raw[i]
		local def = minetest.registered_items[item]
		local desc = string.lower(minetest.get_translated_string(data.lang_code, def and def.description)) or ""
		local search_in = fmt("%s", desc)
		local temp, j, to_add = {}, 1

		if search_filter then
			for filter_name, values in pairs(filters) do
				if values then
					local func = i3.search_filters[filter_name]
					to_add = (j > 1 and temp[item] or j == 1) and
						func(item, values) and (search_filter == "" or
						string.find(search_in, search_filter, 1, true))

					if to_add then
						temp[item] = true
					end

					j = j + 1
				end
			end
		else
			local ok = true

			for keyword in string.gmatch(filter, "%S+") do
				if not string.find(search_in, keyword, 1, true) then
					ok = nil
					break
				end
			end

			if ok then
				to_add = true
			end
		end

		if to_add then
			c = c + 1
			filtered_list[c] = item
		end
	end

	data.items = filtered_list
end

local function clean_name(item)
	if string.sub(item, 1, 1) == ":" or string.sub(item, 1, 1) == " " or string.sub(item, 1, 1) == "_" then
		item = string.sub(item, 2)
	end

	return item
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
	reset_compression(data)
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
			to_add = minetest.registered_nodes[item]
		elseif data.itab == 3 then
			to_add = minetest.registered_craftitems[item] or minetest.registered_tools[item]
		end

		if to_add then
			table.insert(new, item)
		end
	end

	data.items = new
end

local function spawn_item(player, stack)
	local dir     = player:get_look_dir()
	local ppos    = player:get_pos()
	      ppos.y  = ppos.y + player:get_properties().eye_height
	local look_at = vector.add(ppos, vector.multiply(dir, 1))

	minetest.add_item(look_at, stack)
end

local function get_stack(player, stack)
	local inv = player:get_inventory()

	if inv:room_for_item("main", stack) then
		inv:add_item("main", stack)
	else
		spawn_item(player, stack)
	end
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

-- Much faster implementation of `unpack`
local function createunpack(n)
	local ret = {"local t = ... return "}

	for k = 2, n do
		ret[2 + (k - 2) * 4] = "t["
		ret[3 + (k - 2) * 4] = k - 1
		ret[4 + (k - 2) * 4] = "]"

		if k ~= n then
			ret[5 + (k - 2) * 4] = ","
		end
	end

	return loadstring(table.concat(ret))
end

local newunpack = createunpack(33)

-------------------------------------------------------------------------------

local _ = {
	-- Compression
	compressible = compressible,
	compression_active = compression_active,

	-- Sorting
	search = search,
	sort_by_category = sort_by_category,

	-- Type checks
	is_num = is_num,
	is_func = is_func,
	true_str = true_str,
	true_table = true_table,

	-- Console
	err = err,
	msg = msg,

	-- Misc. functions
	valid_item = valid_item,
	spawn_item = spawn_item,
	clean_name = clean_name,
	reset_data = reset_data,

	-- Inventory
	get_stack = get_stack,

	-- String
	fmt = string.format,
	upper = string.upper,

	-- Table
	unpack = newunpack,
	is_table = is_table,

	-- Math
	round = round,

}

function i3.get(...)
	local t = {}

	for i, var in ipairs{...} do
		t[i] = _[var]
	end

	return newunpack(t)
end
