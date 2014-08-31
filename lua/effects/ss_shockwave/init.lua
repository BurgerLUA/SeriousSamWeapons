function EFFECT:Init(data)
	self:SetAngles(data:GetAngles() + Angle(90,0,0))
	self:SetModel("models/effects/serioussam/shockwave.mdl")
	self.Refract = 1
	self.Size = 0
	self.Scale = data:GetScale()
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	self.Size = self.Scale * self.Refract^(5)
	if self.Refract >= 1.7 then return false end
	
	return true
end

function EFFECT:Render()
	local col = 255 * -self.Refract *5 +2166
	self:SetModelScale(self.Size -3, 0)
	self:SetColor(Color(col,col,col))
	self:DrawModel()
end