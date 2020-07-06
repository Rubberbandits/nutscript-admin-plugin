local PLUGIN = PLUGIN
PLUGIN.name = "Admin"
PLUGIN.author = "rusty"
PLUGIN.desc = "Stop using paid admin mods, idiots."
-- i included this so messages presented to players via the server will be in the language of the server's choice.
PLUGIN.language = "english"

nut.admin = nut.admin or {}

nut.util.include("sh_permissions.lua")
nut.util.include("cl_permissions.lua")

if SERVER then
	nut.util.include("sv_permissions.lua")
	nut.util.include("sv_bans.lua")
end

local PLUGIN = PLUGIN

-- in order to create groups that can noclip
-- oh this will also fix prediction errors, thanks chessnut.

function PLUGIN:InitializedPlugins()
	local plugin = nut.plugin.list["observer"]
	
	function plugin:PlayerNoClip(client, state)
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
		end
	end
end