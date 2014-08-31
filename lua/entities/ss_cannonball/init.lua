AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_phx/misc/smallcannonball.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	--self:SetMoveType(MOVETYPE_VPHYSICS)
	--self:SetSolid(SOLID_VPHYSICS)
	--self:SetCustomCollisionCheck( true )
	--self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(true)
		phys:EnableGravity(true)
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
		--phys:AddGameFlag(FVPHYSICS_DMG_DISSOLVE)
		--phys:AddGameFlag(FVPHYSICS_NO_SELF_COLLISIONS)
	end
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
		timer.Simple(10,function() 
			if self:IsValid() then 
				self:Remove()
			end
		end)
	end
		
	local impulse = (-data.Speed * data.HitNormal) * 0.5
	

	
	phys:ApplyForceCenter(impulse)
	if data.HitEntity:Health() > 0 then
		data.HitEntity:TakeDamage(data.Speed/4,self.Owner,self)
		print(data.Speed/4)
	end
	
end