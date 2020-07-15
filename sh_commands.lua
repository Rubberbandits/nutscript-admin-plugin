local PLUGIN = PLUGIN
nut.admin = nut.admin or {}

-- plyslap
-- plygag
-- plysethealth
-- grpsetadmin
-- grpsetsuperadmin
-- editinv

/* Player management commands */

nut.command.add("plykick", {
	adminOnly = true,
	syntax = "<string name> [string reason]",
	onRun = function(client, arguments)
		if SERVER then
			local target = nut.command.findPlayer(client, arguments[1])
			if IsValid(target) then
				target:Kick(L("kickMessage", target, arguments[2] or "No reason specified."))
				client:notifyLocalized("plyKicked")
			end
		end
	end
})

nut.command.add("plyban", {
	adminOnly = true,
	syntax = "<string name> [number duration] [string reason]",
	onRun = function(client, arguments)
		if SERVER then
			local target = nut.command.findPlayer(client, arguments[1])
			if IsValid(target) then
				target:banPlayer(arguments[3] or "No reason specified.", arguments[2])
				client:notifyLocalized("plyBanned")
			end
		end
	end
})

nut.command.add("plykill", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function(client, arguments)
		if SERVER then
			local target = nut.command.findPlayer(client, arguments[1])
			if IsValid(target) then
				target:Kill()
				client:notifyLocalized("plyKilled")
			end
		end
	end
})

nut.command.add("plysetgroup", {
	adminOnly = true,
	syntax = "<string name> <string group>",
	onRun = function(client, arguments)
		if SERVER then
			local target = nut.command.findPlayer(client, arguments[1])
			if IsValid(target) and nut.admin.permissions[arguments[2]] then
				nut.admin.setPlayerGroup(target, arguments[2])
				client:notifyLocalized("plyGroupSet")
			elseif IsValid(target) and !nut.admin.permissions[arguments[2]] then
				client:notifyLocalized("groupNotExists")
			end
		end
	end
})

/* Group management commands */

nut.command.add("grpaddgroup", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function(client, arguments)
		if SERVER then
			if !nut.admin.permissions[arguments[1]] then
				nut.admin.createGroup(arguments[1])
				client:notifyLocalized("groupCreated")
			else
				client:notifyLocalized("groupExists")
			end
		end
	end
})

nut.command.add("grprmgroup", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function(client, arguments)
		if SERVER then
			if nut.admin.permissions[arguments[1]] then
				nut.admin.removeGroup(arguments[1])
				client:notifyLocalized("groupRemoved")
			else
				client:notifyLocalized("groupNotExists")
			end
		end
	end
})

-- i really, really hate these specific notifications, but gotta tell the retards whats wrong when it doesnt work.
nut.command.add("grpaddperm", {
	adminOnly = true,
	syntax = "<string name> <string command>",
	onRun = function(client, arguments)
		if SERVER then
			if nut.admin.permissions[arguments[1]] and nut.admin.commands[arguments[2]] and !nut.admin.permissions[arguments[1]].permissions[arguments[2]] then
				nut.admin.addPermission(arguments[1], arguments[2])
				client:notifyLocalized("permissionAdded")
			elseif !nut.admin.permissions[arguments[1]] then
				client:notifyLocalized("groupNotExists")
			elseif !nut.admin.commands[arguments[2]] then
				client:notifyLocalized("commandNotExists")
			elseif nut.admin.permissions[arguments[1]].permissions[arguments[2]] then
				client:notifyLocalized("groupPermExists")
			end
		end
	end
})

nut.command.add("grprmperm", {
	adminOnly = true,
	syntax = "<string name> <string command>",
	onRun = function(client, arguments)
		if SERVER then
			if nut.admin.permissions[arguments[1]] and nut.admin.commands[arguments[2]] and nut.admin.permissions[arguments[1]].permissions[arguments[2]] then
				nut.admin.removePermission(arguments[1], arguments[2])
				client:notifyLocalized("permissionRemoved")
			elseif !nut.admin.permissions[arguments[1]] then
				client:notifyLocalized("groupNotExists")
			elseif !nut.admin.commands[arguments[2]] then
				client:notifyLocalized("commandNotExists")
			elseif !nut.admin.permissions[arguments[1]].permissions[arguments[2]] then
				client:notifyLocalized("groupNoPermExists")
			end
		end
	end
})

nut.command.add("grpsetposition", {
	adminOnly = true,
	syntax = "<string name> <number position>",
	onRun = function(client, arguments)
		if SERVER then
			local pos = tonumber(arguments[2])
			if nut.admin.permissions[arguments[1]] and isnumber(pos) then
				nut.admin.setGroupPosition(arguments[1], pos)
				client:notifyLocalized("groupPosChanged")
			elseif !nut.admin.permissions[arguments[1]] then
				client:notifyLocalized("groupNotExists")
			elseif !isnumber(pos) then
				client:notifyLocalized("invalidArg")
			end
		end
	end
})