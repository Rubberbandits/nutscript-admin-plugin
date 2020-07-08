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