local PLUGIN = PLUGIN
nut.admin = nut.admin or {}
nut.admin.permissions = nut.admin.permissions or {}

netstream.Hook("nutscript_updateAdminPermissions", function(info)
	nut.admin.permissions = info
end)

-- this is actually a little slow, but its not a big deal on startup.
function PLUGIN:InitPostEntity()
	netstream.Start("nutscript_requestAdminPermissions")
end