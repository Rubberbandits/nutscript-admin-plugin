local PLUGIN = PLUGIN
local meta = FindMetaTable("Player")
nut.admin = nut.admin or {}
nut.admin.permissions = nut.admin.permissions or {}

function nut.admin.save(network)
	-- fuck a db
	file.Write("nutscript/admin_permissions.txt", util.TableToJSON(nut.admin.permissions))
	
	if network then
		-- honestly, networking the whole ass table is bad practice on every change is bad practice, but who cares lol
		netstream.Start(nil, "nutscript_updateAdminPermissions", nut.admin.permissions)
	end
end

function nut.admin.load()
	nut.admin.permissions = util.JSONToTable(file.Read("nutscript/admin_permissions.txt", "DATA")) or {}
end

function PLUGIN:InitPostEntity()
	nut.admin.load()
end

function PLUGIN:ShutDown()
	nut.admin.save()
end

netstream.Start("nutscript_requestAdminPermissions", function(ply)
	netstream.Start(ply, "nutscript_updateAdminPermissions", nut.admin.permissions)
end)