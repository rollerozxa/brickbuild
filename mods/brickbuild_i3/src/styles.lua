local PNG = {
	blank = "blank.png",
	bg = "i3_bg.png",
	bg_full = "i3_bg_full.png",
	search = "i3_search.png",
	prev = "i3_next.png^\\[transformFX",
	next = "i3_next.png",
	trash = "i3_trash.png",
	cancel = "i3_cancel.png",
	slot = "i3_slot.png",
	tab = "i3_tab.png",
	tab_top = "i3_tab.png^\\[transformFY",

	cancel_hover = "i3_cancel.png^\\[brighten",
	search_hover = "i3_search.png^\\[brighten",
	trash_hover = "i3_trash.png^\\[brighten^\\[colorize:#f00:100",
	prev_hover = "i3_next_hover.png^\\[transformFX",
	next_hover = "i3_next_hover.png",
	tab_hover = "i3_tab_hover.png",
	tab_hover_top = "i3_tab_hover.png^\\[transformFY",
}

local styles = string.format([[
	style_type[field;border=false;bgcolor=transparent]
	style_type[label,field;font_size=16]
	style_type[button;border=false;content_offset=0]
	style_type[image_button,item_image_button,dropdown;border=false]
	style_type[item_image_button;bgimg_hovered=%s]

	style[pagenum,no_item;font=bold;font_size=18]
	style[cancel;fgimg=%s;fgimg_hovered=%s;content_offset=0]
	style[search;fgimg=%s;fgimg_hovered=%s;content_offset=0]
	style[prev_page;fgimg=%s;fgimg_hovered=%s]
	style[next_page;fgimg=%s;fgimg_hovered=%s]
]],
PNG.slot,
PNG.cancel, PNG.cancel_hover,
PNG.search, PNG.search_hover,
PNG.prev,   PNG.prev_hover,
PNG.next,   PNG.next_hover)

local fs_elements = {
	label = "label[%f,%f;%s]",
	box = "box[%f,%f;%f,%f;%s]",
	image = "image[%f,%f;%f,%f;%s]",
	tooltip = "tooltip[%f,%f;%f,%f;%s]",
	button = "button[%f,%f;%f,%f;%s;%s]",
	item_image = "item_image[%f,%f;%f,%f;%s]",
	bg9 = "background9[%f,%f;%f,%f;%s;false;%u]",
	model = "model[%f,%f;%f,%f;%s;%s;%s;%s;%s;%s;%s]",
	image_button = "image_button[%f,%f;%f,%f;%s;%s;%s]",
	item_image_button = "item_image_button[%f,%f;%f,%f;%s;%s;%s]",
}

local colors = {
	yellow = "#ffd866",
	black = "#2d2a2e",
	blue = "#7bf",
}

return PNG, styles, fs_elements, colors
