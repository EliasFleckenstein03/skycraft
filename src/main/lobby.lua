skycraft.lobby_pos = {x = 0, y = 10000, z = 0}

function skycraft.join_lobby(name)
	local player = minetest.get_player_by_name(name)
	if not player then return false, "You have to be online to use this command" end
	minetest.chat_send_all(skycraft.get_player_name(name) .. " joined the Lobby")
	local pos = player:get_pos()
	if pos.y < 5000 and (pos.y > 1000 or pos.y < -100) then player:get_meta():set_string("skycraft:skyblock_pos", minetest.pos_to_string(pos)) end
	player:set_pos(skycraft.lobby_pos)
end

function skycraft.join_skyblock(name)
	local player = minetest.get_player_by_name(name)
	if not player then return false, "You have to be online to use this command" end
	local old_pos = player:get_pos()
	if old_pos.y < 5000 then return false, "You are already on the Skyblock map." end
	minetest.chat_send_all(skycraft.get_player_name(name) .. " joined Skyblock")
	local pos = minetest.string_to_pos(player:get_meta():get_string("skycraft:skyblock_pos"))
	if pos then
		player:set_pos(pos)
	else
		skycraft.spawn_player(player)
	end
end

minetest.register_chatcommand("lobby", {
	description = "Warp to the Lobby",
	func = skycraft.join_lobby
})

minetest.register_chatcommand("skyblock", {
	description = "Join Skyblock",
	func = skycraft.join_skyblock
})

minetest.register_chatcommand("shop", {
	description = "Join Skyblock",
	func = function(name)
		skycraft.join_lobby(name)
		local player = minetest.get_player_by_name(name)
		if player then 
			player:set_pos({x = 25, y = 10000, z = 25})
		end
	end
})

minetest.register_on_joinplayer(function(player)
	minetest.after(0.5, skycraft.join_lobby, player:get_player_name())
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if player:get_pos().y > 5000 then
		minetest.chat_send_player(hitter:get_player_name(), minetest.colorize("#FF6737", "Hey! Sorry, you can't PvP here!"))
		return true
	end
end)

minetest.register_on_player_hpchange(function(player, hp_change)
	return (player:get_pos().y > 5000) and 0 or hp_change
end, true)

minetest.register_globalstep(function()
	local players = minetest.get_connected_players()
	for _, player in pairs(players) do
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		local pos = player:get_pos()
		privs.skycraft = (pos.y < 5000 or privs.protection_bypass) and true or nil
		minetest.set_player_privs(name, privs)
    end
end)
