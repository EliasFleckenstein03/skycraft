skycraft.register_request_system("tpa", "teleport", "teleporting", "to", function(target, name)
	local player = minetest.get_player_by_name(name)
	local pos = player:get_pos()
	local target_pos = minetest.get_player_by_name(target):get_pos()
	minetest.sound_play("whoosh", {pos = pos, gain = 0.5, max_hear_distance = 10})
	minetest.sound_play("whoosh", {pos = target_pos, gain = 0.5, max_hear_distance = 10})
	player:set_pos(skycraft.find_free_position_near(target_pos))
end)
