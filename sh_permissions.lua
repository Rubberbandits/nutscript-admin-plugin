local PLUGIN = PLUGIN
local meta = FindMetaTable("Player")
nut.admin = nut.admin or {}
nut.admin.permissions = nut.admin.permissions or {}

function meta:hasPermission(cmd) -- if returns nil, wtf??
	return nut.admin.permissions[self:GetUserGroup()] and nut.admin.permissions[self:GetUserGroup()]["permissions"][cmd] or false
end

-- we shall be detouring IsAdmin and IsSuperAdmin, just so we can support some other
-- plugins that go off of those funcs

function meta:IsAdmin()
	return nut.admin.permissions[self:GetUserGroup()] and nut.admin.permissions[self:GetUserGroup()].admin or false
end

function meta:IsSuperAdmin()
	return nut.admin.permissions[self:GetUserGroup()] and nut.admin.permissions[self:GetUserGroup()].superadmin or false
end

function nut.admin.createGroup(groupName, info)
	if nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup already exists!")
		return
	end
	
	nut.admin.permissions[groupName] = info or {
		position = table.Count(nut.admin.permissions),
		admin = false,
		superadmin = false,
		permissions = {},
	}
	
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.removeGroup(groupName)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!")
		return
	end
	
	nut.admin.permissions[groupName] = nil
		
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.addPermission(groupName, permission)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!")
		return
	end
	
	nut.admin.permissions[groupName]["permissions"][permission] = true
		
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.removePermission(groupName, permission)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!")
		return
	end
	
	nut.admin.permissions[groupName]["permissions"][permission] = nil
		
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.setIsAdmin(groupName, isAdmin)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!")
		return
	end
	
	nut.admin.permissions[groupName].admin = isAdmin
	
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.setIsSuperAdmin(groupName, isAdmin)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!")
		return
	end
	
	nut.admin.permissions[groupName].superadmin = isAdmin
	
	if SERVER then
		nut.admin.save(true)
	end
end