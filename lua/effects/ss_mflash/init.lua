EFFECT.mat = Material("sprites/serioussam/flare")

function EFFECT:Init(data)	
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Refract = 0
	self.Size = data:GetScale()
	
	local lightpos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	if GetConVarNumber("ss_firelight") == 0 then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = lightpos
		dynlight.Size = 64
		dynlight.R = 80
		dynlight.G = 80
		dynlight.B = 60
		dynlight.Brightness = 8
		dynlight.DieTime = CurTime()+.05
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	self.Size = self.Size * self.Refract^(-0.005)
	if self.Refract >= math.Rand(.02,.01) then return false end
	return true
end

function EFFECT:Render()
	local Muzzle = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	if !self.WeaponEnt or !IsValid(self.WeaponEnt) or !Muzzle then return end
	render.SetMaterial(self.mat)
	render.DrawSprite(Muzzle, self.Size, self.Size)
	self:SetRenderBoundsWS(Muzzle, self.Position)
end