EFFECT.mat = Material("sprites/serioussam/explosionrocket")
local exists = file.Exists("materials/sprites/serioussam/explosionrocket.vmt", "GAME")

function EFFECT:Init(data)
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
	render.SetMaterial(self.mat)
	if exists then
		self.mat:SetInt("$frame", math.Clamp(math.floor(14-(self.time-CurTime())*14),0,11))
	end
	render.DrawSprite(self.Pos, self.Size, self.Size)
end