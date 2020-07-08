local PLUGIN = PLUGIN
nut.admin = nut.admin or {}

-- plykick
-- plyban
-- plyslap
-- plykill
-- plygag
-- plysetgroup
-- plysethealth
-- grpsetadmin
-- grpsetsuperadmin
-- grpsetposition
-- editinv

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