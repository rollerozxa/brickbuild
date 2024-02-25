
local reset_data = i3.get("reset_data")
local search, sort_by_category = i3.get("search", "sort_by_category")
local valid_item, compressible = i3.get("valid_item", "compressible")

local function clean_name(item)
	if string.sub(item, 1, 1) == ":" or string.sub(item, 1, 1) == " " or string.sub(item, 1, 1) == "_" then
		item = string.sub(item, 2)
	end

	return item
end

local function select_item(player, data, fields)
	local item

	for field in pairs(fields) do
		if string.find(field, ":") then
			item = field
			break
		end
	end

	if not item then return end

	if compressible(item, data) then
		local idx

		for i = 1, #data.items do
			local it = data.items[i]
			if it == item then
				idx = i
				break
			end
		end

		if data.expand ~= "" then
			data.alt_items = nil

			if item == data.expand then
				data.expand = nil
				return
			end
		end

		if idx and item ~= data.expand then
			data.alt_items = table.copy(data.items)
			data.expand = item

			if i3.compress_groups[item] then
				local items = table.copy(i3.compress_groups[item])
				table.insert(items, string.format("_%s", item))

				table.sort(items, function(a, b)
					if a:sub(1, 1) == "_" then
						a = a:sub(2)
					end

					return a < b
				end)

				local i = 1

				for _, v in ipairs(items) do
					if valid_item(minetest.registered_items[clean_name(v)]) then
						table.insert(data.alt_items, idx + i, v)
						i = i + 1
					end
				end
			end
		end
	else
		if string.sub(item, 1, 1) == "_" then
			item = string.sub(item, 2)
		elseif string.sub(item, 1, 6) == "group!" then
			item = string.match(item, "([%w:_]+)$")
		end

		item = minetest.registered_aliases[item] or item
		if not minetest.registered_items[item] then return end

		if minetest.is_creative_enabled(data.player_name) then
			local inv = player:get_inventory()
			if not inv:contains_item("main", item) then
				inv:add_item("main", item)
			end
		end
	end
end

local function rcp_fields(player, data, fields)
	if fields.cancel then
		reset_data(data)

	elseif fields.exit then
		data.query_item = nil

	elseif fields.key_enter_field == "filter" or fields.search then
		if fields.filter == "" then
			reset_data(data)
			return i3.set_fs(player)
		end

		local str = string.lower(fields.filter)
		if data.filter == str then return end

		data.filter = str
		data.pagenum = 1

		search(data)

		if data.itab > 1 then
			sort_by_category(data)
		end

	elseif fields.prev_page or fields.next_page then
		if data.pagemax == 1 then return end
		data.pagenum = data.pagenum - (fields.prev_page and 1 or -1)

		if data.pagenum > data.pagemax then
			data.pagenum = 1
		elseif data.pagenum == 0 then
			data.pagenum = data.pagemax
		end
	else
		select_item(player, data, fields)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" or fields.pagenum or fields.no_item then
		return false
	end

	local data = i3.data[player:get_player_name()]
	if not data then return end

	rcp_fields(player, data, fields)

	return true, i3.set_fs(player)
end)
