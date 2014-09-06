AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_phx/cannonball_solid.mdl")
	
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
 

	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
		phys:SetMass(1000)
		phys:EnableDrag(true)
		phys:EnableGravity(true)
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
		--phys:AddGameFlag(FVPHYSICS_DMG_DISSOLVE)
		--phys:AddGameFlag(FVPHYSICS_NO_SELF_COLLISIONS)
	end
	
	timer.Simple(10,function() phys:EnableDrag(true) end)
	
end


function ENT:SetExplodeDelay(flDelay)
	self.delayExplode = CurTime() +flDelay
end

function ENT:SetDamage(dmg)
	self.Damage = dmg
end

function ENT:PhysicsCollide(data,phys)

	if data.Speed > 50 then
		self:EmitSound("weapons/serioussam/cannon/Bounce.wav",100,100)
	else
		SafeRemoveEntityDelayed( self, 5 )
	end
		
	local impulse = (-data.Speed * data.HitNormal) * 0.5
	

	
	phys:ApplyForceCenter(impulse)
	if data.HitEntity:Health() > 0 then
		data.HitEntity:TakeDamage(data.Speed/4,self.Owner,self)
		print(data.Speed/4)
	end
	
end