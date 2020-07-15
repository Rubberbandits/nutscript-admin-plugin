local PLUGIN = PLUGIN
PLUGIN.name = "Admin"
PLUGIN.author = "rusty"
PLUGIN.desc = "Stop using paid admin mods, idiots."
-- i included this so messages presented to players via the server will be in the language of the server's choice.
PLUGIN.language = "english"

nut.admin = nut.admin or {}
nut.admin.commands = nut.admin.commands or {noclip = true}

nut.util.include("sh_permissions.lua")
nut.util.include("cl_permissions.lua")
nut.util.include("cl_plugin.lua")

nut.util.include("sh_commands.lua")

if SERVER then
	nut.util.include("sv_permissions.lua")
	nut.util.include("sv_bans.lua")
end

local PLUGIN = PLUGIN

-- in order to create groups that can noclip
-- oh this will also fix prediction errors, thanks chessnut.

function PLUGIN:PlayerNoClip(client, state)
	if (client:hasPermission("noclip")) then
		if SERVER then
		-- Check if they are entering noclip.
			if (state) then
				-- Store their old position and looking		 at angle.
				client.nutObsData = {client:GetPos(), client:EyeAngles()}
				-- Hide them so they are not visible.
				client:SetNoDraw(true)
				client:SetNotSolid(true)
				client:DrawWorldModel(false)
				client:DrawShadow(false)
				-- Don't allow the player to get hurt.
				client:GodEnable()
				-- Don't allow npcs to target the player.
				client:SetNoTarget(true)
				hook.Run("OnPlayerObserve", client, state)
			else
				if (client.nutObsData) then
					-- Move they player back if they want.
					if (client:GetInfoNum("nut_obstpback", 0) > 0) then
						local position, angles = client.nutObsData[1], client.nutObsData[2]

						-- Do it the next frame since the player can not be moved right now.
						timer.Simple(0, function()
							client:SetPos(position)
							client:SetEyeAngles(angles)
							-- Make sure they stay still when they get back.
							client:SetVelocity(Vector(0, 0, 0))
						end)
					end

					-- Delete the old data.
					client.nutObsData = nil
				end

				-- Make the player visible again.
				client:SetNoDraw(false)
				client:SetNotSolid(false)
				client:DrawWorldModel(true)
				client:DrawShadow(true)
				-- Let the player take damage again.
				client:GodDisable()
				-- Let npcs target the player again.
				client:SetNoTarget(false)
				hook.Run("OnPlayerObserve", client, state)
			end
		end
		
		return true
	end
end

function PLUGIN:InitializedPlugins()
	-- ok this is some hacky shiznit, but is best solution for custom commands and whatnot for admin access
	-- across multiple plugins that i have no control over
	for cmd,info in next, nut.command.list do
		-- automagical access shit to override
		if info.group or info.superAdminOnly or info.adminOnly then
			info.onCheckAccess = function(client)
				return client:hasPermission(cmd)
			end
			info.onRun = function(client, arguments)
				if !info.onCheckAccess(client) then
					return "@noPerm"
				else
					return info._onRun(client, arguments)
				end
			end
			
			nut.admin.commands[cmd] = true
		end
	end
	
	-- a lot of these kinds of detours we might have to update for things to work in the future
	-- but this allows for better support
	nut.command.findPlayer = function(client, name)
		local calling_func = debug.getinfo(2)
		local command
		local target = type(name) == "string" and nut.util.findPlayer(name) or NULL

		for cmd,info in next, nut.command.list do
			if info._onRun == calling_func.func then
				-- we've found our command
				command = info
			end
		end

		if (IsValid(target)) then
			if command and (command.adminOnly or command.superAdminOnly) then
				local target_group = nut.admin.permissions[target:GetUserGroup()]
				local client_group = nut.admin.permissions[client:GetUserGroup()]
				
				if target_group.position < client_group.position then
					client:notifyLocalized("plyCantTarget")
					return
				end
			end
		
			return target
		else
			client:notifyLocalized("plyNoExist")
		end
	end
end

/* gotta give people some way to actually make themselves a rank lol */

concommand.Add("plysetgroup", function( ply, cmd, args )
    if !IsValid(ply) then
		local target = nut.util.findPlayer(args[1])
		if IsValid(target) then
			if nut.admin.permissions[args[2]] then
				nut.admin.setPlayerGroup(target, args[2])
			else
				MsgC(Color(200,20,20), "[NutScript Admin] Error: usergroup not found.\n")
			end
		else
			MsgC(Color(200,20,20), "[NutScript Admin] Error: specified player not found.\n")
		end
	end
end)

/* command to populate default ranks */

concommand.Add("nsadmin_createownergroup", function( ply, cmd, args )
    if !IsValid(ply) then
		nut.admin.createGroup("owner", {
			position = 0,
			admin = false,
			superadmin = true,
			permissions = {},
		})
		
		for cmd,_ in next, nut.admin.commands do
			nut.admin.permissions["owner"].permissions[cmd] = true
		end
		
		nut.admin.save(true)
	end
end)

concommand.Add("nsadmin_wipegroups", function( ply, cmd, args )
    if !IsValid(ply) then
		for k,v in next, player.GetAll() do
			v:SetUserGroup("user")
		end
	
		nut.admin.permissions = {}
		nut.admin.save(true)
	end
end)