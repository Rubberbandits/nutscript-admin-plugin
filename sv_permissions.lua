local PLUGIN = PLUGIN
local meta = FindMetaTable("Player")
nut.admin = nut.admin or {}
nut.admin.permissions = nut.admin.permissions or {}

function nut.admin.save(network)
	-- fuck a db
	file.Write("nutscript/admin_permissions.txt", util.TableToJSON(nut.admin.permissions))
	
	if network then
		-- honestly, networking the whole ass table on every change is bad practice, but who cares lol
		netstream.Start(nil, "nutscript_updateAdminPermissions", nut.admin.permissions)
	end
end

function nut.admin.load()
	nut.admin.permissions = util.JSONToTable(file.Read("nutscript/admin_permissions.txt", "DATA") or "")
end

function nut.admin.setPlayerGroup(ply, usergroup)
	ply:SetUserGroup(usergroup)
	nut.db.query(Format("UPDATE nut_players SET _userGroup = '%s' WHERE _steamID = %s", nut.db.escape(usergroup), ply:SteamID64()))
end

function nut.admin.createGroup(groupName, info)
	if nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup already exists!\n")
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
		Error("[NutScript Administration] This usergroup doesn't exist!\n")
		return
	end
	
	nut.admin.permissions[groupName] = nil
		
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.addPermission(groupName, permission)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!\n")
		return
	end
	
	nut.admin.permissions[groupName]["permissions"][permission] = true
		
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.removePermission(groupName, permission)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!\n")
		return
	end
	
	nut.admin.permissions[groupName]["permissions"][permission] = nil
		
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.setIsAdmin(groupName, isAdmin)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!\n")
		return
	end
	
	nut.admin.permissions[groupName].admin = isAdmin
	
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.setIsSuperAdmin(groupName, isAdmin)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!\n")
		return
	end
	
	nut.admin.permissions[groupName].superadmin = isAdmin
	
	if SERVER then
		nut.admin.save(true)
	end
end

function nut.admin.setGroupPosition(groupName, position)
	if !nut.admin.permissions[groupName] then
		Error("[NutScript Administration] This usergroup doesn't exist!\n")
		return
	end
	
	local group = nut.admin.permissions[groupName]
	local oldPos = group.position
	
	for name,group in next, nut.admin.permissions do
		if name == groupName then continue end

		if position - oldPos > 0 then -- moving position down the stack
			if group.position > oldPos and group.position <= position then
				group.position = group.position - 1
			end
		elseif position - oldPos < 0 then -- moving position up the stack
			if group.position < oldPos and group.position >= position then
				group.position = group.position + 1
			end
		end
	end
	
	group.position = position
	
	if SERVER then
		nut.admin.save(true)
	end
end

function PLUGIN:InitPostEntity()
	nut.admin.load()
end

function PLUGIN:ShutDown()
	nut.admin.save()
end

function PLUGIN:PlayerAuthed(ply, steamid, uid)
	nut.db.query(Format("SELECT _userGroup FROM nut_players WHERE _steamID = %s", util.SteamIDTo64(steamid)), function(data)
		ply:SetUserGroup(data[1]._userGroup)
	end)
end

netstream.Hook("nutscript_requestAdminPermissions", function(ply)
	netstream.Start(ply, "nutscript_updateAdminPermissions", nut.admin.permissions)
end)

local MYSQL_FINDCOLUMN = [[SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='%s' AND TABLE_NAME='nut_players' and column_name='_userGroup';]]
local MYSQL_CREATECOLUMN = [[ALTER TABLE `nut_players` ADD COLUMN `_userGroup` varchar(255) NOT NULL DEFAULT 'user';]]

local SQLITE_FINDCOLUMN = [[SELECT EXISTS (SELECT * FROM sqlite_master WHERE tbl_name = 'nut_players' AND sql LIKE '_userGroup');]]

hook.Add("OnLoadTables", "nut.admin.permissions.setupUsergroup", function() -- lame af tbh
	if nut.db.object then
		nut.db.query(Format(MYSQL_FINDCOLUMN, nut.db.database), function(data)
			if !data then
				nut.db.query(MYSQL_CREATECOLUMN)
			end
		end)
	else
		nut.db.query(SQLITE_FINDCOLUMN, function(data)
			if !data then
				nut.db.query(MYSQL_CREATECOLUMN)
			end
		end)
	end
end)
