EFFECT.mat = Material("sprites/serioussam/explosionrocket")
local exists = file.Exists("materials/sprites/serioussam/explosionrocket.vmt", "GAME")

function EFFECT:Init(data)
	self.Ang = data:GetAngles()
	self.time = CurTime()+1
	self.Refract = 0
	self:SetRenderBounds(Vector()*-512, Vector()*512)
	
	self.Size = 256
	self.Pos = data:GetOrigin()
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	if self.Refract >= .9 then return false end	
	return true
end

function EFFECT:Render()
	local ang
	if self.Ang.p > 0 then
		ang = self:GetAngles():Up()
	else
		ang = self.Ang:Forward()
	end

	print(self.Ang.p)

	render.SetMaterial(self.mat)
	if exists then
		self.mat:SetInt("$frame", math.Clamp(math.floor(14-(self.time-CurTime())*14),0,11))
	end
	//render.DrawSprite(self.Pos, self.Size, self.Size)
	render.DrawQuadEasy(self.Pos, ang, self.Size, self.Size, Color(255,255,255,255), 0)
end