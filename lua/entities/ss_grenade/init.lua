AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/projectiles/serioussam/grenade.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(5)
		phys:Wake()
	end
end

function ENT:SetExplodeDelay(flDelay)
	self.delayExplode = CurTime() +flDelay
end

function ENT:SetDamage(dmg)
	self.Damage = dmg
end

function ENT:PhysicsCollide(data,phys)
	self:EmitSound("weapons/serioussam/grenadelauncher/Bounce.wav")
	local impulse = -data.Speed * data.HitNormal * 1.5
	phys:ApplyForceCenter(impulse)
end

function ENT:Think()
	if !self.delayExplode || CurTime() < self.delayExplode then return end
	self.delayExplode = nil
	self:Explode()
end

function ENT:Explode()
	local pos = self:GetPos()

	local effectdata = EffectData()
	effectdata:SetAngles(pos:Angle())
	effectdata:SetOrigin(pos)
	effectdata:SetScale(3.8)
	util.Effect("ss_shockwave", effectdata)
	
	local explosion = EffectData()
	explosion:SetOrigin(pos)
	explosion:SetMagnitude(3)
	explosion:SetScale(2)
	explosion:SetRadius(4)
	util.Effect("Sparks", explosion)
	util.Effect("ss_exprocket", explosion)
	util.Effect("ss_expparticles", explosion)
	
	self:EmitSound("weapons/serioussam/Explosion02.wav", 100, 100)
	util.BlastDamage(self, self:GetOwner(), pos, 256, self.Damage)
	self:Remove()
end

function ENT:StartTouch(ent)
	if (ent:IsValid() and ent:IsPlayer() or ent:IsNPC() or ent:Health() > 0) then
 		self:Explode()
	end
end