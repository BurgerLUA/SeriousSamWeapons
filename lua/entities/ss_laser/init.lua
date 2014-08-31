
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/projectiles/serioussam/laserproj.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:DrawShadow(false)

	local glow = ents.Create("env_sprite")
	glow:SetKeyValue("rendercolor","60 255 60")
	glow:SetKeyValue("GlowProxySize","2")
	glow:SetKeyValue("HDRColorScale","1")
	glow:SetKeyValue("renderfx","14")
	glow:SetKeyValue("rendermode","3")
	glow:SetKeyValue("renderamt","100")
	glow:SetKeyValue("model","sprites/flare1.spr")
	glow:SetKeyValue("scale","1.2")
	glow:Spawn()
	glow:SetParent(self)
	glow:SetPos(self:GetPos())
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
		phys:SetVelocity(self:GetForward()*4000)
	end
end

function ENT:SetDamage(dmg)
	self.Damage = dmg
end

function ENT:PhysicsCollide(data, physobj)
	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	util.Decal("fadingscorch",start,endpos)

	local effectdata = EffectData()
	effectdata:SetAngles(data.HitNormal:Angle())
	effectdata:SetOrigin(endpos)
	effectdata:SetScale(.65)
	util.Effect("ss_shockwavegreen", effectdata)

	local dmginfo = DamageInfo()
	
	dmginfo:SetDamage( self.Damage )
	dmginfo:SetDamageType( DMG_SHOCK )
	dmginfo:SetInflictor(self.Entity)
	dmginfo:SetAttacker( self.Entity:GetOwner() ) 
	dmginfo:SetDamageForce( data.HitNormal*1000 )

	data.HitEntity:TakeDamageInfo(dmginfo)
	self:Remove()
end