local PLUGIN = PLUGIN
nut.admin = nut.admin or {}
nut.admin.bans = nut.admin.bans or {}
nut.admin.bans.list = nut.admin.bans.list or {}

function nut.admin.bans.add(steamid, reason, duration)
	local genericReason = nut.lang.stored[PLUGIN.language].genericReason
	if !steamid then
		Error("[NutScript Admin] nut.admin.bans.add: no steam id specified!")
	end

	-- just dont want two calls with (possibly) different starts for bans
	local banStart = os.time()

	nut.admin.bans.list[steamid] = {
		reason = reason or genericReason,
		start = banStart,
		duration = (duration * 60) or 0,
	}
	
	nut.db.insertTable({
		_steamID = "\""..steamid.."\"",
		_banStart = banStart,
		_banDuration = (duration * 60) or 0,
		_reason = reason or genericReason,
	}, nil, "bans")
end

function nut.admin.bans.remove(steamid)
	if !steamid then
		Error("[NutScript Admin] nut.admin.bans.remove: no steam id specified!")
	end
	
	nut.admin.bans.list[steamid] = nil
	
	-- lol, having to escape info. a prepared query would work so much better
	-- but gotta have sqlite support for the plebs and tmysql4 users (why tf would u use that trash module)
	nut.db.query(Format("DELETE FROM nut_bans WHERE _steamID = '%s'", nut.db.escape(steamid)), function(data)
		MsgC(Color(0, 200, 0), "[NutScript Admin] Ban removed.\n") -- gotta switch this over to nut.log
	end)
end

function nut.admin.bans.isBanned(steamid)
	return nut.admin.bans.list[steamid] or false
end

function nut.admin.bans.hasExpired(steamid)
	local ban = nut.admin.bans.list[steamid]
	if !ban then return true end
	if ban.duration == 0 then return false end
	
	return ban.start + ban.duration <= os.time()
end

local meta = FindMetaTable("Player")

function meta:banPlayer(reason, duration)
	nut.admin.bans.add(self:SteamID64(), reason, duration)
	self:Kick(L("banMessage", self, duration or 0, reason or L("genericReason", self)))
end

nut.admin.bans.sqlite_createTables = [[
CREATE TABLE IF NOT EXISTS `nut_bans` (
	`_steamID` TEXT,
	`_banStart` INTEGER,
	`_banDuration` INTEGER,
	`_reason` TEXT
);
]]

nut.admin.bans.mysql_createTables = [[
CREATE TABLE IF NOT EXISTS `nut_bans` (
	`_steamID` varchar(64) NOT NULL,
	`_banStart` int(32) NOT NULL,
	`_banDuration` int(32) NOT NULL,
	`_reason` varchar(512) DEFAULT '',
	PRIMARY KEY (`_steamID`)
);
]]

hook.Add("OnLoadTables", "nut.admin.bans.setupDatabase", function() -- cool
	nut.db.query(nut.db.object and nut.admin.bans.mysql_createTables or nut.admin.bans.sqlite_createTables)
end)

hook.Add("OnDatabaseLoaded", "nut.admin.bans.loadBanlist", function()
	nut.db.query("SELECT * FROM nut_bans", function(data)
		if data and istable(data) then
			local list = {}
			for _,ban in next, data do
				list[ban._steamID] = {
					reason = ban._reason,
					start = ban._banStart,
					duration = ban._banDuration,
				}
			end
			
			nut.admin.bans.list = list
		end
	end)
end)

function PLUGIN:CheckPassword(steamid64, ipAddress, svPassword, clPassword, name)
	local banned = nut.admin.bans.isBanned(steamid64)
	local hasExpired = nut.admin.bans.hasExpired(steamid64)
	
	if banned and !hasExpired then
		return false, Format(nut.lang.stored[PLUGIN.language].banMessage, banned.duration / 60, banned.reason)
	elseif banned and hasExpired then
		nut.admin.bans.remove(steamid64)
	end
end