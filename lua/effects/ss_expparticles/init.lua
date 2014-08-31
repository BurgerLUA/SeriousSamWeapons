EFFECT.mat = Material("sprites/serioussam/explosionparticles")
local exists = file.Exists("materials/sprites/serioussam/explosionparticles.vmt", "GAME")

function EFFECT:Init(data)
	self.time = CurTime()+1
	self.Refract = 0
	self.Entity:SetRenderBounds(Vector()*-512, Vector()*512)
	
	self.Size = 512
	self.Pos = data:GetOrigin()
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	if self.Refract >= 1.05 then return false end	
	return true
end

function EFFECT:Render()
	render.SetMaterial(self.mat)
	if exists then
		self.mat:SetInt("$frame", math.Clamp(math.floor(22-(self.time-CurTime())*22),0,22))
	end
	render.DrawSprite(self.Pos, self.Size, self.Size)
end