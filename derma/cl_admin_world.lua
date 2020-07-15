local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(255,0,0)
	surface.DrawOutlinedRect(0,0,w,h)
end

vgui.Register("DAdminWorldMenu", PANEL, "DPanel")