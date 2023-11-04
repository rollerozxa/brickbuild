local set_fs = i3.set_fs

local fmt = i3.get("fmt")
local reset_data = i3.get("reset_data")
local search, sort_by_category = i3.get("search", "sort_by_category")
local valid_item, get_stack, clean_name, compressible = i3.get("valid_item", "get_stack", "clean_name", "compressible")

local function inv_fields(player, data, fields)
	local sb_inv = fields.scrbar_inv

	if sb_inv and string.sub(sb_inv, 1, 3) == "CHG" then
		data.scrbar_inv = tonumber(string.match(sb_inv, "%d+"))
		return
	end

	return set_fs(player)
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
				table.insert(items, fmt("_%s", item))

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
			local stack = ItemStack(item)
			local stackmax = stack:get_stack_max()
			      stack = fmt("%s %s", item, stackmax)

			return get_stack(player, stack)
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
			return set_fs(player)
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
	local name = player:get_player_name()

	if formname == "i3_outdated" then
		return false, minetest.kick_player(name,
			"Come back when your Minetest client is up-to-date (www.minetest.net).")
	elseif formname ~= "" then
		return false
	end

	-- No-op buttons
	if fields.player_name or fields.pagenum or fields.no_item then
		return false
	end

	local data = i3.data[name]
	if not data then return end

	for f in pairs(fields) do
		if string.sub(f, 1, 4) == "tab_" then
			local tabname = string.sub(f, 5)
			i3.set_tab(player, tabname)
			break
		end
	end

	rcp_fields(player, data, fields)

	local tab = i3.tabs[data.tab]

	if tab and tab.fields then
		return true, tab.fields(player, data, fields)
	end

	return true, set_fs(player)
end)

return inv_fields
