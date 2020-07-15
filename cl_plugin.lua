local PLUGIN = PLUGIN
nut.admin = nut.admin or {}
nut.admin.menu = nut.admin.menu or {}
nut.admin.menu.tabs = nut.admin.menu.tabs or {}

function nut.admin.menu.addTab(info)
	nut.admin.menu.tabs[info.title] = info
end

nut.admin.menu.addTab({
	icon = "icon16/world.png",
	panelClass = "DAdminWorldMenu",
	title = "adminWorldMenuTitle",
})  