local PANEL = {}

function PANEL:Init()
	self:SetTitle(L("adminMenuTitle"))
	self:SetSize(ScrW() / 2, ScrH() / 1.5)
	self:Center()
	self:MakePopup()
	self:SetSkin("Default")
	
	self.menuTabs = self:Add("DPropertySheet")
	self.menuTabs:Dock(FILL)
	self.menuTabs.childTabs = {}
	
	for _,info in next, nut.admin.menu.tabs do
		local icon = info.icon
		local panelClass = info.panelClass
		local title = L(info.title)
		local panel = self.menuTabs:Add(panelClass)
		
		self.menuTabs:AddSheet(title, panel, icon)
		self.menuTabs.childTabs[#self.menuTabs.childTabs + 1] = panel
	end
end

vgui.Register("DAdminMenu", PANEL, "DFrame")