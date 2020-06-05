
skycraft.ranks = {
	player = {
        privs = {"interact", "shout", "skycraft"},
        color = "#FFFFFF",
        tag = "",
    },
    vip = {
		color = "#4FFF00",
		tag = "[VIP]",
	},
    mvp = {
		color = "#00B6B3",
		tag = "[MVP]",
	},
	creative = {
		privs = {"creative", "fly", "fast"},
		color = "#FF9C00",
		tag = "[CREATIVE]",
	},
	mod = {
		privs = {"kick", "ban", "noclip", "settime", "give", "teleport", "bring", "protection_bypass", "worldedit"},
		color = "#006BFF",
		tag = "[MOD]",
	},
	dev = {
		privs = {"server", "privs"},
		color = "#9D00FF",
		tag = "[DEV]",
	},
	admin = {
		color = "#FF001C",
		tag = "[ADMIN]",
	},
	owner = {
		color = "#D90059",
		tag = "[OWNER]",
	},
}


function skycraft.get_rank(name)
	local player = minetest.get_player_by_name(name)
	if not player then return end
	local rank = player:get_meta():get_string("rank")
	if rank == "" then rank = "player" end
    return skycraft.ranks[rank]
end

function skycraft.get_player_name(name, brackets)
    local rank = skycraft.get_rank(name)
    local rank_tag = minetest.colorize(rank.color, rank.tag)
	if not brackets then 
		brackets = {"",""}
	end
	return rank_tag .. brackets[1] .. name .. brackets[2]
end

function skycraft.update_nametag(player)
	player:set_nametag_attributes({color = skycraft.get_rank(player:get_player_name()).color})
end

minetest.register_on_leaveplayer(function(player)
    minetest.chat_send_all(skycraft.get_player_name(player:get_player_name()) .. " left the Server")
    skycraft.update_nametag(player)
end)

minetest.register_on_chat_message(function(name, message)
    minetest.chat_send_all(skycraft.get_player_name(name, {"<", ">"}) .. " " .. message)
    return true
end)

minetest.register_chatcommand("rank", {
	params = "<player> <rank>",
	description = "Set a player's rank (owner|admin|dev|mod|creative|mvp|vip|player)",
	privs = {privs = true},
	func = function(name, param)
		local target = param:split(" ")[1] or ""
		local target_ref = minetest.get_player_by_name(name)
		local rank = param:split(" ")[2] or ""
		local rank_ref = skycraft.ranks[rank]
		if not rank_ref then 
			return false, "Invalid Rank '" .. rank .. "'."
		elseif not target_ref then
			return false, "Player '" .. target .. "' is not online."
        else
			local privs = {}
			for k, v in pairs(skycraft.ranks) do
				for _, priv in pairs(v.privs or {}) do
					privs[priv] = true
				end
				if k == rank then
					break
				end
			end
			target_ref:get_meta():set_string("rank", rank)
			minetest.set_player_privs(target, privs)
			skycraft.update_nametag(target_ref)
			return true, "The rank of '" .. target .. "' has been updated to '" .. rank .. "'." 
		end
	end,
})