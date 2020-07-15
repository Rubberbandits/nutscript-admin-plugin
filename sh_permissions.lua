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
	if !nut.admin.permissions[self:GetUserGroup()] then return false end

	return (nut.admin.permissions[self:GetUserGroup()].admin or nut.admin.permissions[self:GetUserGroup()].superadmin) or false
end

function meta:IsSuperAdmin()
	if !nut.admin.permissions[self:GetUserGroup()] then return false end

	return nut.admin.permissions[self:GetUserGroup()].superadmin or false
end