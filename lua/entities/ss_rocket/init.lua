
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/projectiles/serioussam/rocket.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)

	local glow = ents.Create("env_sprite")
	glow:SetKeyValue("rendercolor","255 180 60")
	glow:SetKeyValue("GlowProxySize","2")
	glow:SetKeyValue("HDRColorScale","1")
	glow:SetKeyValue("renderfx","14")
	glow:SetKeyValue("rendermode","3")
	glow:SetKeyValue("renderamt","100")
	glow:SetKeyValue("model","sprites/flare1.spr")
	glow:SetKeyValue("scale","1.5")
	glow:Spawn()
	glow:SetParent(self)
	glow:SetPos(self:GetPos())
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(true)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
	self.Fuel = 20 + math.Rand(-5,5)
	self.deployDelay = true
end

function ENT:SetDamage(dmg)
	self.Damage = dmg
end

function ENT:PhysicsCollide(data, physobj)
	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	util.Decal("Scorch",start,endpos)
	
	local effectdata = EffectData()
	effectdata:SetAngles(data.HitNormal:Angle())
	effectdata:SetOrigin(endpos)
	effectdata:SetScale(2)
	util.Effect("ss_shockwave", effectdata)
	
	local explosion = EffectData()
	explosion:SetOrigin(endpos)
	explosion:SetMagnitude(1)
	explosion:SetScale(1)
	explosion:SetRadius(2)
	util.Effect("Sparks", explosion)
	util.Effect("ss_exprocket", explosion)
	util.Effect("ss_expparticles", explosion)
	
	self:EmitSound("weapons/serioussam/Explosion02.wav", 100, 100)
	util.BlastDamage(self, self:GetOwner(), start, 125, self.Damage + (self.Fuel/3))
	self:Remove()
end

function ENT:OnRemove()
	if self.flysound then self.flysound:Stop() end
end

function ENT:Think()
	if self.deployDelay then
		self.deployDelay = nil
		self.flysound = CreateSound(self, "weapons/serioussam/RocketFly.wav")
		self.flysound:Play()
		ParticleEffectAttach("rockettrail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	end
	local phys = self:GetPhysicsObject()
	
	if IsValid(phys) then
	
		if self.Fuel > 0 then 
			self.Fuel = self.Fuel - 1
			phys:ApplyForceCenter(self:GetAngles():Forward() * 50 * self.Fuel * phys:GetMass())
			phys:AddAngleVelocity(Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5)))
			
		else
			phys:EnableGravity(true)
			phys:EnableDrag(true)
		end

	end
	
	
	
end